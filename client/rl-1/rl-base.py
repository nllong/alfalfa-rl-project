# Author: Nicholas Long / Yanfei
#
import datetime
import os
import random
import sys
import time

import pandas as pd

sys.path.append(os.path.join(os.path.dirname(__file__), '..'))
import boptest


def dummy_flow():
    """
    :return: list, control actions
    """
    # create a number roughly between 1 and 10
    return [random.random() * random.random() for _ in range(0, 5)]


def RL_control(temp):
    flow = []
    for i in range(len(temp)):
        flow.append(random.random() * 2.0)

    return flow


# Setup
bop = boptest.Boptest(url='http://localhost')

# Winter Heating Window: 2019-11-06 7:30:00
start_time = datetime.datetime(2019, 11, 6, 8, 15, 0)
simu_length = datetime.timedelta(hours=10)
end_time = start_time + simu_length
simu_steps = int(simu_length.total_seconds() / 60.0)  # number of time steps, of which each timestep is 1 minute
# simu_steps = 60  # 1 hour hard coded

# Submit only one file
files = [os.path.join(os.path.dirname(__file__), 'RefBuildingSmallOffice2013_270.osm')]
siteids = bop.submit_many(files)
bop.start_many(siteids, external_clock="false", start_datetime=start_time, end_datetime=end_time)

history = {
    'timestamp': [],
    'T1': [],
    'T2': [],
    'T3': [],
    'T4': [],
    'T5': [],
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

for i in range(simu_steps):
    print(f"Simulation step: {i}")
    bop.advance(siteids)
    new_inputs = {}
    state_vars = []
    for siteid in siteids:
        model_outputs = bop.outputs(siteid)
        # print ('model-outputs: ', model_outputs)
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

        flow = dummy_flow()
        print(f"new control inputs: core/p1/p2/p3/p4: {flow[0]}/{flow[1]}/{flow[2]}/{flow[3]}/{flow[4]}")
        history['u1'] = flow[0]
        history['u2'] = flow[1]
        history['u3'] = flow[2]
        history['u4'] = flow[3]
        history['u5'] = flow[4]

        history['vdot1'] = flow[0]
        history['vdot2'] = flow[1]
        history['vdot3'] = flow[2]
        history['vdot4'] = flow[3]
        history['vdot5'] = flow[4]

        model_inputs = bop.inputs(siteid)

        # new_inputs must be dictionary format
        new_inputs["SA_FlowRate_Zone_Core_CMD"] = flow[0]
        new_inputs["SA_FlowRate_Zone_P1_CMD"] = flow[1]
        new_inputs["SA_FlowRate_Zone_P2_CMD"] = flow[2]
        new_inputs["SA_FlowRate_Zone_P3_CMD"] = flow[3]
        new_inputs["SA_FlowRate_Zone_P4_CMD"] = flow[4]

        # here the setpoints are dummy, for test only
        new_inputs["Cooling_Setpoint_CMD"] = 22.2
        new_inputs["Heating_Setpoint_CMD"] = 18.2
        history['Tsetpoint_cooling'] = 22.2
        history['Tsetpoint_heating'] = 18.2

        bop.setInputs(siteid, new_inputs)

    time.sleep(0.05)

bop.stop_many(siteids)

# storage for results
result_dir = f'{os.path.splitext(os.path.basename(__file__))[0]}-results'
os.makedirs(result_dir, exist_ok=True)
history_df = pd.DataFrame.from_dict(history)
print(history_df)
history_df.to_csv(f'{result_dir}/rl-base.csv')
