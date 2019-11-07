import sys
import os
thispath = os.path.dirname(os.path.abspath(__file__)) 
sys.path.append(thispath + '/../')
import boptest 
import time
import datetime
import random

sys.path.insert(0, './controllers')

from controllers import pid

def RL_control(temp):
    flow = []
    for i in range(len(temp)):
        flow.append( 1.5 + random.random()  )

    return flow


start_time = datetime.datetime.now()

#assume we are doing 60 min simulation
simu_length = datetime.timedelta(minutes=60)

end_time = start_time + simu_length
simu_steps = int(simu_length.total_seconds() / 60.0) # number of time steps, of which each timestep is 1 minute
print("Yanfei steps: ", simu_steps)

my_url = 'http://localhost'
osm_model= thispath + "/SmallOffice.osm"
time_scale =5 

bop = boptest.Boptest(url = my_url)

siteid = bop.submit(osm_model)

time_args={ "timescale":time_scale, "start_datetime":start_time, "end_datetime":end_time }

bop.start(siteid, **time_args)
state_vars=[]
new_inputs={}
for i in range(simu_steps):
    print("\n Yanfei u r on step ", i, "\n")
    bop.advance(siteid)
    model_outputs = bop.outputs(siteid)
    #print (model_outputs)

    temp1 = model_outputs["Packaged Rooftop Air Conditioner 1 Mixed Air Temp Sensor"]
    temp2 = model_outputs["Packaged Rooftop Air Conditioner 2 Mixed Air Temp Sensor"]
    state_vars.append(temp1)
    state_vars.append(temp2)
    #Here i only use a fake RL control.
    #Here you may need to replace it using your RL control
    flow = RL_control(state_vars)
    model_inputs = bop.inputs(siteid)

    #new_inputs must be dictionary format
    new_inputs["SA_FlowRate_Zone_1_CMD"] = flow[0]
    new_inputs["SA_FlowRate_Zone_2_CMD"] = flow[1]
    print ("state vars: ", state_vars, "; new inputs: ", new_inputs)

    bop.setInputs(siteid, new_inputs)
    
    time.sleep(5)


bop.stop(siteid)

