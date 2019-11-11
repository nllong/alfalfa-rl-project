1. The alfalfa/client/test of SimBuild2020 branch is where the model currently locates.\ 
   The model name: RefBuildingSmallOffice2013_270.osm. \
2. The model for test is an OpenStudio Model, version 2.7, which will be 
   automatically updated by docker image (OpenStudio 2.8.1). \ 
   It follows the ASHRAE 2013 building standard.\
3. The model for test is the Small-Office-Reference-Building, which has 5 \
   thermal zones: Core_ZN, Perimeter_Zone1, Perimeter_Zone2, Perimeter_Zone3,
                  Perimeter_Zone4. 
4. The procedure to run the test file needs two terminals: \
   (1) on terminal-1, please specify below 3 commands sequentially: \
   ==> Docker-compose down \
   ==> Docker-compose build web worker \
   ==> Docker-compose up web worker \
 
   Then you need to wait until the model being uploaded to the localhost.\
   A good sign is you see words like: "Watchout" \

   (2) on terminal-2, after model is up, please run the test file: \
       ==> python osm-simbuild2.py \

   You will see the state variables and new-control-inputs displaying on the terminal. \
   
5. test file: osm-simbuild2.py \
   It specifies the starting time as 2019-11-06 7:30:00 (AM); \
   The ending time is 2019-11-06 17:30:00 (PM);  \
   The timestep is 1 minute. \
   The starting/ending time can be adjusted. Here were just use them to test the algorithm.\ 
   Because the building operation schedule starts from 8AM to 5PM. The HVAC system is not working before 8AM and after 5PM. \
   I am using a fake reinforcement learning control currently in the test. \
   You probably need to hookup the actual reinforcement learning control algorithm. \ Please let me know, if you need me to adjust the current calling architecture for RL_control. \
   The API to get the state variables is model_outputs["key"], where key is the carefully designed. Please see osm-simbuild2.py for details. \
   The API to give new control inputs is setInputs(). \
   The inputs need to be in dictionary format, where the key is also carefully designed. Please see osm-simbuild2.py for details. \

6. The upper lever logic of RL control:  \
   Each time step, the program is being advanced by API: advance();  \
   Then we get state variables, like zone mean air temperature, cooling/heating rate;  \
   Then we feed those state variables into RL, to get new control inputs; \
   Then we organize new control inputs into a dictionary, and send back to the model by setInputs(). \
   
7. Issues: currently the model can not output zone thermal comfort index, like PPD. \
   This is due to a bug in the EnergyPlus. I tried the version 9.1 and 9.2, both can not output PPD. \
   I already reported to EnergyPlus team. Hopefully next weeki can get some positive feedbacks. 

