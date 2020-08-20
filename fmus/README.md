# Building FMUs for Alfalfa/BOPTEST

* Build local docker container for running JModelica

```bash
cd {root_path}/client/rl-examples/fmus/local_docker
docker build -t local/jmodelica .
```

* Check out Modelica Buildings Library (https://github.com/lbl-srg/modelica-buildings)
* Export the MODELICAPATH (e.g., Linux: export MODELICAPATH=$MODELICAPATH:/files/checkout/modelica-buildings)
* Construct and test the model in Dymola using the .mo file
* Build the FMU using the following command. This will generate the wrapper.mo project that will be used which includes the KPIs JSON file.

```bash
cd {root_path}/client/rl-example/fmus/<package_to_build>
../jm_ipython.sh ../parser.py SingleZoneVAV.mo SingleZoneVAV.TestCaseSupervisory
```

* If desired, run the FMU to test that it works (Note that you must pass the path to the modelica model to build, not just the FMU filename)
```bash
../jm_ipython.sh ../jmodelica.py SingleZoneVAV.TestCaseSupervisory
```

* Now you can submit the wrapped.mo file to Alfalfa/BOPTEST!


# Notes / Issues

* The kpis.json file needs to be added to the FMU before it is uploaded to Alfalfa. The data_manager.py library is in the worker node, but it doesn't compile or wrap the FMU (Which it probably should). Needed to add generate and add kpi.json by updating the parser and data_manager python files.
* The data_manager requires the categories.json file, but again, it is in the worker node and is needed before submitting to Alfalfa.
* The _append_csv_data method in data_mananger.py needs to catch a not existent key

```
# Replace 
if appended[key] is not None:

# With
if key in appended and appended[key] is not None:
```
* The JModelica container in the worker uses Ubuntu 16.04, but the latest docker-ubuntu-jmodelica used 18.04. Need to update Worker. 
* Default JModelica container does not have pandas, needed to fork dockerfile for docker-ubuntu-jmodelica to install pandas
* Pandas requires a valid user, however, the default user in docker-ubuntu-jmodelica was not found. Removed user in docker run command.
* parser.py script uses a hard coded model (SimpleRC). Needed to add positional arguments (could not use argparse due to jm_ipython).

