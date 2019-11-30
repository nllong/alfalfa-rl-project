# Author: Nicholas Long / Sourav Dey

import datetime
import os
import random
import sys
import time
from multiprocessing import Process, freeze_support

import pandas as pd

sys.path.append(os.path.join(os.path.dirname(__file__), '..'))
import boptest


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
def compute_control(y, heating_setpoint, cooling_setpoint):
    """

    :param y: Temperature of zone, K
    :param heating_setpoint: Temperature Setpoint, C
    :return: dict, control input to be used for the next step {<input_name> : <input_value>}
    """
    # y has any of the accessible model outputs such as the cooling power etc.

    # Controller parameters
    setpoint = heating_setpoint + 273.15
    k_p = 3500
    # Compute control
    e = setpoint - y['TRooAir_y']
    # value = max(k_p * e, 0)
    u = {
        'oveTSetRooHea_u': heating_setpoint + 273.15 + random.randint(-4, 1),
        'oveTSetRooCoo_u': cooling_setpoint + 273.15 + random.randint(-1, 4)
    }

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


def deg_k_to_c(kelvin):
    return kelvin - 273.15


class Historian(object):
    def __init__(self):
        self.data = {}
        self.name_map = {}
        self.units = {}
        self.conversion_map = {}

    # def name_from_point(self, point_name):
    #     """
    #     Assumes that the mapping exists, will not check for non-existent keys at the moment.
    #
    #     :param point_name: point_name to look up the historian name
    #     :return:
    #     """
    #     return list(self.name_map.keys())[list(self.name_map.values()).index(point_name)]

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
            name = self.name_map[point_name]
            # print(f"name {name} and point {point_name} with value {value}")
            f = self.conversion_map[name] if self.conversion_map[name] is not None else None
            if f:
                value = f(value)
            self.data[name].append(value)

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
    start_time = datetime.datetime(2019, 1, 1, 1, 00, 0)
    length = 48 * 3600  # 48 hours
    step = 300  # 5 minutes
    sim_steps = int(length / step) - 1
    # sim_steps = 100  # test a few steps

    u = initialize_control()
    heating_setpoint = 21
    cooling_setpoint = 25

    file = os.path.join(os.path.dirname(__file__), 'fmus', 'single_zone_vav', 'wrapped.fmu')
    print(f"Uploading test case {file}")
    site = bop.submit(file)

    print('Starting simulation')
    bop.start(site, external_clock="true")

    historian = Historian()
    historian.add_point('timestamp', 'Time', None)
    historian.add_point('T1', 'degC', 'TRooAir_y', f_conversion=deg_k_to_c)
    historian.add_point('CoolingPower', 'W', 'PCoo_y')
    historian.add_point('HeatingPower', 'W', 'PHea_y')
    historian.add_point('FanPower', 'W', 'PFan_y')
    historian.add_point('PumpPower', 'W', 'PPum_y')
    historian.add_point('HeatingSetpoint', '', 'senTSetRooHea_y', f_conversion=deg_k_to_c)
    historian.add_point('CoolingSetpoint', '', 'senTSetRooCoo_y', f_conversion=deg_k_to_c)
    historian.add_point('u_CoolingSetpoint', '', 'oveTSetRooCoo_u', f_conversion=deg_k_to_c)
    historian.add_point('u_HeatingSetpoint', '', 'oveTSetRooHea_u', f_conversion=deg_k_to_c)


    # Initialize the flow control to random values
    # flow = [1, 1, 1, 1, 1]
    # dual band thermostat

    print('Stepping through time')
    for i in range(sim_steps):
        bop.setInputs(site, u)
        bop.advance([site])
        model_outputs = bop.outputs(site)
        # print(u)
        # print(model_outputs)
        sys.stdout.flush()
        u = compute_control(model_outputs, heating_setpoint, cooling_setpoint)
        historian.add_data(u)

        # current_time = start_time + datetime.timedelta(minutes=i)
        # history['timestamp'].append(current_time.strftime('%m/%d/%Y %H:%M:%S'))
        current_time = start_time + datetime.timedelta(seconds=(i * step))
        print(f'Running time: {current_time.strftime("%m/%d/%Y %H:%M:%S")}')
        historian.add_datum('timestamp', current_time)
        historian.add_data(model_outputs)

        # throttle the requests a bit
        time.sleep(0.01)

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
