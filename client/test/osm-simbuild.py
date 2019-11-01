import sys
import os
thispath = os.path.dirname(os.path.abspath(__file__)) 
sys.path.append(thispath + '/../')
import boptest 
import time
import datetime

sys.path.insert(0, './controllers')

from controllers import pid

start_time = datetime.datetime.now()
#start_time = time.time()
end_time = start_time + datetime.timedelta(minutes=10)
#print("end-time: ", end_time)

my_url = 'http://localhost'
osm_model= thispath + "/SmallOffice.osm"
time_scale =5 

bop = boptest.Boptest(url = my_url)

siteid = bop.submit(osm_model)

time_args={ "timescale":time_scale, "start_datetime":start_time, "end_datetime":end_time }

bop.start(siteid, **time_args)

bop.advance(siteid)

bop.stop(siteid)

