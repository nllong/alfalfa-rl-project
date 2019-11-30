# insert your copyright here

# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/

# start the measure
class AddAlfalfaForPSZ < OpenStudio::Measure::ModelMeasure
  # human readable name
  def name
    # Measure name should be the title case of the class name.
    return 'Add Alfalfa for PSZ'
  end

  # human readable description
  def description
    return 'Add in Alfalfa controllers for PSZ'
  end

  # human readable description of modeling approach
  def modeler_description
    return ''
  end

  # define the arguments that the user will input
  def arguments(model)
    args = OpenStudio::Measure::OSArgumentVector.new

    return args
  end

  # define what happens when the measure is run
  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)

    # use the built-in error checking
    if !runner.validateUserArguments(arguments(model), user_arguments)
      return false
    end

    runner.registerInitialCondition("Starting to add variables for Alfalfa")

    # These were taken from Yanfei's measure that was embedded into Alfalfa. I moved them to
    # a measure in order to keep alfalfa's haystack measure clean.

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

    def create_EMS_sensor_bcvtb(outVarName, key, emsName, uuid, report_freq, model)

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


    zone_outputs = [
        'Zone Mean Air Temperature',
        'Zone Mean Radiant Temperature',
        'Zone Air System Sensible Heating Rate',
        'Zone Air System Sensible Cooling Rate'
    ]
    model.getThermalZones.each do |zone|
      # ignore attics
      next if zone.name.get =~ /attic/i

      zone_outputs.each do |zone_output|
        outputVariable = OpenStudio::Model::OutputVariable.new(zone_output, model)
        outputVariable.setKeyValue(zone.name.get)
        outputVariable.setReportingFrequency('timestep')
        outputVariable.setName("#{zone.name.get}_#{zone_output}")
        outputVariable.setExportToBCVTB(true)
        runner.registerInfo("Adding output variable for #{outputVariable.variableName}.")
      end
    end



    # ###############################################################################################################################
    # #########################       Create SAflow Commands/Actuators in Haystack,       #############################
    # #########################         which are from ExternalInterfaceVariables         #############################
    # ###############################################################################################################################
    # #ExternalInterfaceVariables: supply_air_flow_rate command
    # supply_air_flow_zone_core_cmd = create_ems_str("SA FlowRate Zone Core CMD")
    # supply_air_flow_zone_p1_cmd = create_ems_str("SA FlowRate Zone P1 CMD")
    # supply_air_flow_zone_p2_cmd = create_ems_str("SA FlowRate Zone P2 CMD")
    # supply_air_flow_zone_p3_cmd = create_ems_str("SA FlowRate Zone P3 CMD")
    # supply_air_flow_zone_p4_cmd = create_ems_str("SA FlowRate Zone P4 CMD")
    #
    # model.getFanOnOffs.each do |fan|
    #   fan_name = fan.name.to_s
    #   if fan_name == "Core_ZN ZN PSZ-AC-1 Fan"
    #     #zone_core_sa_var = OpenStudio::Model::ExternalInterfaceVariable.new(model, supply_air_flow_zone_core_cmd, 0.1)
    #     zone_core_sa_var = OpenStudio::Model::ExternalInterfaceActuator.new(fan,"Fan","Fan Air Mass Flow Rate")
    #     zone_core_sa_var.setExportToBCVTB(true)
    #     zone_core_sa_var.setOptionalInitialValue(0.1)
    #     zone_core_sa_var.setName(supply_air_flow_zone_core_cmd.to_s)
    #     mapping_json << create_mapping_output_uuid(supply_air_flow_zone_core_cmd, zone_core_sa_var.handle)
    #     haystack_zone_core_sa_json = create_controlpoint_simbuild("writable", supply_air_flow_zone_core_cmd, zone_core_sa_var.handle, building.handle,  "where", "what", "measurement", "Number", "kg/s")
    #     haystack_json << haystack_zone_core_sa_json
    #   end
    # end
    #
    # zone_p1_sa_var = OpenStudio::Model::ExternalInterfaceVariable.new(model, supply_air_flow_zone_p1_cmd, 0.1)
    # zone_p1_sa_var.setExportToBCVTB(true)
    # zone_p2_sa_var = OpenStudio::Model::ExternalInterfaceVariable.new(model, supply_air_flow_zone_p2_cmd, 0.1)
    # zone_p2_sa_var.setExportToBCVTB(true)
    # zone_p3_sa_var = OpenStudio::Model::ExternalInterfaceVariable.new(model, supply_air_flow_zone_p3_cmd, 0.1)
    # zone_p3_sa_var.setExportToBCVTB(true)
    # zone_p4_sa_var = OpenStudio::Model::ExternalInterfaceVariable.new(model, supply_air_flow_zone_p4_cmd, 0.1)
    # zone_p4_sa_var.setExportToBCVTB(true)
    #
    #
    # mapping_json << create_mapping_output_uuid(supply_air_flow_zone_p1_cmd, zone_p1_sa_var.handle)
    # mapping_json << create_mapping_output_uuid(supply_air_flow_zone_p2_cmd, zone_p2_sa_var.handle)
    # mapping_json << create_mapping_output_uuid(supply_air_flow_zone_p3_cmd, zone_p3_sa_var.handle)
    # mapping_json << create_mapping_output_uuid(supply_air_flow_zone_p4_cmd, zone_p4_sa_var.handle)
    #
    #
    # #zone sa haystack point	as actuator
    #
    # haystack_zone_p1_sa_json = create_controlpoint_simbuild("writable", supply_air_flow_zone_p1_cmd, zone_p1_sa_var.handle, building.handle,  "where", "what", "measurement", "Number", "kg/s")
    # haystack_zone_p2_sa_json = create_controlpoint_simbuild("writable", supply_air_flow_zone_p2_cmd, zone_p2_sa_var.handle, building.handle,  "where", "what", "measurement", "Number", "kg/s")
    # haystack_zone_p3_sa_json = create_controlpoint_simbuild("writable", supply_air_flow_zone_p3_cmd, zone_p3_sa_var.handle, building.handle,  "where", "what", "measurement", "Number", "kg/s")
    # haystack_zone_p4_sa_json = create_controlpoint_simbuild("writable", supply_air_flow_zone_p4_cmd, zone_p4_sa_var.handle, building.handle,  "where", "what", "measurement", "Number", "kg/s")
    #
    # haystack_json << haystack_zone_p1_sa_json
    # haystack_json << haystack_zone_p2_sa_json
    # haystack_json << haystack_zone_p3_sa_json
    # haystack_json << haystack_zone_p4_sa_json
    #
    #
    # ################################################################################################################################
    # #########################       get Fan from AirLoopHVACs which is used as EMS actuator             ############################
    # #########################       to overwrite the zone SA flow, through EMS                          #############################
    # ################################################################################################################################
    #
    # model.getFanOnOffs.each do |fan|
    #   fan_name = fan.name.to_s
    #   #print fan_name
    #   zone_sa_actuator = OpenStudio::Model::EnergyManagementSystemActuator.new(fan,"Fan","Fan Air Mass Flow Rate")
    #   zone_sa_actuator.setName(create_ems_str("#{hyphen_replace(fan_name)} actuator"))
    #
    #   program = OpenStudio::Model::EnergyManagementSystemProgram.new(model)
    #   program.setName("SAFlow_Prgm_#{hyphen_replace(fan_name)}")
    #   if fan_name == "Core_ZN ZN PSZ-AC-1 Fan"
    #     program.addLine("SET #{zone_sa_actuator.handle.to_s} = #{supply_air_flow_zone_core_cmd}")
    #   elsif fan_name == "Perimeter_ZN_1 ZN PSZ-AC-2 Fan"
    #     program.addLine("SET #{zone_sa_actuator.handle.to_s} = #{supply_air_flow_zone_p1_cmd}")
    #   elsif fan_name == "Perimeter_ZN_2 ZN PSZ-AC-3 Fan"
    #     program.addLine("SET #{zone_sa_actuator.handle.to_s} = #{supply_air_flow_zone_p2_cmd}")
    #   elsif fan_name == "Perimeter_ZN_3 ZN PSZ-AC-4 Fan"
    #     program.addLine("SET #{zone_sa_actuator.handle.to_s} = #{supply_air_flow_zone_p3_cmd}")
    #   elsif fan_name == "Perimeter_ZN_4 ZN PSZ-AC-5 Fan"
    #     program.addLine("SET #{zone_sa_actuator.handle.to_s} = #{supply_air_flow_zone_p4_cmd}")
    #   else
    #     print ()
    #   end
    #   #EMS program calling manager
    #   pcm = OpenStudio::Model::EnergyManagementSystemProgramCallingManager.new(model)
    #   pcm.setName("SAFlow_Prgm_Mgr_#{ hyphen_replace(fan_name) }")
    #   pcm.setCallingPoint("AfterPredictorAfterHVACManagers")
    #   pcm.addProgram(program)
    #
    # end
    #
    #
    #
    # ################################################################################################################################
    # #########################       Create Setpoint Commands/Actuators in Haystack,    #############################
    # ######################### 	which are also from ExternalInterfaceVariables         #############################
    # ################################################################################################################################
    # #ExternalInterfaceVariables: heating/cooling setpoint command
    # heating_setpoint_cmd = create_ems_str("Heating Setpoint CMD")
    # cooling_setpoint_cmd = create_ems_str("Cooling Setpoint CMD")
    # heating_sp_var = OpenStudio::Model::ExternalInterfaceVariable.new(model, heating_setpoint_cmd, 24)
    # heating_sp_var.setExportToBCVTB(true)
    # cooling_sp_var = OpenStudio::Model::ExternalInterfaceVariable.new(model, cooling_setpoint_cmd, 28)
    # cooling_sp_var.setExportToBCVTB(true)
    # mapping_json << create_mapping_output_uuid(heating_setpoint_cmd, heating_sp_var.handle)
    # mapping_json << create_mapping_output_uuid(cooling_setpoint_cmd, cooling_sp_var.handle)
    # heating_sp_json = create_controlpoint_simbuild("writable", heating_setpoint_cmd, heating_sp_var.handle, building.handle,  "where", "what", "measurement", "Number", "Celsius")
    # cooling_sp_json = create_controlpoint_simbuild("writable", cooling_setpoint_cmd, cooling_sp_var.handle, building.handle,  "where", "what", "measurement", "Number", "Celsius")
    # haystack_json << heating_sp_json
    # haystack_json << cooling_sp_json
    #
    #
    # ################################################################################################################################
    # #########################       Create Heating/Cooling Setpoint Constant Schedules,                     #############################
    # #########################       which is to be used in EMS                      #############################
    # ################################################################################################################################
    #
    # heating_sch = OpenStudio::Model::ScheduleConstant.new(model)
    # heating_sch.setName("Heating SP")
    # heating_sch.setValue(24)
    #
    # cooling_sch = OpenStudio::Model::ScheduleConstant.new(model)
    # cooling_sch.setName("Cooling SP")
    # cooling_sch.setValue(28)
    #
    # ################################################################################################################################
    # #########################       set the thermostat setpoint to the                     #############################
    # #########################       constant setpoint i created                    #############################
    # ################################################################################################################################
    # model.getThermostatSetpointDualSetpoints.each do |tsp|
    #   xh=tsp.heatingSetpointTemperatureSchedule()
    #   if xh
    #     tsp.setHeatingSetpointTemperatureSchedule(heating_sch)
    #   end
    #   xc = tsp.coolingSetpointTemperatureSchedule()
    #   if xc
    #     tsp.setCoolingSetpointTemperatureSchedule(cooling_sch)
    #   end
    # end
    #
    #
    # ################################################################################################################################
    # #########################       Create EMS for heating/cooling setpoints,                     #############################
    # #########################       which is overwritten by Haystack commands                    #############################
    # ################################################################################################################################
    # heating_sp_actuator = OpenStudio::Model::EnergyManagementSystemActuator.new(heating_sch,"Schedule:Constant","Schedule Value")
    # heating_sp_actuator.setName(create_ems_str("heating setpoint actuator"))
    # program = OpenStudio::Model::EnergyManagementSystemProgram.new(model)
    # program.setName("Prgm_Heating_Setpoint")
    # program.addLine("SET #{heating_sp_actuator.handle.to_s} = #{heating_setpoint_cmd}")
    # pcm = OpenStudio::Model::EnergyManagementSystemProgramCallingManager.new(model)
    # pcm.setName("Prgm_Mgr_Heating_Setpoint")
    # pcm.setCallingPoint("AfterPredictorAfterHVACManagers")
    # pcm.addProgram(program)
    #
    # cooling_sp_actuator = OpenStudio::Model::EnergyManagementSystemActuator.new(cooling_sch,"Schedule:Constant","Schedule Value")
    # cooling_sp_actuator.setName(create_ems_str("cooling setpoint actuator"))
    # program = OpenStudio::Model::EnergyManagementSystemProgram.new(model)
    # program.setName("Prgm_Cooling_Setpoint")
    # program.addLine("SET #{cooling_sp_actuator.handle.to_s} = #{cooling_setpoint_cmd}")
    # pcm = OpenStudio::Model::EnergyManagementSystemProgramCallingManager.new(model)
    # pcm.setName("Prgm_Mgr_Cooling_Setpoint")
    # pcm.setCallingPoint("AfterPredictorAfterHVACManagers")
    # pcm.addProgram(program)
    #
    # ################################################################################################################################
    # #########################       wake up Fanger model for People Modules                      #############################
    # #########################                           #############################
    # ################################################################################################################################
    # people_defs = model.getPeopleDefinitions
    # people_defs.sort.each do |people_def|
    #   people_def.setThermalComfortModelType(0, 'FANGER')
    # end
    #
    # ################################################################################################################################
    # #########################      add new output variables                    #############################
    # #########################             check if its value == I give              #############################
    # ################################################################################################################################
    # outvar = OpenStudio::Model::OutputVariable.new("System Node Mass Flow Rate", model)
    # outvar.setKeyValue("Core_ZN ZN PSZ-AC-1 Supply Outlet Node")
    # outvar.setReportingFrequency(report_freq)
    # #outvar.setName("Core_SAMassFlow")
    # outvar.setExportToBCVTB(true)
    #
    # outvar = OpenStudio::Model::OutputVariable.new("Schedule Value", model)
    # outvar.setKeyValue("Cooling SP")
    # outvar.setReportingFrequency(report_freq)
    # #outvar.setName("Core_SAMassFlow")
    # outvar.setExportToBCVTB(true)

    runner.registerFinalCondition("Finished adding variables")

    return true
  end
end

# register the measure to be used by the application
AddAlfalfaForPSZ.new.registerWithApplication
