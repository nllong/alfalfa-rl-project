# Author: Nicholas Long / Yanfei Li / Sourav Dey

import datetime
import os
import random
import sys
import time
from multiprocessing import Process, freeze_support
from alfalfa_client import AlfalfaClient
import pandas as pd


def pe_signal():
    k_pe = 20000
    return [random.random() * k_pe for _ in range(5)]


def dummy_flow():
    """
    :return: list, control actions
    """
    # create a number for the Supply Fan status
    return [random.random() * 0.5 for _ in range(0, 5)]


def pid_control(temp_states, previous_flow, setpoint, deadband=1):
    """
    Simple proportional controller, need to add integrator, no need for derivative

    :param temp_states: list, zone temperatures (C)
    :param previous_flow: list, previous control inputs, u, (scalar)
    :param setpoint: float, setpoint (C)
    :param deadband: float, deadband for setpoint (C)
    :return: list, new control inputs
    """
    # this is for 5 zones, assuming uniform setpoint
    pid_flow = []
    for index, temp in enumerate(temp_states):
        k_p = 2000
        if temp <= setpoint + deadband / 2 and temp >= setpoint - deadband / 2:
            # in the deadband... do nothing
            # print(f'in range... skipping: {temp}')
            pid_flow.append(previous_flow[index])
        else:
            if temp < setpoint - deadband / 2:
                pid_flow.append(1)
                # e = abs(setpoint - temp)
                # pid_flow.append(max(k_p * e, 0))
            elif temp > setpoint + deadband / 2:
                pid_flow.append(0)
                # e = abs(temp - setpoint)
                # pid_flow.append(max(k_p * e, 0))

    return pid_flow


def main():
    alfalfa = AlfalfaClient(url='http://localhost')

    # Winter
    start_time = datetime.datetime(2019, 2, 6, 9, 00, 0)
    simu_length = datetime.timedelta(hours=10)
    end_time = start_time + simu_length
    simu_steps = int(simu_length.total_seconds() / 60.0)  # number of time steps, of which each timestep is 1 minute
    simu_steps = 30
    print(
        f'Simulation start {start_time.strftime("%m/%d/%Y %H:%M:%S")}, end {end_time.strftime("%m/%d/%Y %H:%M:%S")} with {simu_steps} total steps'
    )

    # Submit only one file
    files = [os.path.join(os.path.dirname(__file__), 'openstudio_model', 'SmallOffice_Unitary_1.osm')]
    # files = [os.path.join(os.path.dirname(__file__), 'openstudio_model', 'SmallOffice_VAV_1.osm')]
    siteids = alfalfa.submit_many(files)
    alfalfa.start_many(siteids, external_clock="true", start_datetime=start_time, end_datetime=end_time)

    history = {
        'timestamp': [],
        'T1': [],
        'T2': [],
        'T3': [],
        'T4': [],
        'T5': [],
        'RadTemp1': [],
        'RadTemp2': [],
        'RadTemp3': [],
        'RadTemp4': [],
        'RadTemp5': [],
        'u1': [],
        'u2': [],
        'u3': [],
        'u4': [],
        'u5': [],
        'ZN1_Cooling_Rate': [],
        'ZN2_Cooling_Rate': [],
        'ZN3_Cooling_Rate': [],
        'ZN4_Cooling_Rate': [],
        'ZN5_Cooling_Rate': [],
        'ZN1_Heating_Rate': [],
        'ZN2_Heating_Rate': [],
        'ZN3_Heating_Rate': [],
        'ZN4_Heating_Rate': [],
        'ZN5_Heating_Rate': [],
        'vdot1': [],
        'vdot2': [],
        'vdot3': [],
        'vdot4': [],
        'vdot5': [],
        'Tsetpoint_cooling': [],
        'Tsetpoint_heating': [],
    }

    # Initialize the flow control to random values
    flow = [1, 1, 1, 1, 1]
    # dual band thermostat
    heating_setpoint = 21
    cooling_setpoint = 25

    for i in range(simu_steps):
        print(f"Simulation step: {i}")
        alfalfa.advance(siteids)
        new_inputs = {}
        state_vars = []
        for siteid in siteids:
            model_outputs = alfalfa.outputs(siteid)

            current_time = start_time + datetime.timedelta(minutes=i)
            history['timestamp'].append(current_time.strftime('%m/%d/%Y %H:%M:%S'))

            # get zone mean air temperature
            temp_core = model_outputs["Core_ZN ZN_Zone Mean Air Temperature"]
            temp_p1 = model_outputs["Perimeter_ZN_1 ZN_Zone Mean Air Temperature"]
            temp_p2 = model_outputs["Perimeter_ZN_2 ZN_Zone Mean Air Temperature"]
            temp_p3 = model_outputs["Perimeter_ZN_3 ZN_Zone Mean Air Temperature"]
            temp_p4 = model_outputs["Perimeter_ZN_4 ZN_Zone Mean Air Temperature"]
            history['T1'].append(temp_core)
            history['T2'].append(temp_p1)
            history['T3'].append(temp_p2)
            history['T4'].append(temp_p3)
            history['T5'].append(temp_p4)
            history['RadTemp1'].append(model_outputs["Core_ZN ZN_Zone Mean Radiant Temperature"])
            history['RadTemp2'].append(model_outputs["Perimeter_ZN_1 ZN_Zone Mean Radiant Temperature"])
            history['RadTemp3'].append(model_outputs["Perimeter_ZN_2 ZN_Zone Mean Radiant Temperature"])
            history['RadTemp4'].append(model_outputs["Perimeter_ZN_3 ZN_Zone Mean Radiant Temperature"])
            history['RadTemp5'].append(model_outputs["Perimeter_ZN_4 ZN_Zone Mean Radiant Temperature"])
            state_vars.append(temp_core)
            state_vars.append(temp_p1)
            state_vars.append(temp_p2)
            state_vars.append(temp_p3)
            state_vars.append(temp_p4)

            print(f"statevars: core/p1/p2/p3/p4: {temp_core}/{temp_p1}/{temp_p2}/{temp_p3}/{temp_p4}")

            # get zone cooling/heating rate
            cooling_core = model_outputs["Core_ZN ZN_Zone Air System Sensible Cooling Rate"]
            heating_core = model_outputs["Core_ZN ZN_Zone Air System Sensible Heating Rate"]
            cooling_p1 = model_outputs["Perimeter_ZN_1 ZN_Zone Air System Sensible Cooling Rate"]
            heating_p1 = model_outputs["Perimeter_ZN_1 ZN_Zone Air System Sensible Heating Rate"]
            cooling_p2 = model_outputs["Perimeter_ZN_2 ZN_Zone Air System Sensible Cooling Rate"]
            heating_p2 = model_outputs["Perimeter_ZN_2 ZN_Zone Air System Sensible Heating Rate"]
            cooling_p3 = model_outputs["Perimeter_ZN_3 ZN_Zone Air System Sensible Cooling Rate"]
            heating_p3 = model_outputs["Perimeter_ZN_3 ZN_Zone Air System Sensible Heating Rate"]
            cooling_p4 = model_outputs["Perimeter_ZN_4 ZN_Zone Air System Sensible Cooling Rate"]
            heating_p4 = model_outputs["Perimeter_ZN_4 ZN_Zone Air System Sensible Heating Rate"]
            history['ZN1_Cooling_Rate'].append(cooling_core)
            history['ZN2_Cooling_Rate'].append(cooling_p1)
            history['ZN3_Cooling_Rate'].append(cooling_p2)
            history['ZN4_Cooling_Rate'].append(cooling_p3)
            history['ZN5_Cooling_Rate'].append(cooling_p4)
            history['ZN1_Heating_Rate'].append(heating_core)
            history['ZN2_Heating_Rate'].append(heating_p1)
            history['ZN3_Heating_Rate'].append(heating_p2)
            history['ZN4_Heating_Rate'].append(heating_p3)
            history['ZN5_Heating_Rate'].append(heating_p4)

            print(f"cooling rate: core/p1/p2/p3/p4: {cooling_core}/{cooling_p1}/{cooling_p2}/{cooling_p3}/{cooling_p4}")
            print(f"heating rate: core/p1/p2/p3/p4: {heating_core}/{heating_p1}/{heating_p2}/{heating_p3}/{heating_p4}")

            temps = [temp_core, temp_p1, temp_p2, temp_p3, temp_p4]
            # manually implement seasonal reset
            run_cooling_data_start = datetime.datetime(2019, 4, 15, 0, 00, 0)
            run_cooling_data_end = datetime.datetime(2019, 12, 30, 0, 00, 0)

            if current_time > run_cooling_data_start and current_time < run_cooling_data_end:
                flow = pid_control(temps, flow, cooling_setpoint)
            else:
                flow = pid_control(temps, flow, heating_setpoint)

            print(f"new control inputs: core/p1/p2/p3/p4: {flow[0]}/{flow[1]}/{flow[2]}/{flow[3]}/{flow[4]}")
            history['u1'].append(flow[0])
            history['u2'].append(flow[1])
            history['u3'].append(flow[2])
            history['u4'].append(flow[3])
            history['u5'].append(flow[4])

            history['vdot1'].append(flow[0])
            history['vdot2'].append(flow[1])
            history['vdot3'].append(flow[2])
            history['vdot4'].append(flow[3])
            history['vdot5'].append(flow[4])

            model_inputs = alfalfa.inputs(siteid)

            # new_inputs must be dictionary format
            new_inputs["SA_FlowRate_Zone_Core_CMD"] = flow[0]
            new_inputs["SA_FlowRate_Zone_P1_CMD"] = flow[1]
            new_inputs["SA_FlowRate_Zone_P2_CMD"] = flow[2]
            new_inputs["SA_FlowRate_Zone_P3_CMD"] = flow[3]
            new_inputs["SA_FlowRate_Zone_P4_CMD"] = flow[4]

            # here the setpoints are dummy, for test only
            new_inputs["Cooling_Setpoint_CMD"] = cooling_setpoint
            new_inputs["Heating_Setpoint_CMD"] = heating_setpoint
            history['Tsetpoint_cooling'].append(cooling_setpoint)
            history['Tsetpoint_heating'].append(heating_setpoint)

            alfalfa.setInputs(siteid, new_inputs)

        # throttle the requests a bit
        time.sleep(0.01)

    alfalfa.stop_many(siteids)

    # storage for results
    file_basename = os.path.splitext(os.path.basename(__file__))[0]
    result_dir = f'results_{file_basename}'
    os.makedirs(result_dir, exist_ok=True)
    history_df = pd.DataFrame.from_dict(history)
    print(history_df)
    history_df.to_csv(f'{result_dir}/{file_basename}.csv')


# In windows you must include this to allow boptest client to multiprocess
if __name__ == '__main__':
    if os.name == 'nt':
        freeze_support()
        p = Process(target=main)
        p.start()
    else:
        # Running the debugger doesn't work on mac with freeze_support()
        main()
