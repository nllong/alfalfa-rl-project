import sys
import os
thispath = os.path.dirname(os.path.abspath(__file__)) 
sys.path.append(thispath + '/../')
import boptest
import time
import random

def RL_control(temp):
    flow = []
    for i in range(len(temp)):
        flow.append( random.random() *2.0 )
    
    return flow

sys.path.insert(0, './controllers')

from controllers import pid

bop = boptest.Boptest(url='http://localhost')

osm_files = []
for _ in range(1):
    osm_files.append(thispath + '/RefBuildingSmallOffice2013_270.osm')

siteids = bop.submit_many(osm_files)
bop.start_many(siteids, external_clock = "true")

#new_inputs = {}
#state_vars=[]
for i in range(1000):
    print ("yanfei step: ", i)
    bop.advance(siteids)
    new_inputs = {}
    state_vars=[] 
    for siteid in siteids:
        model_outputs = bop.outputs(siteid)
        #print ('model-outputs: ', model_outputs)
        
        
        temp1 = model_outputs["Core_ZN ZN_Zone Mean Air Temperature"]
        temp2 = model_outputs["Perimeter_ZN_1 ZN_Zone Mean Air Temperature"]
        temp3 = model_outputs["Perimeter_ZN_2 ZN_Zone Mean Air Temperature"]
        temp4 = model_outputs["Perimeter_ZN_3 ZN_Zone Mean Air Temperature"]
        temp5 = model_outputs["Perimeter_ZN_4 ZN_Zone Mean Air Temperature"]
        state_vars.append(temp1)
        state_vars.append(temp2)
        state_vars.append(temp3)
        state_vars.append(temp4)
        state_vars.append(temp5)

        print ("statevars: ", temp1, " + ", temp2, " + ", temp3,\
                " + ", temp4, " + ", temp5, "\n")

        csp = model_outputs["Perimeter_ZN_2 ZN_Zone Air System Sensible Cooling Rate"]
        hsp = model_outputs["Perimeter_ZN_2 ZN_Zone Air System Sensible Heating Rate"]
        print ("cooling: ", csp, "heting: ", hsp , "\n")

        #Here i only use a fake RL control.
        #Here you may need to replace it using your RL control
        flow = RL_control(state_vars)
        print ("new control inputs: ", flow[0], " + ", flow[1], \
                " + ", flow[2], " + ", flow[3], " + ", flow[4], "\n" )        
        model_inputs = bop.inputs(siteid)
        #print ('model-inputs: ', model_inputs)
        
        #new_inputs must be dictionary format
        new_inputs["SA_FlowRate_Zone_Core_CMD"] = flow[0]
        new_inputs["SA_FlowRate_Zone_P1_CMD"] = flow[1]
        new_inputs["SA_FlowRate_Zone_P2_CMD"] = flow[2]
        new_inputs["SA_FlowRate_Zone_P3_CMD"] = flow[3]
        new_inputs["SA_FlowRate_Zone_P4_CMD"] = flow[4]
        

        bop.setInputs(siteid, new_inputs)
        
        
    time.sleep(5)

bop.stop_many(siteids)

