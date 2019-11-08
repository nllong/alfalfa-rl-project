import sys
import os
thispath = os.path.dirname(os.path.abspath(__file__)) 
sys.path.append(thispath + '/../')
import boptest
import time

def RL_control(temp):
    flow = []
    for i in range(len(temp)):
        flow.append(1.5)
    
    return flow

sys.path.insert(0, './controllers')

from controllers import pid

bop = boptest.Boptest(url='http://localhost')

osm_files = []
for _ in range(1):
    osm_files.append(thispath + '/RefBuildingSmallOffice2013_270.osm')

siteids = bop.submit_many(osm_files)
bop.start_many(siteids, external_clock = "true")

new_inputs = {}
state_vars=[]
for i in range(10):
    print ("yanfei step: ", i)
    bop.advance(siteids)
    
    for siteid in siteids:
        model_outputs = bop.outputs(siteid)
        print ('model-outputs: ', model_outputs)
        
        '''
        temp1 = model_outputs["Sensor"]
        temp2 = model_outputs["Sensor"]
        state_vars.append(temp1)
        state_vars.append(temp2)

        #Here i only use a fake RL control.
        #Here you may need to replace it using your RL control
        flow = RL_control(state_vars)
        '''
        
        model_inputs = bop.inputs(siteid)
        print ('model-inputs: ', model_inputs)
        '''
        #new_inputs must be dictionary format
        new_inputs["SA_FlowRate_Zone_P1_CMD"] = flow[0]
        new_inputs["SA_FlowRate_Zone_P2_CMD"] = flow[1]

        bop.setInputs(siteid, new_inputs)
        '''
        
    time.sleep(5)

bop.stop_many(siteids)

