# insert your copyright here

# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/

# start the measure
class SimBuild20 < OpenStudio::Measure::ModelMeasure
  # human readable name
  def name
    # Measure name should be the title case of the class name.
    return 'SimBuild20'
  end

  # human readable description
  def description
    return 'This measure will tag the state variables and command variables, which are to be tagged by Haystack. The state variables are: zone mean air temprature, zone PPD, zone heating/cooling load. The command variables are: zone supply airflowrate, which is implemented by overwriting the fan mass flow rate.'
  end

  # human readable description of modeling approach
  def modeler_description
    return 'state variables are tagged into sensors; command variables are put into ExternalInterface:Variables, and tagged into CMDs'
  end

  def hyphen_replace(mystr)
     return mystr.gsub("-","_")
  end

  def braces_replace(mystr)
      str1=mystr.to_s.gsub("{","")
	  str2=str1.to_s.gsub("}","")
	  return str2
  end
  
  def create_uuid(dummyinput)
    return "r:#{OpenStudio.removeBraces(OpenStudio.createUUID)}"
  end
  
  def create_ref(id)
    #return string formatted for Ref (ie, "r:xxxxx") with uuid of object
    #return "r:#{id.gsub(/[\s-]/,'_')}"
    return "r:#{OpenStudio.removeBraces(id)}"
  end 
  
  def create_ref_name(id)
    #return string formatted for Ref (ie, "r:xxxxx") with uuid of object
    return "r:#{id.gsub(/[\s-]/,'_')}"
  end
  
  def create_str(str)
    #return string formatted for strings (ie, "s:xxxxx")
    return "s:#{str}"
  end
  
  def create_num(str)
    #return string formatted for numbers (ie, "n:xxxxx")
    return "n:#{str}"
  end
  
  def create_ems_str(id)
    #return string formatted with no spaces or '-' (can be used as EMS var name)
    return "#{id.gsub(/[\s-]/,'_')}"
  end

  def create_point_timevars(outvar_time, siteRef)
    #this function will add haystack tag to the time-variables created by user. 
    #the time-variables are also written to variables.cfg file to coupling energyplus
    #the uuid is unique to be used for mapping purpose
    #the point_json generated here caontains the tags for the tim-variables 
    point_json = Hash.new
    #id = outvar_time.keyValue.to_s + outvar_time.name.to_s
    uuid = create_uuid("")
    point_json[:id]=uuid
    #point_json[:source] = create_str("EnergyPlus")
    #point_json[:type] = "Output:Variable"
    #point_json[:name] = create_str(outvar_time.name.to_s)
    #point_json[:variable] = create_str(outvar_time.name)
    point_json[:dis] = create_str(outvar_time.nameString)
    point_json[:siteRef]=create_ref(siteRef)
    point_json[:point]="m:"
    point_json[:cur]="m:" 
    point_json[:curStatus] = "s:disabled"    

    return point_json, uuid
  end # end of create_point_timevar

  def create_mapping_timevars(outvar_time, uuid)
    #this function will use the uuid generated from create_point_timevars(), to make a mapping. 
    #the uuid is unique to be used for mapping purpose; uuid is the belt to connect point_json and mapping_json
    #the mapping_json below contains all the necessary tags
    mapping_json = Hash.new
    mapping_json[:id] = uuid
    mapping_json[:source] = "EnergyPlus"
    mapping_json[:name] = "EMS"
    mapping_json[:type] = outvar_time.nameString
    mapping_json[:variable] = ""
    

    return mapping_json
  end

  def create_point_simbuild(outvar_str, siteRef)
    #this function will add haystack tag to the time-variables created by user. 
    #the time-variables are also written to variables.cfg file to coupling energyplus
    #the uuid is unique to be used for mapping purpose
    #the point_json generated here caontains the tags for the tim-variables 
    point_json = Hash.new
    #id = outvar_time.keyValue.to_s + outvar_time.name.to_s
    uuid = create_uuid("")
    point_json[:id]=uuid
    #point_json[:source] = create_str("EnergyPlus")
    #point_json[:type] = "Output:Variable"
    #point_json[:name] = create_str(outvar_time.name.to_s)
    #point_json[:variable] = create_str(outvar_time.name)
    point_json[:dis] = create_str(outvar_str)
    point_json[:siteRef]=create_ref(siteRef)
    point_json[:point]="m:"
    point_json[:cur]="m:" 
    point_json[:curStatus] = "s:disabled"    

    return point_json, uuid
  end # end of create_point_timevar
  

  def create_point_uuid(type, id, siteRef, equipRef, floorRef, where,what,measurement,kind,unit)
    point_json = Hash.new
    uuid = create_uuid(id)
    point_json[:id] = uuid
    point_json[:dis] = create_str(id)
    point_json[:siteRef] = create_ref(siteRef)
    point_json[:equipRef] = create_ref(equipRef)
    point_json[:floorRef] = create_ref(floorRef)
    point_json[:point] = "m:"
    point_json["#{type}"] = "m:"
    point_json["#{measurement}"] = "m:"   
    point_json["#{where}"] = "m:" 
    point_json["#{what}"] = "m:" 
    point_json[:kind] = create_str(kind) 
    point_json[:unit] = create_str(unit) 
    point_json[:cur] = "m:" 
    point_json[:curStatus] = "s:disabled" 
    return point_json, uuid
  end
  
  def create_point2_uuid(type, type2, id, siteRef, equipRef, floorRef, where,what,measurement,kind,unit)
    point_json = Hash.new
    uuid = create_uuid(id)
    point_json[:id] = uuid
    point_json[:dis] = create_str(id)
    point_json[:siteRef] = create_ref(siteRef)
    point_json[:equipRef] = create_ref(equipRef)
    point_json[:floorRef] = create_ref(floorRef)
    point_json[:point] = "m:"
    point_json["#{type}"] = "m:"
    point_json["#{type2}"] = "m:"
    point_json["#{measurement}"] = "m:"   
    point_json["#{where}"] = "m:" 
    point_json["#{what}"] = "m:" 
    point_json[:kind] = create_str(kind) 
    point_json[:unit] = create_str(unit) 
    point_json[:cur] = "m:" 
    point_json[:curStatus] = "s:disabled" 
    return point_json, uuid
  end
  
  def create_controlpoint2(type, type2, id, uuid, siteRef, equipRef, floorRef, where,what,measurement,kind,unit)
    point_json = Hash.new
    point_json[:id] = create_ref(uuid)
    point_json[:dis] = create_str(id)
    point_json[:siteRef] = create_ref(siteRef)
    point_json[:equipRef] = create_ref(equipRef)
    point_json[:floorRef] = create_ref(floorRef)
    point_json[:point] = "m:"
    point_json["#{type}"] = "m:"
    point_json["#{type2}"] = "m:"
    point_json["#{measurement}"] = "m:"   
    point_json["#{where}"] = "m:" 
    point_json["#{what}"] = "m:" 
    point_json[:kind] = create_str(kind) 
    point_json[:unit] = create_str(unit) 
    if type2 == "writable"
      point_json[:writeStatus] = "s:ok" 
    end
    return point_json
  end
  
  def create_controlpoint_simbuild(type2, id, uuid, siteRef, where,what,measurement,kind,unit)
    point_json = Hash.new
    point_json[:id] = create_ref(uuid)
    point_json[:dis] = create_str(id)
    point_json[:siteRef] = create_ref(siteRef)
    point_json[:point] = "m:"
    point_json["#{type2}"] = "m:"
    point_json["#{measurement}"] = "m:"   
    point_json["#{where}"] = "m:" 
    point_json["#{what}"] = "m:" 
    point_json[:kind] = create_str(kind) 
    point_json[:unit] = create_str(unit) 
    if type2 == "writable"
      point_json[:writeStatus] = "s:ok" 
    end
    return point_json
  end
  
  
  def create_fan(id, name, siteRef, equipRef, floorRef, variable)
    point_json = Hash.new
    point_json[:id] = create_ref(id)
    point_json[:dis] = create_str(name)
    point_json[:siteRef] = create_ref(siteRef)
    point_json[:equipRef] = create_ref(equipRef)
    point_json[:floorRef] = create_ref(floorRef)
    point_json[:equip] = "m:"
    point_json[:fan] = "m:"
    if variable
      point_json[:vfd] = "m:"
      point_json[:variableVolume] = "m:"
    else
      point_json[:constantVolume] = "m:"
    end     
    return point_json
  end

  def create_ahu(id, name, siteRef, floorRef)
    ahu_json = Hash.new
    ahu_json[:id] = create_ref(id)
    ahu_json[:dis] = create_str(name)
    ahu_json[:ahu] = "m:"
    ahu_json[:hvac] = "m:"
    ahu_json[:equip] = "m:"
    ahu_json[:siteRef] = create_ref(siteRef)
    ahu_json[:floorRef] = create_ref(floorRef)
    return ahu_json
  end  
  
  def create_vav(id, name, siteRef, equipRef, floorRef)
    vav_json = Hash.new
    vav_json[:id] = create_ref(id)
    vav_json[:dis] = create_str(name)
    vav_json[:hvac] = "m:"
    vav_json[:vav] = "m:"
    vav_json[:equip] = "m:"
    vav_json[:equipRef] = create_ref(equipRef)
    vav_json[:ahuRef] = create_ref(equipRef)
    vav_json[:siteRef] = create_ref(siteRef)
    vav_json[:floorRef] = create_ref(floorRef)
    return vav_json
  end
  
  def create_mapping_output_uuid(emsName, uuid)
    json = Hash.new
    json[:id] = create_ref(uuid)
    json[:source] = "Ptolemy" 
    json[:name] = ""
    json[:type] = ""
    json[:variable] = emsName
    return json
  end
  
  def create_EMS_sensor_bcvtb(outVarName, key, emsName, uuid, report_freq, model)
    outputVariable = OpenStudio::Model::OutputVariable.new(outVarName,model)
    outputVariable.setKeyValue("#{key.name.to_s}")
    outputVariable.setReportingFrequency(report_freq) 
    outputVariable.setName(outVarName)
    outputVariable.setExportToBCVTB(true)
    
    sensor = OpenStudio::Model::EnergyManagementSystemSensor.new(model, outputVariable)
    sensor.setKeyName(key.handle.to_s)
    sensor.setName(create_ems_str(emsName))
    
    json = Hash.new
    json[:id] = uuid 
    json[:source] = "EnergyPlus" 
    json[:type] = outVarName
    json[:name] = key.name.to_s
    json[:variable] = ""
    return sensor, json
  end
  
  #will get deprecated by 'create_EMS_sensor_bcvtb' once Master Algo debugged (dont clutter up the json's with unused points right now)
  def create_EMS_sensor(outVarName, key, emsName, report_freq, model)
    outputVariable = OpenStudio::Model::OutputVariable.new(outVarName,model)
    outputVariable.setKeyValue("#{key.name.to_s}")
    outputVariable.setReportingFrequency(report_freq) 
    outputVariable.setName(outVarName)
    sensor = OpenStudio::Model::EnergyManagementSystemSensor.new(model, outputVariable)
    sensor.setKeyName(key.handle.to_s)
    sensor.setName(create_ems_str(emsName))
    return sensor
  end
  
  # define the arguments that the user will input
  def arguments(model)
    args = OpenStudio::Ruleset::OSArgumentVector.new
    
    local_test = OpenStudio::Ruleset::OSArgument::makeBoolArgument("local_test", false)
    local_test.setDisplayName("Local Test")
    local_test.setDescription("Use EMS for Local Testing")
    local_test.setDefaultValue(false)
    args << local_test
    
    return args
  end



  # define what happens when the measure is run
  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)

    # Use the built-in error checking 
    if not runner.validateUserArguments(arguments(model), user_arguments)
      return false
    end   

    local_test = runner.getBoolArgumentValue("local_test",user_arguments) 
    runner.registerInfo("local_test = #{local_test}")
    
    #initialize variables
    haystack_json = []
    mapping_json = []
	
    #Global Vars
    report_freq = "timestep"
    runner.registerInitialCondition("starting the measure SimBuild20") 
    
    ###############################################################################################################################
    #########################       Open up the EMS:ReportingVariables to       #############################
    #########################       get a list of available EMS actuators        #############################
    ###############################################################################################################################
    report_edd = model.getOutputEnergyManagementSystem
    #puts report_edd.inspect

    report_edd.setActuatorAvailabilityDictionaryReporting("Verbose")
    report_edd.setInternalVariableAvailabilityDictionaryReporting("None")
    report_edd.setEMSRuntimeLanguageDebugOutputLevel("None")
    #print report_edd
	
    externalInterface = model.getExternalInterface
    #puts externalInterface.inspect

    externalInterface.setNameofExternalInterface("PtolemyServer")
	
    ###############################################################################################################################
    #########################       get building basic information       #############################
    #########################       into Haystack points       #############################
    ###############################################################################################################################
    #Site and WeatherFile Data
    if model.weatherFile.is_initialized 
      puts model.weatherFile.is_initialized

      site_json = Hash.new
      weather_json = Hash.new
      floor_json = Hash.new
      
      wf = model.weatherFile.get
      building = model.getBuilding
      
      site_json[:id] = create_ref(building.handle)
      site_json[:dis] = create_str(building.name.to_s)
      site_json[:site] = "m:"
      site_json[:area] = create_num(building.floorArea)
      site_json[:weatherRef] = create_ref(wf.handle)
      site_json[:tz] = create_num(wf.timeZone)
      site_json[:geoCity] = create_str(wf.city)
      site_json[:geoState] = create_str(wf.stateProvinceRegion)
      site_json[:geoCountry] = create_str(wf.country)
      site_json[:geoCoord] = "c:#{wf.latitude},#{wf.longitude}"
      site_json[:simStatus] = "s:Stopped"
      site_json[:simType] = "s:osm"
      haystack_json << site_json
            
      weather_json[:id] = create_ref(wf.handle)
      weather_json[:dis] = create_str(wf.city)
      weather_json[:weather] = "m:"
      weather_json[:tz] = create_num(wf.timeZone)
      weather_json[:geoCoord] = "c:#{wf.latitude},#{wf.longitude}"
      haystack_json << weather_json    
      
      #floor tag
      simCon = model.getSimulationControl  #use this for now until floors are defined
      floor_json[:id] = create_ref(simCon.handle)
      floor_json[:dis] = create_str("floor discription")
      floor_json[:floor] = "m:"   
      haystack_json << floor_json      
    end
	
	###############################################################################################################################
	#########################       put state-variables into Output:Variables        #############################
	#########################       which will be tagged as haystack-sensors                 #############################
	###############################################################################################################################
	
    model.getThermalZones.each do |tz|
      zonename = tz.name.to_s
  
      if zonename =="Core_ZN ZN" or zonename =="Perimeter_ZN_1 ZN" or zonename =="Perimeter_ZN_2 ZN" or zonename =="Perimeter_ZN_3 ZN" or zonename =="Perimeter_ZN_4 ZN"
	  
	    temperature_sensor, temperature_json = create_EMS_sensor_bcvtb("Zone Mean Air Temperature", tz, zonename+" temp sensor", create_uuid("dummy"), "Timestep", model)	
	    mapping_json << temperature_json
	  
	    #ppd_sensor, ppd_json = create_EMS_sensor_bcvtb("Zone Thermal Comfort Fanger Model PPD", tz, zonename+" ppd sensor", create_uuid("dummy"), "Timestep", model)	
	    #mapping_json << ppd_json
		
	    heating_sensor, heating_json = create_EMS_sensor_bcvtb("Zone Air System Sensible Heating Rate", tz, zonename+" heatingE sensor", create_uuid("dummy"), "Timestep", model)	
	    mapping_json << heating_json
		
	    cooling_sensor, cooling_json = create_EMS_sensor_bcvtb("Zone Air System Sensible Cooling Rate", tz, zonename+" coolingE sensor", create_uuid("dummy"), "Timestep", model)	
	    mapping_json << cooling_json
		

      end
    end
		
		
		

	
	###############################################################################################################################
	#########################       Create SAflow Commands/Actuators in Haystack,       #############################
	#########################         which are from ExternalInterfaceVariables         #############################
	###############################################################################################################################
    #ExternalInterfaceVariables: supply_air_flow_rate command
	supply_air_flow_zone_core_cmd = create_ems_str("SA FlowRate Zone Core CMD")
	supply_air_flow_zone_p1_cmd = create_ems_str("SA FlowRate Zone P1 CMD")
	supply_air_flow_zone_p2_cmd = create_ems_str("SA FlowRate Zone P2 CMD")
	supply_air_flow_zone_p3_cmd = create_ems_str("SA FlowRate Zone P3 CMD")
	supply_air_flow_zone_p4_cmd = create_ems_str("SA FlowRate Zone P4 CMD")

	
	zone_core_sa_var = OpenStudio::Model::ExternalInterfaceVariable.new(model, supply_air_flow_zone_core_cmd, 0.1)
	zone_core_sa_var.setExportToBCVTB(true)
	zone_p1_sa_var = OpenStudio::Model::ExternalInterfaceVariable.new(model, supply_air_flow_zone_p1_cmd, 0.1)
	zone_p1_sa_var.setExportToBCVTB(true)
	zone_p2_sa_var = OpenStudio::Model::ExternalInterfaceVariable.new(model, supply_air_flow_zone_p2_cmd, 0.1)
	zone_p2_sa_var.setExportToBCVTB(true)
	zone_p3_sa_var = OpenStudio::Model::ExternalInterfaceVariable.new(model, supply_air_flow_zone_p3_cmd, 0.1)
	zone_p3_sa_var.setExportToBCVTB(true)
	zone_p4_sa_var = OpenStudio::Model::ExternalInterfaceVariable.new(model, supply_air_flow_zone_p4_cmd, 0.1)
	zone_p4_sa_var.setExportToBCVTB(true)

	mapping_json << create_mapping_output_uuid(supply_air_flow_zone_core_cmd, zone_core_sa_var.handle)
	mapping_json << create_mapping_output_uuid(supply_air_flow_zone_p1_cmd, zone_p1_sa_var.handle)
	mapping_json << create_mapping_output_uuid(supply_air_flow_zone_p2_cmd, zone_p2_sa_var.handle)
	mapping_json << create_mapping_output_uuid(supply_air_flow_zone_p3_cmd, zone_p3_sa_var.handle)
	mapping_json << create_mapping_output_uuid(supply_air_flow_zone_p4_cmd, zone_p4_sa_var.handle)

	
	#zone sa haystack point	as actuator
	haystack_zone_core_sa_json = create_controlpoint_simbuild("writable", supply_air_flow_zone_core_cmd, zone_core_sa_var.handle, building.handle,  "where", "what", "measurement", "Number", "kg/s")
	haystack_zone_p1_sa_json = create_controlpoint_simbuild("writable", supply_air_flow_zone_p1_cmd, zone_p1_sa_var.handle, building.handle,  "where", "what", "measurement", "Number", "kg/s")
	haystack_zone_p2_sa_json = create_controlpoint_simbuild("writable", supply_air_flow_zone_p2_cmd, zone_p2_sa_var.handle, building.handle,  "where", "what", "measurement", "Number", "kg/s")
	haystack_zone_p3_sa_json = create_controlpoint_simbuild("writable", supply_air_flow_zone_p3_cmd, zone_p3_sa_var.handle, building.handle,  "where", "what", "measurement", "Number", "kg/s")
	haystack_zone_p4_sa_json = create_controlpoint_simbuild("writable", supply_air_flow_zone_p4_cmd, zone_p4_sa_var.handle, building.handle,  "where", "what", "measurement", "Number", "kg/s")

	
	haystack_json << haystack_zone_core_sa_json
	haystack_json << haystack_zone_p1_sa_json
	haystack_json << haystack_zone_p2_sa_json
	haystack_json << haystack_zone_p3_sa_json
	haystack_json << haystack_zone_p4_sa_json
	
	
	################################################################################################################################
	#########################       get Fan from AirLoopHVACs which is used as EMS actuator             ############################
	#########################       to overwrite the zone SA flow, through EMS                          #############################
	################################################################################################################################

    model.getFanOnOffs.each do |fan|
          fan_name = fan.name.to_s
	  #print fan_name
	  zone_sa_actuator = OpenStudio::Model::EnergyManagementSystemActuator.new(fan,"Fan","Fan Air Mass Flow Rate") 
	  zone_sa_actuator.setName(create_ems_str("#{hyphen_replace(fan_name)} actuator"))
	  
	  program = OpenStudio::Model::EnergyManagementSystemProgram.new(model)
	  program.setName("SAFlow_Prgm_#{hyphen_replace(fan_name)}")
	  if fan_name == "Core_ZN ZN PSZ-AC-1 Fan"
	    program.addLine("SET #{zone_sa_actuator.handle.to_s} = #{supply_air_flow_zone_core_cmd}")	
          elsif fan_name == "Perimeter_ZN_1 ZN PSZ-AC-2 Fan"	
            program.addLine("SET #{zone_sa_actuator.handle.to_s} = #{supply_air_flow_zone_p1_cmd}")	
          elsif fan_name == "Perimeter_ZN_2 ZN PSZ-AC-3 Fan"	
            program.addLine("SET #{zone_sa_actuator.handle.to_s} = #{supply_air_flow_zone_p2_cmd}")
          elsif fan_name == "Perimeter_ZN_3 ZN PSZ-AC-4 Fan"	
            program.addLine("SET #{zone_sa_actuator.handle.to_s} = #{supply_air_flow_zone_p3_cmd}")
          elsif fan_name == "Perimeter_ZN_4 ZN PSZ-AC-5 Fan"	
            program.addLine("SET #{zone_sa_actuator.handle.to_s} = #{supply_air_flow_zone_p4_cmd}")
          else
            print ()
          end		
	  #EMS program calling manager
	  pcm = OpenStudio::Model::EnergyManagementSystemProgramCallingManager.new(model)
	  pcm.setName("SAFlow_Prgm_Mgr_#{ hyphen_replace(fan_name) }")
	  pcm.setCallingPoint("AfterPredictorAfterHVACManagers")
	  pcm.addProgram(program)
	
    end
	
	
	
    ################################################################################################################################
	#########################       Create Setpoint Commands/Actuators in Haystack,    #############################
    ######################### 	which are also from ExternalInterfaceVariables         #############################
	################################################################################################################################
	#ExternalInterfaceVariables: heating/cooling setpoint command
	heating_setpoint_cmd = create_ems_str("Heating Setpoint CMD")
    cooling_setpoint_cmd = create_ems_str("Cooling Setpoint CMD")
    heating_sp_var = OpenStudio::Model::ExternalInterfaceVariable.new(model, heating_setpoint_cmd, 24)
	heating_sp_var.setExportToBCVTB(true)
	cooling_sp_var = OpenStudio::Model::ExternalInterfaceVariable.new(model, cooling_setpoint_cmd, 28)
	cooling_sp_var.setExportToBCVTB(true)
	mapping_json << create_mapping_output_uuid(heating_setpoint_cmd, heating_sp_var.handle)
	mapping_json << create_mapping_output_uuid(cooling_setpoint_cmd, cooling_sp_var.handle)
	heating_sp_json = create_controlpoint_simbuild("writable", heating_setpoint_cmd, heating_sp_var.handle, building.handle,  "where", "what", "measurement", "Number", "Celsius")
	cooling_sp_json = create_controlpoint_simbuild("writable", cooling_setpoint_cmd, cooling_sp_var.handle, building.handle,  "where", "what", "measurement", "Number", "Celsius")
	haystack_json << heating_sp_json
	haystack_json << cooling_sp_json
	
			
    ################################################################################################################################
	#########################       Create Heating/Cooling Setpoint Constant Schedules,                     #############################
	#########################       which is to be used in EMS                      #############################
	################################################################################################################################
	
	heating_sch = OpenStudio::Model::ScheduleConstant.new(model)
	heating_sch.setName("Heating SP")	
	heating_sch.setValue(24)

	cooling_sch = OpenStudio::Model::ScheduleConstant.new(model)
	cooling_sch.setName("Cooling SP")
	cooling_sch.setValue(28)
	
	################################################################################################################################
	#########################       set the thermostat setpoint to the                     #############################
	#########################       constant setpoint i created                    #############################
	################################################################################################################################
	model.getThermostatSetpointDualSetpoints.each do |tsp|
	  xh=tsp.heatingSetpointTemperatureSchedule() 
	  if xh
	    tsp.setHeatingSetpointTemperatureSchedule(heating_sch)
	  end
	  xc = tsp.coolingSetpointTemperatureSchedule() 
	  if xc
	    tsp.setCoolingSetpointTemperatureSchedule(cooling_sch)
	  end
	end
	
	
	################################################################################################################################
	#########################       Create EMS for heating/cooling setpoints,                     #############################
	#########################       which is overwritten by Haystack commands                    #############################
	################################################################################################################################
	heating_sp_actuator = OpenStudio::Model::EnergyManagementSystemActuator.new(heating_sch,"Schedule:Constant","Schedule Value") 
	heating_sp_actuator.setName(create_ems_str("heating setpoint actuator"))
	program = OpenStudio::Model::EnergyManagementSystemProgram.new(model)
	program.setName("Prgm_Heating_Setpoint")
	program.addLine("SET #{heating_sp_actuator.handle.to_s} = #{heating_setpoint_cmd}")
	pcm = OpenStudio::Model::EnergyManagementSystemProgramCallingManager.new(model)
	pcm.setName("Prgm_Mgr_Heating_Setpoint")
	pcm.setCallingPoint("AfterPredictorAfterHVACManagers")
	pcm.addProgram(program)

	cooling_sp_actuator = OpenStudio::Model::EnergyManagementSystemActuator.new(cooling_sch,"Schedule:Constant","Schedule Value") 
	cooling_sp_actuator.setName(create_ems_str("cooling setpoint actuator"))
	program = OpenStudio::Model::EnergyManagementSystemProgram.new(model)
	program.setName("Prgm_Cooling_Setpoint")
	program.addLine("SET #{cooling_sp_actuator.handle.to_s} = #{cooling_setpoint_cmd}")
	pcm = OpenStudio::Model::EnergyManagementSystemProgramCallingManager.new(model)
	pcm.setName("Prgm_Mgr_Cooling_Setpoint")
	pcm.setCallingPoint("AfterPredictorAfterHVACManagers")
	pcm.addProgram(program)
	
	################################################################################################################################
	#########################       wake up Fanger model for People Modules                      #############################
	#########################                           #############################
	################################################################################################################################	    	
    people_defs = model.getPeopleDefinitions
    people_defs.sort.each do |people_def|
	  people_def.setThermalComfortModelType(0, 'FANGER')
    end
	
    ################################################################################################################################
	#########################      create sensors for output variables                    #############################
	#########################                           #############################
	################################################################################################################################
    building = model.getBuilding
    output_vars = model.getOutputVariables
    output_vars.each do |outvar|
      
      if outvar.exportToBCVTB
        uuid = create_ref(outvar.handle)

        var_haystack_json = Hash.new
        var_haystack_json[:id] = uuid
        var_haystack_json[:dis] = create_str(outvar.keyValue + "_"+ outvar.variableName)
        var_haystack_json[:siteRef] = create_ref(building.handle)
        var_haystack_json[:point]="m:"
        var_haystack_json[:cur]="m:" 
        var_haystack_json[:curStatus] = "s:disabled"
        haystack_json << var_haystack_json

        var_map_json = Hash.new
        var_map_json[:id] = uuid
        var_map_json[:source] = "EnergyPlus"
        var_map_json[:type] = outvar.variableName
        var_map_json[:name] = outvar.keyValue
        var_map_json[:variable] = ""
        mapping_json << var_map_json
      end
    end
	
    
		  
		  
    runner.registerFinalCondition("The building has applied the Simbuild20 Measure") 
	
	################################################################################################################################
	#########################       write all haystack points                      #############################
	#########################       to a json file                    #############################
	################################################################################################################################
    #write out the haystack json
    File.open("./report_haystack.json","w") do |f|
      f.write(haystack_json.to_json)
    end
    #write out the mapping json
    File.open("./report_mapping.json","w") do |f|
      f.write(mapping_json.to_json)
    end
	
    return true

  end    #end of the Run
end # end of the Class

# register the measure to be used by the application
SimBuild20.new.registerWithApplication
