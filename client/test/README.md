1. The alfalfa/client/test of SimBuild2020 branch is where the model currently locates. </br> 
   The model name: RefBuildingSmallOffice2013_270.osm. </br>
2. The model for test is an OpenStudio Model, version 2.7, which will be 
   automatically updated by docker image (OpenStudio 2.8.1). </br> 
   It follows the ASHRAE 2013 building standard.</br>
3. The model for test is the Small-Office-Reference-Building, which has 5 
   thermal zones: Core_ZN, Perimeter_Zone1, Perimeter_Zone2, Perimeter_Zone3,
                  Perimeter_Zone4. </br>
4. The procedure to run the test file needs two terminals: </br>
   (1) on terminal-1, please specify below 3 commands sequentially: </br>
   ==> Docker-compose down </br>
   ==> Docker-compose build web worker </br>
   ==> Docker-compose up web worker </br>
 
   Then you need to wait until the model being uploaded to the localhost.</br>
   A good sign is you see words like: "Watchout". <br>

   (2) on terminal-2, after model is up, please run the test file: </br>
       ==> python osm-simbuild2.py </br>

   You will see the state variables and new-control-inputs displaying on the terminal. </br>
   
5. test file: osm-simbuild2.py </br>
   It specifies the starting time as 2019-11-06 7:30:00 (AM); </br>
   The ending time is 2019-11-06 17:30:00 (PM);  </br>
   The timestep is 1 minute. </br>
   The starting/ending time can be adjusted. Here were just use them to test the algorithm. </br>
   Because the building operation schedule starts from 8AM to 5PM. The HVAC system is not working before 8AM and after 5PM. </br>
   I am using a fake reinforcement learning control currently in the test. </br>
   You probably need to hookup the actual reinforcement learning control algorithm. </br> 
    Please let me know, if you need me to adjust the current calling architecture for RL_control. </br>
   The API to get the state variables is model_outputs["key"], where key is the carefully designed. Please see osm-simbuild2.py for details. </br>
   The API to give new control inputs is setInputs(). </br>
   The inputs need to be in dictionary format, where the key is also carefully designed. Please see osm-simbuild2.py for details. </br>

6. The upper lever logic of RL control:  </br>
   Each time step, the program is being advanced by API: advance();  </br>
   Then we get state variables, like zone mean air temperature, cooling/heating rate;  </br>
   Then we feed those state variables into RL, to get new control inputs; </br>
   Then we organize new control inputs into a dictionary, and send back to the model by setInputs(). </br>
   
7. Issues: currently the model can not output zone thermal comfort index, like PPD. </br>
   This is due to a bug in the EnergyPlus. I tried the version 9.1 and 9.2, both can not output PPD. </br>
   I already reported to EnergyPlus team. Hopefully next weeki can get some positive feedbacks. 

