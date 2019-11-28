To rebuild the FMU:

* Install https://github.com/lbl-srg/docker-ubuntu-jmodelica
* Make sure to configure the correct path to Modelica Buildings Library **and** the path to the jm_ipython.sh script
* Make sure to configure the correct path to Modelica Buildings Library
* Build the model in dymola using the .mo file
* Run the following command (Note that you must pass the path to the modelica model to build, not just the FMU filename)

```bash
cd <model-to-build>
jm_ipython.sh ../jmodelica.py SingleZoneVAV.TestCaseSupervisory
```
