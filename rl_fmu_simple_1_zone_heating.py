# Author: Nicholas Long / Sourav Dey

import datetime
import os
import random
import sys
import time
from multiprocessing import Process, freeze_support

import pandas as pd
from alfalfa_client import AlfalfaClient


def pe_signal():
    k_pe = 20000
    return [random.random() * k_pe for _ in range(5)]


def dummy_flow():
    """
    :return: list, control actions
    """
    # create a number for the Supply Fan status
    return [random.random() * 0.5 for _ in range(0, 5)]


# def Controller(object):
def compute_control(y, heating_setpoint):
    """

    :param y: Temperature of zone, K
    :param heating_setpoint: Temperature Setpoint, C
    :return: dict, control input to be used for the next step {<input_name> : <input_value>}
    """
    # Controller parameters
    setpoint = 273.15 + 20
    k_p = 3500
    # Compute control
    e = setpoint - y['TRooAir_y']
    value = max(k_p * e, 0)
    u = {'oveAct_u': value,
         'oveAct_activate': 1}

    return u


def initialize_control():
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

    u = {'oveAct_u': 0,
         'oveAct_activate': 1}

    return u


def main():
    alfalfa = AlfalfaClient(url='http://localhost')

    # set an arbitrary start time because there is no weather at the moment
    start_time = datetime.datetime(2019, 2, 6, 9, 00, 0)
    length = 48 * 3600  # 48 hours
    step = 300  # 5 minutes
    u = initialize_control()
    heating_setpoint = 21
    # cooling_setpoint = 25

    file = os.path.join(os.path.dirname(__file__), 'fmus', 'simple_1_zone_heating', 'simple_1_zone_heating.fmu')
    print(f"Uploading test case {file}")
    site = alfalfa.submit(file)

    print('Starting simulation')
    alfalfa.start(site, external_clock="true")

    history = {
        'timestamp': [],
        'T1': [],
        # 'T2': [],
        # 'T3': [],
        # 'T4': [],
        # 'T5': [],
        # 'RadTemp1': [],
        # 'RadTemp2': [],
        # 'RadTemp3': [],
        # 'RadTemp4': [],
        # 'RadTemp5': [],
        'u1': [],
        'u2': [],
        # 'u3': [],
        # 'u4': [],
        # 'u5': [],
        # 'ZN1_Cooling_Rate': [],
        # 'ZN2_Cooling_Rate': [],
        # 'ZN3_Cooling_Rate': [],
        # 'ZN4_Cooling_Rate': [],
        # 'ZN5_Cooling_Rate': [],
        'ZN1_Heating_Rate': [],
        # 'ZN2_Heating_Rate': [],
        # 'ZN3_Heating_Rate': [],
        # 'ZN4_Heating_Rate': [],
        # 'ZN5_Heating_Rate': [],
        # 'vdot1': [],
        # 'vdot2': [],
        # 'vdot3': [],
        # 'vdot4': [],
        # 'vdot5': [],
        # 'Tsetpoint_cooling': [],
        'Tsetpoint_heating': [],
    }

    # Initialize the flow control to random values
    # flow = [1, 1, 1, 1, 1]
    # dual band thermostat

    print('Stepping through time')
    for i in range(int(length / step)):
        alfalfa.setInputs(site, u)
        alfalfa.advance([site])
        model_outputs = alfalfa.outputs(site)
        # print(u)
        # print(model_outputs)
        sys.stdout.flush()
        u = compute_control(model_outputs, heating_setpoint)

        # current_time = start_time + datetime.timedelta(minutes=i)
        # history['timestamp'].append(current_time.strftime('%m/%d/%Y %H:%M:%S'))
        # get zone mean air temperature
        # get zone cooling/heating rate
        # throttle the requests a bit
        current_time = start_time + datetime.timedelta(seconds=(i * step))
        print(f'Running time: {current_time.strftime("%m/%d/%Y %H:%M:%S")}')
        history['timestamp'].append(current_time)
        history['T1'].append(model_outputs['TRooAir_y'] - 273)
        history['ZN1_Heating_Rate'].append(model_outputs['PHea_y'])
        history['u1'].append(u['oveAct_u'])
        history['u2'].append(u['oveAct_activate'])
        history['Tsetpoint_heating'].append(heating_setpoint)
        time.sleep(0.01)

    alfalfa.stop(site)

    # storage for results
    file_basename = os.path.splitext(os.path.basename(__file__))[0]
    result_dir = f'results_{file_basename}'
    os.makedirs(result_dir, exist_ok=True)
    history_df = pd.DataFrame.from_dict(history)
    print(history_df)
    history_df.to_csv(f'{result_dir}/{file_basename}.csv')


# In windows you must include this to allow alfalfa client to multiprocess
if __name__ == '__main__':
    if os.name == 'nt':
        freeze_support()
        p = Process(target=main)
        p.start()
    else:
        # Running the debugger doesn't work on mac with freeze_support()
        main()
