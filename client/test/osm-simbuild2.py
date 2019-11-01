import sys
import os
thispath = os.path.dirname(os.path.abspath(__file__)) 
sys.path.append(thispath + '/../')
import boptest
import time

sys.path.insert(0, './controllers')

from controllers import pid

bop = boptest.Boptest(url='http://localhost')

osm_files = []
for _ in range(1):
    osm_files.append(thispath + '/SmallOffice.osm')

siteids = bop.submit_many(osm_files)
bop.start_many(siteids, external_clock = "true")

for i in range(3):
    print ("yanfei step: ", i)
    bop.advance(siteids)
    #total_rtu_power = 0.0
    for siteid in siteids:
        model_outputs = bop.inputs(siteid)
        print (model_outputs) 
        
    time.sleep(5)

bop.stop_many(siteids)

