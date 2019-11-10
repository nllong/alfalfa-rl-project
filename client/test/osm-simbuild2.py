import sys
import os
thispath = os.path.dirname(os.path.abspath(__file__)) 
sys.path.append(thispath + '/../')
import boptest
import time
import random
import datetime 

def RL_control(temp):
    flow = []
    for i in range(len(temp)):
        flow.append( random.random() *2.0 )
    
    return flow

sys.path.insert(0, './controllers')

from controllers import pid
# 2019-11-06 7:30:00
start_time = datetime.datetime(2019, 11, 6, 7, 30, 0)
simu_length = datetime.timedelta( hours = 10 )
end_time = start_time + simu_length
simu_steps = int(simu_length.total_seconds() / 60.0) # number of time steps, of which each timestep is 1 minute



bop = boptest.Boptest(url='http://localhost')

osm_files = []
for _ in range(1):
    osm_files.append(thispath + '/RefBuildingSmallOffice2013_270.osm')

siteids = bop.submit_many(osm_files)

bop.start_many(siteids, external_clock = "false", \
               start_datetime= start_time, end_datetime=end_time)

#new_inputs = {}
#state_vars=[]
for i in range(simu_steps):
    print ("yanfei step: ", i)
    bop.advance(siteids)
    new_inputs = {}
    state_vars=[] 
    for siteid in siteids:
        model_outputs = bop.outputs(siteid)
        #print ('model-outputs: ', model_outputs)
        
        #get zone mean air temperature
        temp_core = model_outputs["Core_ZN ZN_Zone Mean Air Temperature"]
        temp_p1 = model_outputs["Perimeter_ZN_1 ZN_Zone Mean Air Temperature"]
        temp_p2 = model_outputs["Perimeter_ZN_2 ZN_Zone Mean Air Temperature"]
        temp_p3 = model_outputs["Perimeter_ZN_3 ZN_Zone Mean Air Temperature"]
        temp_p4 = model_outputs["Perimeter_ZN_4 ZN_Zone Mean Air Temperature"]
        state_vars.append(temp_core)
        state_vars.append(temp_p1)
        state_vars.append(temp_p2)
        state_vars.append(temp_p3)
        state_vars.append(temp_p4)

        print ("statevars: core/p1/p2/p3/p4: ", temp_core, "/", temp_p1, "/", temp_p2,\
                "/", temp_p3, "/", temp_p4, "\n")

        #get zone cooling/heating rate
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

        print ("cooling core/p1/p2/p3/p4: ", cooling_core, "/", cooling_p1, "/", cooling_p2, "/", \
                cooling_p3, "/", cooling_p4, "/",  "\n")

        print ("heating core/p1/p2/p3/p4: ", heating_core, "/", heating_p1, "/", heating_p2, "/", \
                heating_p3, "/", heating_p4, "/",  "\n")

        #Here i only use a fake RL control.
        #Here you may need to replace it using your RL control
        flow = RL_control(state_vars)
        print ("new control inputs: core/p1/p2/p3/p4: ", flow[0], "/", flow[1], "/", flow[2], \
                "/", flow[3], "/", flow[4], "\n" )        

        model_inputs = bop.inputs(siteid)
        #print ('model-inputs: ', model_inputs)
        
        #new_inputs must be dictionary format
        new_inputs["SA_FlowRate_Zone_Core_CMD"] = flow[0]
        new_inputs["SA_FlowRate_Zone_P1_CMD"] = flow[1]
        new_inputs["SA_FlowRate_Zone_P2_CMD"] = flow[2]
        new_inputs["SA_FlowRate_Zone_P3_CMD"] = flow[3]
        new_inputs["SA_FlowRate_Zone_P4_CMD"] = flow[4]

        #here the setpoints are dummy, for test only
        new_inputs["Cooling_Setpoint_CMD"] =  22.2
        new_inputs["Heating_Setpoint_CMD"] =  18.2

        bop.setInputs(siteid, new_inputs)
        
        
    time.sleep(5)

bop.stop_many(siteids)

