# Author: Nicholas Long / Sourav Dey

# from __future__ import absolute_import

import datetime
import os
import sys
import time
import json
from multiprocessing import Process, freeze_support
from alfalfa_client import AlfalfaClient
from lib.historian import Historian
from lib.unit_conversions import deg_k_to_c
from rl_fmu_single_zone_vav import compute_rewards, compute_control

def main():
    alfalfa = AlfalfaClient(url='http://localhost')

    # Denver weather
    # 1/1/2019 00:00:00  - Note that we have to start at 1/1 right now.
    beg_time = datetime.datetime(2019, 1, 1, 0, 0, 0)
    start_time = datetime.datetime(2019, 1, 2, 0, 0, 0)
    end_time = datetime.datetime(2019, 1, 3, 0, 0, 0)

    step = 300  # 5 minutes
    sim_steps = int((end_time - start_time).total_seconds() / step)  # total time (in seconds) / 5 minute steps

    heating_setpoint = 21
    cooling_setpoint = 25

    file = os.path.join(os.path.dirname(__file__), 'fmus', 'single_zone_vav', 'wrapped.fmu')
    print(f"Uploading test case {file}")
    site = alfalfa.submit(file)

    print('Starting simulation')
    alfalfa.start(
        site,
        external_clock="true",
        start_datetime=int((start_time - beg_time).total_seconds()),
        end_datetime=int((end_time - beg_time).total_seconds())
    )

    historian = Historian()
    historian.add_point('timestamp', 'Time', None)
    historian.add_point('T1', 'degC', 'TRooAir_y', f_conversion=deg_k_to_c)
    historian.add_point('T1_Rad', 'degC', 'TRooRad_y', f_conversion=deg_k_to_c)
    historian.add_point('Toutdoor', 'degC', 'TOutdoorDB_y', f_conversion=deg_k_to_c)
    historian.add_point('CoolingPower', 'W', 'PCoo_y')
    historian.add_point('HeatingPower', 'W', 'PHea_y')
    historian.add_point('FanPower', 'W', 'PFan_y')
    historian.add_point('PumpPower', 'W', 'PPum_y')
    historian.add_point('TotalHVACPower', 'W', 'power')
    historian.add_point('TotalHVACEnergy', 'Ws', 'ECumuHVAC_y')  # I think this is in Watt-seconds! (sorry)
    historian.add_point('HeatingSetpoint', '', 'senTSetRooHea_y', f_conversion=deg_k_to_c)
    historian.add_point('CoolingSetpoint', '', 'senTSetRooCoo_y', f_conversion=deg_k_to_c)
    historian.add_point('FanControlInput', '', 'senUSetFan_y')
    historian.add_point('u_CoolingSetpoint', '', 'oveTSetRooCoo_u', f_conversion=deg_k_to_c)
    historian.add_point('u_HeatingSetpoint', '', 'oveTSetRooHea_u', f_conversion=deg_k_to_c)
    historian.add_point('u_FanOverride', '', 'oveUSetFan_u')
    historian.add_point('PMV', '', 'pmv')
    historian.add_point('PPD', '', 'ppd')
    historian.add_point('Reward', '', 'reward')

    print('Stepping through time')
    for i in range(sim_steps):
        current_time = start_time + datetime.timedelta(seconds=(i * step))

        # Skip setting any control points for the baseline
        # alfalfa.setInputs(site, u['u'])
        alfalfa.advance([site])
        model_outputs = alfalfa.outputs(site)
        sys.stdout.flush()

        reward_scalar, all_rewards = compute_rewards(model_outputs, current_time)
        historian.add_data(all_rewards)

        # def compute_control(y, costs, time, heating_setpoint, cooling_setpoint):
        u = compute_control(model_outputs, reward_scalar, current_time, heating_setpoint, cooling_setpoint)
        historian.add_data(u['historian'])

        # Note that we aren't setting any u values, so this control is ignored. The control will be
        # entirely determined by Modelica.

        print(f'Running time: {current_time.strftime("%m/%d/%Y %H:%M:%S")}')
        historian.add_datum('timestamp', current_time)
        historian.add_data(model_outputs)

        # throttle the requests a bit
        time.sleep(0.05)

    alfalfa.stop(site)

    # storage for results
    file_basename = os.path.splitext(os.path.basename(__file__))[0]
    result_dir = f'results_{file_basename}'
    historian.save_csv(result_dir, f'{file_basename}.csv')
    historian.save_pickle(result_dir, f'{file_basename}.pkl')
    print(historian.to_df().describe())
    kpis = historian.evaluate_performance()
    with open(f'{result_dir}/kpis_result.json', 'w') as f:
        f.write(json.dumps(kpis, indent=2))
    print(kpis)


# In windows you must include this to allow boptest client to multiprocess
if __name__ == '__main__':
    if os.name == 'nt':
        freeze_support()
        p = Process(target=main)
        p.start()
    else:
        # Running the debugger doesn't work on mac with freeze_support()
        main()
