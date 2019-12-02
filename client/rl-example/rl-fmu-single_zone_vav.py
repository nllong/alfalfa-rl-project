# Author: Nicholas Long / Sourav Dey

import datetime
import os
import random
import sys
import time
from multiprocessing import Process, freeze_support

import pandas as pd
from lib.thermal_comfort import ThermalComfort

sys.path.append(os.path.join(os.path.dirname(__file__), '..'))
import boptest


def pe_signal():
    k_pe = 20000
    return [random.random() * k_pe for _ in range(5)]


# def Controller(object):
def compute_control(y, costs, time, heating_setpoint, cooling_setpoint):
    """
    y has any of the accessible model outputs such as the cooling power etc.
    costs are the caclulated costs for the latest timestep, including PMV

    :param y: Temperature of zone, K
    :param heating_setpoint: Temperature Setpoint, C
    :return: dict, control input to be used for the next step {<input_name> : <input_value>}
    """
    # Controller parameters
    setpoint = heating_setpoint + 273.15
    k_fan = 4
    # Compute control
    e = setpoint - y['TRooAir_y']  # 275-273 = 2 deg C
    if e > 0:
        value = 0
    else:
        value = abs(k_fan * e)
        if value > 1:
            value = 1

    # read from existing values
    # y['TRooAir_y']
    # y['ECumuHVAC']

    # if datetime.time(11, 00) < time.time() < datetime.time(15, 00):
    #     new_control_fan = 2.5
    # else:
    #     new_control_fan = 0.4

    # Sourav -- I think we want to try and control the oveUSetFan_u value.
    result = {
        'u': {
            # 'oveTSetRooHea_u': heating_setpoint + 273.15,  # + random.randint(-4, 1),
            # 'oveTSetRooCoo_u': cooling_setpoint + 273.15,  # + random.randint(-1, 4)
            'oveUSetFan_u': value
        },
        'historian': {
            'oveTSetRooHea_u': heating_setpoint + 273.15,  # + random.randint(-4, 1),
            'oveTSetRooCoo_u': cooling_setpoint + 273.15,  # + random.randint(-1, 4)
            'oveUSetFan_u': y['senUSetFan_y'],
        }
    }

    return result


def compute_costs(y, timestamp):
    # Assumptions:
    #   Occupied hours: 8 - 18
    #   TRadiant is 1.5 degC lower than room drybulb -- rough assumption. Need from model.
    #   met is 1.2 (office filing seated)
    #   clo is 1 clo for winter
    #   vel is 0.2 m/s
    #   rh is 50

    if datetime.time(8, 00) < timestamp.time() < datetime.time(18, 00):
        pmv, ppd = ThermalComfort.pmv_ppd(y['TRooAir_y'] - 273.15, y['TRooAir_y'] - 273.15 - 1.5, 1.20, 1, 0.2, 50)
    else:
        pmv = 0
        ppd = 0

    result = {
        'pmv': pmv,
        'ppd': ppd,
    }

    return result


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


def deg_k_to_c(kelvin):
    return kelvin - 273.15


class Historian(object):
    def __init__(self):
        self.data = {}
        self.name_map = {}
        self.units = {}
        self.conversion_map = {}

    def add_point(self, name, units, point_name, f_conversion=None):
        """
        Add a point to store to the historian

        :param name: string, name of the datapoint. Must be convertible into dict key and dataframe column
        :param units: string, units in which the values are stored
        :param point_name: string, name of the point to extract from the model output dictionary from Alfalfa
        :param f_conversion: function pointer, function to call to convert the value
        :return:
        """
        if name in self.data.keys():
            raise Exception(f'Historian point already exists for {name}')

        self.data[name] = []
        self.conversion_map[name] = f_conversion
        self.units[name] = units

        if point_name is not None:
            if point_name in self.name_map.keys():
                raise Exception(f'Point name in name map already exists for {point_name}')

            self.name_map[point_name] = name

    def add_data(self, values):
        """
        Append the data in the fields into the mapped column names. Pulls data out of values and
        into the historian.

        :param values: dict
        """

        for point_name, value in values.items():
            if point_name in self.name_map:
                name = self.name_map[point_name]
                # print(f"name {name} and point {point_name} with value {value}")
                f = self.conversion_map[name] if self.conversion_map[name] is not None else None
                if f:
                    value = f(value)
                self.data[name].append(value)
            else:
                # point_name is not registered in historian, skipping
                pass

    def add_datum(self, name, value):
        f = self.conversion_map[name] if self.conversion_map[name] is not None else None

        if f:
            value = f(value)
        self.data[name].append(value)

    def to_df(self):
        return pd.DataFrame.from_dict(self.data)

    def save_csv(self, filepath, filename):
        os.makedirs(filepath, exist_ok=True)

        self.to_df().to_csv(f'{filepath}/{filename}')


def main():
    bop = boptest.Boptest(url='http://localhost')

    # Denver weather
    # 1/1/2019 00:00:00  - Note that we have to start at 1/1 right now.
    beg_time = datetime.datetime(2019, 1, 1, 0, 0, 0)
    start_time = datetime.datetime(2019, 1, 2, 0, 0, 0)
    end_time = datetime.datetime(2019, 1, 3, 0, 0, 0)

    step = 300  # 5 minutes
    sim_steps = int((end_time - start_time).total_seconds() / step)  # total time (in seconds) / 5 minute steps

    heating_setpoint = 21
    cooling_setpoint = 25
    u = initialize_control(heating_setpoint, cooling_setpoint)

    file = os.path.join(os.path.dirname(__file__), 'fmus', 'single_zone_vav', 'wrapped.fmu')
    print(f"Uploading test case {file}")
    site = bop.submit(file)

    print('Starting simulation')
    bop.start(
        site,
        external_clock="true",
        start_datetime=int((start_time - beg_time).total_seconds()),
        end_datetime=int((end_time - beg_time).total_seconds())
    )

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
    for i in range(sim_steps):
        current_time = start_time + datetime.timedelta(seconds=(i * step))

        bop.setInputs(site, u['u'])
        bop.advance([site])
        model_outputs = bop.outputs(site)
        # print(u)
        # print(model_outputs)
        sys.stdout.flush()

        costs = compute_costs(model_outputs, current_time)
        historian.add_data(costs)

        u = compute_control(model_outputs, costs, current_time, heating_setpoint, cooling_setpoint)
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
    result_dir = f'results-{file_basename}'
    print(historian.to_df())
    historian.save_csv(result_dir, f'{file_basename}.csv')


# In windows you must include this to allow boptest client to multiprocess
if __name__ == '__main__':
    if os.name == 'nt':
        freeze_support()
        p = Process(target=main)
        p.start()
    else:
        # Running the debugger doesn't work on mac with freeze_support()
        main()
