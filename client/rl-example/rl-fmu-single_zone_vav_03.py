# Author: Nicholas Long / Sourav Dey

import datetime
import os
import random
import sys
import time
from multiprocessing import Process, freeze_support

import numpy as np
from keras.layers import Dense
from keras.models import Sequential
from keras.optimizers import SGD
from lib.historian import Historian
from lib.thermal_comfort import ThermalComfort
from lib.unit_conversions import deg_k_to_c

sys.path.append(os.path.join(os.path.dirname(__file__), '..'))
import boptest


def pe_signal():
    k_pe = 20000
    return [random.random() * k_pe for _ in range(5)]


def states(model_outputs, current_time):
    i_temp = y['TRooAir_y'] - 273.15
    o_temp = y['TOutdoorDB_y'] - 273.15
    # energy = y['ECumuHVAC']
    t_state = current_time.time().hour + current_time.time().minute / 60

    return np.array([[i_temp, o_temp, t_state]])


# defining the action and limiting it between nearly zero and 1, we should get this value from the actor network
def action_flowrate(action_mean):
    action = float(np.random.normal(action_mean, 0.01, 1))
    if action < 0.001:
        action = [0.001]
    elif action > 1.0:
        action = [1.0]

    result = {
        'u': {
            # 'oveTSetRooHea_u': heating_setpoint + 273.15,  # + random.randint(-4, 1),
            # 'oveTSetRooCoo_u': cooling_setpoint + 273.15,  # + random.randint(-1, 4)
            'oveUSetFan_u': action
        },
        'historian': {
            'oveTSetRooHea_u': heating_setpoint + 273.15,  # + random.randint(-4, 1),
            'oveTSetRooCoo_u': cooling_setpoint + 273.15,  # + random.randint(-1, 4)
            'oveUSetFan_u': y['senUSetFan_y'],
        }
    }

    return result


# create the actor network
def actor_network():
    def custom_loss(y_true, y_pred):
        print(y_true)
        print(y_pred)
        s = np.clip(y_pred, a_min=0.0001, a_max=1.0)
        s = -np.log(s)
        return s

    actor = Sequential()
    actor.add(Dense(100, activation='sigmoid', input_shape=(3,), kernel_initializer='he_uniform'))
    actor.add(Dense(200, activation='tanh', kernel_initializer='he_uniform'))
    actor.add(Dense(8, activation='tanh', kernel_initializer='he_uniform'))
    actor.add(Dense(1, activation='sigmoid', kernel_initializer='he_uniform'))

    epochs, learning_rate, momentum = 80, 0.01, 0.8
    decay_rate = learning_rate / epochs
    sgd = SGD(lr=learning_rate, momentum=momentum, decay=decay_rate)

    actor.compile(loss=custom_loss, optimizer=sgd)

    return actor


# create the critic network
def critic_network():
    critic = Sequential()
    critic.add(Dense(100, activation='sigmoid', input_shape=(3,), kernel_initializer='he_uniform'))
    critic.add(Dense(200, activation='relu', kernel_initializer='he_uniform'))
    critic.add(Dense(8, activation='tanh', kernel_initializer='he_uniform'))
    critic.add(Dense(1, activation='tanh', kernel_initializer='he_uniform'))

    epochs, learning_rate, momentum = 100, 0.1, 0.8
    decay_rate = learning_rate / epochs
    sgd = SGD(lr=learning_rate, momentum=momentum, decay=decay_rate, )

    critic.compile(loss='mean_squared_error', optimizer=sgd)

    return critic


def train_model(current_state, next_state, reward):
    value = critic_network().predict([current_state[0:1]])
    next_value = critic_network().predict([next_state[0:1]])

    gamma_td = 0.9
    advantage = reward + gamma_td * next_value - value
    target = reward + gamma_td * next_value
    targ = np.array([target])

    critic_v = critic_network().fit(current_state, targ, epochs=50, verbose=0)
    actor_a = actor_network(current_state, next_state).fit(current_state, advantage, epochs=50)


def compute_rewards(y, timestamp):
    # Assumptions:
    #   Occupied hours: 8 - 18
    #   TRadiant is 1.5 degC lower than room drybulb -- rough assumption. Need from model.
    #   met is 1.2 (office filing seated)
    #   clo is 1 clo for winter
    #   vel is 0.2 m/s
    #   rh is 50

    power = y['PCoo_y'] + y['PHea_y'] + y['PFan_y'] + y['PPum_y']

    if datetime.time(8, 00) < timestamp.time() < datetime.time(18, 00):
        pmv, ppd = ThermalComfort.pmv_ppd(y['TRooAir_y'] - 273.15, y['TRooAir_y'] - 273.15 - 1.5, 1.20, 1, 0.2, 50)
    else:
        pmv = 0
        ppd = 0

    # calculate scalar - both energy and ppd should be minimized, but reward is maximized
    # power is between 0 and ~ 7000. Assume max at 10,000 W. 7000/10000 = 0.7 * 10 = 7 E [0, 10]
    # ppd is between 0 and 100 E [0,100]
    # reward E [-100, 0]
    reward = -1 * (power / 1000 + ppd)

    all_data = {
        'pmv': pmv,
        'ppd': ppd,
        'power': power,
        'reward': reward,
    }

    return reward, all_data


def initialize_control(heating_setpoint, cooling_setpoint):
    '''Initialize the control input u.

    Parameters
    ----------
    None

    Returns
    -------
    u : dict
        Defines the control input to be used for the next step.
        {<input_name> : <input_value>}

    '''

    result = {
        'u': {
            'oveTSetRooHea_u': heating_setpoint + 273.15,
            'oveTSetRooCoo_u': cooling_setpoint + 273.15,
        },
        'historian': {
            'oveTSetRooHea_u': heating_setpoint + 273.15,
            'oveTSetRooCoo_u': cooling_setpoint + 273.15,
            'oveUSetFan_u': 0.2,
        }
    }
    return result


def main():
    bop = boptest.Boptest(url='http://localhost')

    # Denver weather
    # 1/1/2019 00:00:00  - Note that we have to start at 1/1 right now.
    start_time = datetime.datetime(2019, 1, 1, 0, 0, 0)
    end_time = datetime.datetime(2019, 1, 2, 0, 0, 0)

    step = 300  # 5 minutes
    sim_steps = int((end_time - start_time).total_seconds() / step)  # total time (in seconds) / 5 minute steps

    heating_setpoint = 21
    cooling_setpoint = 25
    u = initialize_control(heating_setpoint, cooling_setpoint)

    file = os.path.join(os.path.dirname(__file__), 'fmus', 'single_zone_vav', 'wrapped.fmu')
    print(f"Uploading test case {file}")
    site = bop.submit(file)

    print('Starting simulation')
    bop.start(site, external_clock="true", start_datetime=57000, end_datetime=90000)

    historian = Historian()
    historian.add_point('timestamp', 'Time', None)
    historian.add_point('T1', 'degC', 'TRooAir_y', f_conversion=deg_k_to_c)
    historian.add_point('Toutdoor', 'degC', 'TOutdoorDB_y', f_conversion=deg_k_to_c)
    historian.add_point('CoolingPower', 'W', 'PCoo_y')
    historian.add_point('HeatingPower', 'W', 'PHea_y')
    historian.add_point('FanPower', 'W', 'PFan_y')
    historian.add_point('PumpPower', 'W', 'PPum_y')
    historian.add_point('TotalHVACEnergy', 'Ws', 'ECumuHVAC_y')  # I think this is in Watt-seconds! (sorry)
    historian.add_point('HeatingSetpoint', '', 'senTSetRooHea_y', f_conversion=deg_k_to_c)
    historian.add_point('CoolingSetpoint', '', 'senTSetRooCoo_y', f_conversion=deg_k_to_c)
    historian.add_point('FanControlInput', '', 'senUSetFan_y')
    historian.add_point('u_CoolingSetpoint', '', 'oveTSetRooCoo_u', f_conversion=deg_k_to_c)
    historian.add_point('u_HeatingSetpoint', '', 'oveTSetRooHea_u', f_conversion=deg_k_to_c)
    historian.add_point('u_FanOverride', '', 'oveUSetFan_u')
    historian.add_point('PMV', '', 'pmv')
    historian.add_point('PPD', '', 'ppd')

    # Initialize the flow control to random values
    # flow = [1, 1, 1, 1, 1]
    # dual band thermostat

    print('Stepping through time')

    # initialize the first state
    # (np.array([[i_temp, o_temp, energy, t_state]]))
    current_state = np.array([21.2, 0, 0])

    for i in range(sim_steps):
        current_time = start_time + datetime.timedelta(seconds=(i * step))

        # compute action
        actor_mean = actor_network().predict([current_state[0:1]])
        u = float(action_flowrate(actor_mean))

        bop.setInputs(site, {'oveUSetFan_u': u})
        bop.advance([site])
        model_outputs = bop.outputs(site)

        next_state = states(model_outputs, current_time)

        # print(u)
        # print(model_outputs)
        sys.stdout.flush()

        current_state = states(model_outputs, current_time)  # get the current state
        reward, all_rewards = compute_rewards(model_outputs, current_time)  # get the current cost

        train_model(current_state, next_state, reward)

        current_state = next_state

        historian.add_data(all_rewards)

        # u = compute_control(model_outputs, costs, current_time, heating_setpoint, cooling_setpoint)
        historian.add_data(u['historian'])

        # current_time = start_time + datetime.timedelta(minutes=i)
        # history['timestamp'].append(current_time.strftime('%m/%d/%Y %H:%M:%S'))

        print(f'Running time: {current_time.strftime("%m/%d/%Y %H:%M:%S")}')
        historian.add_datum('timestamp', current_time)
        historian.add_data(model_outputs)

        # throttle the requests a bit
        time.sleep(0.05)

    bop.stop(site)

    # storage for results
    file_basename = os.path.splitext(os.path.basename(__file__))[0]
    result_dir = f'results_{file_basename}'
    print(historian.to_df())
    historian.save_csv(result_dir, f'{file_basename}.csv')
    print(historian.evaluate_performance())


# In windows you must include this to allow boptest client to multiprocess
if __name__ == '__main__':
    if os.name == 'nt':
        freeze_support()
        p = Process(target=main)
        p.start()
    else:
        # Running the debugger doesn't work on mac with freeze_support()
        main()
