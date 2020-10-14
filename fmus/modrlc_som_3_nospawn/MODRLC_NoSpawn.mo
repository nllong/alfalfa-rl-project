within;
package MODRLC_NoSpawn
  model SOM2_noSpawn_01
    package Medium=Buildings.Media.Air
      "Buildings library air media package";
    Buildings.Experimental.SPAWN_SOM2.System3CAV system3CAV(
      redeclare package Medium=Medium,
      heaNomPow=14001)
      annotation (Placement(transformation(extent={{-66,-78},{8,-26}})));
    Buildings.BoundaryConditions.WeatherData.ReaderTMY3 weaDat(
      filNam=ModelicaServices.ExternalReferences.loadResource(
        "modelica://Buildings/Resources/weatherdata/USA_IL_Chicago-OHare.Intl.AP.725300_TMY3.mos"))
      annotation (Placement(transformation(extent={{-564,-50},{-544,-30}})));
    Buildings.BoundaryConditions.WeatherData.Bus weaBus
      annotation (Placement(transformation(extent={{-512,-60},{-472,-20}}),iconTransformation(extent={{-324,28},{-304,48}})));
    Buildings.Utilities.Time.CalendarTime calTim(
      zerTim=Buildings.Utilities.Time.Types.ZeroTime.NY2017,
      yearRef=2017)
      annotation (Placement(transformation(extent={{-492,82},{-460,114}})));
    Buildings.Experimental.SPAWN_SOM2.Schedule schedule
      annotation (Placement(transformation(extent={{-432,82},{-358,114}})));
    Modelica.Blocks.Sources.Constant qConGai_flow(
      k=0)
      "Convective heat gain"
      annotation (Placement(transformation(extent={{-172,166},{-152,186}})));
    Modelica.Blocks.Sources.Constant qRadGai_flow(
      k=0)
      "Radiative heat gain"
      annotation (Placement(transformation(extent={{-172,206},{-152,226}})));
    Modelica.Blocks.Routing.Multiplex3 mul
      "Multiplex for gains"
      annotation (Placement(transformation(extent={{-120,166},{-100,186}})));
    Modelica.Blocks.Sources.Constant qLatGai_flow(
      k=0)
      "Latent heat gain"
      annotation (Placement(transformation(extent={{-194,126},{-174,146}})));
    Buildings.Fluid.Sources.Outside out(
      redeclare package Medium=Medium,
      nPorts=2)
      annotation (Placement(transformation(extent={{-450,-50},{-430,-30}})));
    Buildings.Experimental.SPAWN_SOM2.CAVControlv2 cAVControlv2_1(
      designVFR=0.447163,
      minOA=0.080548)
      annotation (Placement(transformation(extent={{-66,24},{8,82}})));
    Buildings.Experimental.SPAWN_SOM2.CAVControlv2 cAVControlv2_2(
      designVFR=0.365803,
      minOA=0.061060)
      annotation (Placement(transformation(extent={{-68,-144},{6,-86}})));
    Buildings.Experimental.SPAWN_SOM2.System3CAV system3CAV1(
      redeclare package Medium=Medium,
      heaNomPow=11215.83)
      annotation (Placement(transformation(extent={{-72,-234},{2,-182}})));
    Buildings.Experimental.SPAWN_SOM2.CAVControlv2 cAVControlv2_3(
      designVFR=0.357318,
      minOA=0.036222)
      annotation (Placement(transformation(extent={{-70,-312},{4,-254}})));
    Buildings.Experimental.SPAWN_SOM2.System3CAV system3CAV2(
      redeclare package Medium=Medium,
      heaNomPow=9804.71)
      annotation (Placement(transformation(extent={{-74,-402},{0,-350}})));
    Buildings.Experimental.SPAWN_SOM2.CAVControlv2 cAVControlv2_4(
      designVFR=0.367676,
      minOA=0.061060)
      annotation (Placement(transformation(extent={{-72,-478},{2,-420}})));
    Buildings.Experimental.SPAWN_SOM2.System3CAV system3CAV3(
      redeclare package Medium=Medium,
      heaNomPow=11257.89)
      annotation (Placement(transformation(extent={{-76,-568},{-2,-516}})));
    Buildings.Experimental.SPAWN_SOM2.CAVControlv2 cAVControlv2_5(
      designVFR=0.343483,
      minOA=0.036222)
      annotation (Placement(transformation(extent={{-78,-640},{-4,-582}})));
    Buildings.Experimental.SPAWN_SOM2.System3CAV system3CAV4(
      redeclare package Medium=Medium,
      heaNomPow=9494)
      annotation (Placement(transformation(extent={{-82,-730},{-8,-678}})));
    Buildings.Fluid.Sources.Outside out1(
      redeclare package Medium=Medium,
      nPorts=4)
      annotation (Placement(transformation(extent={{-442,-224},{-422,-204}})));
    Buildings.Fluid.Sources.Outside out2(
      redeclare package Medium=Medium,
      nPorts=4)
      annotation (Placement(transformation(extent={{-440,-396},{-420,-376}})));
    Buildings.Fluid.Sources.Outside out3(
      redeclare package Medium=Medium,
      nPorts=4)
      annotation (Placement(transformation(extent={{-466,-558},{-446,-538}})));
    Buildings.Fluid.Sources.Outside out4(
      redeclare package Medium=Medium,
      nPorts=4)
      annotation (Placement(transformation(extent={{-444,-728},{-424,-708}})));
    Buildings.Airflow.Multizone.ZonalFlow_ACS infCore1(
      redeclare package Medium=Medium,
      V=113.45)
      annotation (Placement(transformation(extent={{-254,-160},{-234,-140}})));
    Modelica.Blocks.Sources.Constant infCoreACH1(
      k=0.000073611)
      annotation (Placement(transformation(extent={{-288,-130},{-268,-110}})));
    Buildings.Airflow.Multizone.ZonalFlow_ACS infCore2(
      redeclare package Medium=Medium,
      V=67.30)
      annotation (Placement(transformation(extent={{-258,-332},{-238,-312}})));
    Modelica.Blocks.Sources.Constant infCoreACH2(
      k=0.000082778)
      annotation (Placement(transformation(extent={{-292,-302},{-272,-282}})));
    Buildings.Airflow.Multizone.ZonalFlow_ACS infCore3(
      redeclare package Medium=Medium,
      V=113.45)
      annotation (Placement(transformation(extent={{-254,-510},{-234,-490}})));
    Modelica.Blocks.Sources.Constant infCoreACH3(
      k=0.000073611)
      annotation (Placement(transformation(extent={{-288,-480},{-268,-460}})));
    Buildings.Airflow.Multizone.ZonalFlow_ACS infCore4(
      redeclare package Medium=Medium,
      V=67.30)
      annotation (Placement(transformation(extent={{-248,-674},{-228,-654}})));
    Modelica.Blocks.Sources.Constant infCoreACH4(
      k=0.000082778)
      annotation (Placement(transformation(extent={{-282,-644},{-262,-624}})));
    Buildings.Fluid.MixingVolumes.MixingVolume vol_cz(
      redeclare package Medium=Medium,
      m_flow_nominal=0.5,
      V=456.46,
      nPorts=2)
      annotation (Placement(transformation(extent={{104,-58},{124,-38}})));
    Buildings.Fluid.MixingVolumes.MixingVolume vol_pz1(
      redeclare package Medium=Medium,
      m_flow_nominal=0.5,
      V=346.02,
      nPorts=4)
      annotation (Placement(transformation(extent={{94,-212},{114,-192}})));
    Buildings.Fluid.MixingVolumes.MixingVolume vol_pz2(
      redeclare package Medium=Medium,
      m_flow_nominal=0.5,
      V=205.26,
      nPorts=4)
      annotation (Placement(transformation(extent={{96,-372},{116,-352}})));
    Buildings.Fluid.MixingVolumes.MixingVolume vol_pz3(
      redeclare package Medium=Medium,
      m_flow_nominal=0.5,
      V=346.02,
      nPorts=4)
      annotation (Placement(transformation(extent={{104,-536},{124,-516}})));
    Buildings.Fluid.MixingVolumes.MixingVolume vol_pz4(
      redeclare package Medium=Medium,
      m_flow_nominal=0.5,
      V=346.02,
      nPorts=4)
      annotation (Placement(transformation(extent={{92,-690},{112,-670}})));
    Buildings.HeatTransfer.Sources.PrescribedHeatFlow prescribedHeatFlow
      annotation (Placement(transformation(extent={{58,-46},{78,-26}})));
    Modelica.Blocks.Sources.CombiTimeTable combiTimeTable(
      tableOnFile=true,
      tableName="csv",
      fileName=ModelicaServices.ExternalReferences.loadResource(
        "modelica://Buildings/Experimental/Resources/combi.csv"))
      annotation (Placement(transformation(extent={{28,-8},{48,12}})));
    Buildings.HeatTransfer.Sources.PrescribedHeatFlow prescribedHeatFlow1
      annotation (Placement(transformation(extent={{58,-204},{78,-184}})));
    Modelica.Blocks.Sources.CombiTimeTable combiTimeTable1(
      tableOnFile=true,
      tableName="csv",
      fileName=ModelicaServices.ExternalReferences.loadResource(
        "modelica://Buildings/Experimental/Resources/combi1.csv"))
      annotation (Placement(transformation(extent={{28,-166},{48,-146}})));
    Buildings.HeatTransfer.Sources.PrescribedHeatFlow prescribedHeatFlow2
      annotation (Placement(transformation(extent={{62,-370},{82,-350}})));
    Modelica.Blocks.Sources.CombiTimeTable combiTimeTable2(
      tableOnFile=true,
      tableName="csv",
      fileName=ModelicaServices.ExternalReferences.loadResource(
        "modelica://Buildings/Experimental/Resources/combi2.csv"))
      annotation (Placement(transformation(extent={{32,-332},{52,-312}})));
    Buildings.HeatTransfer.Sources.PrescribedHeatFlow prescribedHeatFlow3
      annotation (Placement(transformation(extent={{56,-532},{76,-512}})));
    Modelica.Blocks.Sources.CombiTimeTable combiTimeTable3(
      tableOnFile=true,
      tableName="csv",
      fileName=ModelicaServices.ExternalReferences.loadResource(
        "modelica://Buildings/Experimental/Resources/combi3.csv"))
      annotation (Placement(transformation(extent={{26,-494},{46,-474}})));
    Buildings.HeatTransfer.Sources.PrescribedHeatFlow prescribedHeatFlow4
      annotation (Placement(transformation(extent={{56,-688},{76,-668}})));
    Modelica.Blocks.Sources.CombiTimeTable combiTimeTable4(
      tableOnFile=true,
      tableName="csv",
      fileName=ModelicaServices.ExternalReferences.loadResource(
        "modelica://Buildings/Experimental/Resources/combi4.csv"))
      annotation (Placement(transformation(extent={{26,-650},{46,-630}})));
  equation
    connect(weaDat.weaBus,weaBus)
      annotation (Line(points={{-544,-40},{-492,-40}},color={255,204,51},thickness=0.5),Text(string="%second",index=1,extent={{6,3},{6,3}},horizontalAlignment=TextAlignment.Left));
    connect(schedule.Hour,calTim.hour)
      annotation (Line(points={{-434.186,110.8},{-446,110.8},{-446,110},{-452,110},{-452,108.24},{-458.4,108.24}},color={255,127,0}));
    connect(calTim.weekDay,schedule.Day)
      annotation (Line(points={{-458.4,91.6},{-456,91.6},{-456,92},{-452,92},{-452,101.2},{-434.018,101.2}},color={255,127,0}));
    connect(qRadGai_flow.y,mul.u1[1])
      annotation (Line(points={{-151,216},{-132,216},{-132,183},{-122,183}},color={0,0,127},smooth=Smooth.None));
    connect(qConGai_flow.y,mul.u2[1])
      annotation (Line(points={{-151,176},{-122,176}},color={0,0,127},smooth=Smooth.None));
    connect(mul.u3[1],qLatGai_flow.y)
      annotation (Line(points={{-122,169},{-132,169},{-132,136},{-173,136}},color={0,0,127}));
    connect(weaBus,out.weaBus)
      annotation (Line(points={{-492,-40},{-470,-40},{-470,-39.8},{-450,-39.8}},color={255,204,51},thickness=0.5),Text(string="%first",index=-1,extent={{-6,3},{-6,3}},horizontalAlignment=TextAlignment.Right));
    connect(system3CAV.port_outside_inlet,out.ports[1])
      annotation (Line(points={{-67.2634,-59.3273},{-102.2,-59.3273},{-102.2,-38},{-430,-38}},color={0,127,255}));
    connect(system3CAV.port_outside_outlet,out.ports[2])
      annotation (Line(points={{-67.2634,-70.4364},{-253.632,-70.4364},{-253.632,-42},{-430,-42}},color={0,127,255}));
    connect(system3CAV.T_OutsideAir,weaBus.TDryBul)
      annotation (Line(points={{-68.5268,-28.1273},{-374,-28.1273},{-374,-12},{-460,-12},{-460,-40},{-492,-40}},color={0,0,127}),Text(string="%second",index=1,extent={{-6,3},{-6,3}},horizontalAlignment=TextAlignment.Right));
    connect(cAVControlv2_1.isDay,schedule.isDay)
      annotation (Line(points={{-70.1933,76.8444},{-178,76.8444},{-178,112},{-246,112},{-246,111.486},{-355.477,111.486}},color={255,0,255}));
    connect(cAVControlv2_1.isNight,schedule.isNight)
      annotation (Line(points={{-70.1933,65.5667},{-187.8,65.5667},{-187.8,105.543},{-355.645,105.543}},color={255,0,255}));
    connect(cAVControlv2_1.isSunday,schedule.isSunday)
      annotation (Line(points={{-70.1933,52.0333},{-199.8,52.0333},{-199.8,98.9143},{-355.814,98.9143}},color={255,0,255}));
    connect(cAVControlv2_1.HR_return,system3CAV.HR)
      annotation (Line(points={{-58.6,19.1667},{-58.6,6.2611},{-54.6293,6.2611},{-54.6293,-20.8}},color={0,0,127}));
    connect(cAVControlv2_1.T_OA,system3CAV.TOA)
      annotation (Line(points={{-50.7067,18.8444},{-50.7067,6.4222},{-47.4098,6.4222},{-47.4098,-21.2727}},color={0,0,127}));
    connect(cAVControlv2_1.T_mixed,system3CAV.TM)
      annotation (Line(points={{-42.32,18.8444},{-42.32,8.4222},{-41.2732,8.4222},{-41.2732,-21.0364}},color={0,0,127}));
    connect(cAVControlv2_1.T_supp,system3CAV.TS)
      annotation (Line(points={{-34.92,18.8444},{-34.92,6.4222},{-34.0537,6.4222},{-34.0537,-20.8}},color={0,0,127}));
    connect(cAVControlv2_1.CC_OnOff,system3CAV.CoolingCoil_OnOff_Command)
      annotation (Line(points={{-20.7367,18.6833},{-20.7367,6.5028},{-22.322,6.5028},{-22.322,-21.0364}},color={255,0,255}));
    connect(cAVControlv2_1.HC_Setpoint,system3CAV.T_HeatingCoil_Command)
      annotation (Line(points={{-12.4733,18.8444},{-12.4733,6.58335},{-14.561,6.58335},{-14.561,-20.8}},color={0,0,127}));
    connect(cAVControlv2_1.Damper_Setting,system3CAV.OA_Damper_mixing_command)
      annotation (Line(points={{-5.44333,19.0056},{-5.44333,6.6639},{-7.88293,6.6639},{-7.88293,-20.8}},color={0,0,127}));
    connect(out1.weaBus,weaBus)
      annotation (Line(points={{-442,-213.8},{-466,-213.8},{-466,-40},{-492,-40}},color={255,204,51},thickness=0.5),Text(string="%second",index=1,extent={{-6,3},{-6,3}},horizontalAlignment=TextAlignment.Right));
    connect(out1.weaBus,out2.weaBus)
      annotation (Line(points={{-442,-213.8},{-466,-213.8},{-466,-385.8},{-440,-385.8}},color={255,204,51},thickness=0.5));
    connect(out3.weaBus,out2.weaBus)
      annotation (Line(points={{-466,-547.8},{-466,-385.8},{-440,-385.8}},color={255,204,51},thickness=0.5));
    connect(out4.weaBus,out3.weaBus)
      annotation (Line(points={{-444,-717.8},{-466,-717.8},{-466,-547.8}},color={255,204,51},thickness=0.5));
    connect(out1.ports[1],system3CAV1.port_outside_inlet)
      annotation (Line(points={{-422,-211},{-248,-211},{-248,-215.327},{-73.2634,-215.327}},color={0,127,255}));
    connect(system3CAV1.port_outside_outlet,out1.ports[2])
      annotation (Line(points={{-73.2634,-226.436},{-248.632,-226.436},{-248.632,-213},{-422,-213}},color={0,127,255}));
    connect(system3CAV2.port_outside_inlet,out2.ports[1])
      annotation (Line(points={{-75.2634,-383.327},{-249.632,-383.327},{-249.632,-383},{-420,-383}},color={0,127,255}));
    connect(system3CAV2.port_outside_outlet,out2.ports[2])
      annotation (Line(points={{-75.2634,-394.436},{-247.632,-394.436},{-247.632,-385},{-420,-385}},color={0,127,255}));
    connect(system3CAV3.port_outside_inlet,out3.ports[1])
      annotation (Line(points={{-77.2634,-549.327},{-262.632,-549.327},{-262.632,-545},{-446,-545}},color={0,127,255}));
    connect(system3CAV3.port_outside_outlet,out3.ports[2])
      annotation (Line(points={{-77.2634,-560.436},{-261.632,-560.436},{-261.632,-547},{-446,-547}},color={0,127,255}));
    connect(system3CAV4.port_outside_inlet,out4.ports[1])
      annotation (Line(points={{-83.2634,-711.327},{-254.632,-711.327},{-254.632,-715},{-424,-715}},color={0,127,255}));
    connect(system3CAV4.port_outside_outlet,out4.ports[2])
      annotation (Line(points={{-83.2634,-722.436},{-254.632,-722.436},{-254.632,-717},{-424,-717}},color={0,127,255}));
    connect(system3CAV.T_OutsideAir,system3CAV1.T_OutsideAir)
      annotation (Line(points={{-68.5268,-28.1273},{-374,-28.1273},{-374,-12},{-398,-12},{-398,-184.127},{-74.5268,-184.127}},color={0,0,127}));
    connect(system3CAV2.T_OutsideAir,system3CAV1.T_OutsideAir)
      annotation (Line(points={{-76.5268,-352.127},{-398,-352.127},{-398,-184.127},{-74.5268,-184.127}},color={0,0,127}));
    connect(system3CAV3.T_OutsideAir,system3CAV1.T_OutsideAir)
      annotation (Line(points={{-78.5268,-518.127},{-398,-518.127},{-398,-184.127},{-74.5268,-184.127}},color={0,0,127}));
    connect(system3CAV4.T_OutsideAir,system3CAV1.T_OutsideAir)
      annotation (Line(points={{-84.5268,-680.127},{-398,-680.127},{-398,-184.127},{-74.5268,-184.127}},color={0,0,127}));
    connect(cAVControlv2_2.isDay,schedule.isDay)
      annotation (Line(points={{-72.1933,-91.1556},{-72.1933,-92},{-178,-92},{-178,112},{-246,112},{-246,111.486},{-355.477,111.486}},color={255,0,255}));
    connect(cAVControlv2_2.isNight,schedule.isNight)
      annotation (Line(points={{-72.1933,-102.433},{-188,-102.433},{-188,66},{-187.8,66},{-187.8,105.543},{-355.645,105.543}},color={255,0,255}));
    connect(cAVControlv2_2.isSunday,schedule.isSunday)
      annotation (Line(points={{-72.1933,-115.967},{-72.1933,-114},{-198,-114},{-198,52.0333},{-199.8,52.0333},{-199.8,98.9143},{-355.814,98.9143}},color={255,0,255}));
    connect(cAVControlv2_3.isDay,schedule.isDay)
      annotation (Line(points={{-74.1933,-259.156},{-178,-259.156},{-178,112},{-246,112},{-246,111.486},{-355.477,111.486}},color={255,0,255}));
    connect(cAVControlv2_3.isNight,schedule.isNight)
      annotation (Line(points={{-74.1933,-270.433},{-188,-270.433},{-188,66},{-187.8,66},{-187.8,105.543},{-355.645,105.543}},color={255,0,255}));
    connect(cAVControlv2_3.isSunday,schedule.isSunday)
      annotation (Line(points={{-74.1933,-283.967},{-74.1933,-284},{-198,-284},{-198,52.0333},{-199.8,52.0333},{-199.8,98.9143},{-355.814,98.9143}},color={255,0,255}));
    connect(cAVControlv2_4.isDay,schedule.isDay)
      annotation (Line(points={{-76.1933,-425.156},{-176,-425.156},{-176,-259.156},{-178,-259.156},{-178,112},{-246,112},{-246,111.486},{-355.477,111.486}},color={255,0,255}));
    connect(cAVControlv2_4.isNight,schedule.isNight)
      annotation (Line(points={{-76.1933,-436.433},{-188,-436.433},{-188,66},{-187.8,66},{-187.8,105.543},{-355.645,105.543}},color={255,0,255}));
    connect(cAVControlv2_4.isSunday,schedule.isSunday)
      annotation (Line(points={{-76.1933,-449.967},{-76.1933,-450},{-198,-450},{-198,52.0333},{-199.8,52.0333},{-199.8,98.9143},{-355.814,98.9143}},color={255,0,255}));
    connect(cAVControlv2_5.isDay,schedule.isDay)
      annotation (Line(points={{-82.1933,-587.156},{-176,-587.156},{-176,-259.156},{-178,-259.156},{-178,112},{-246,112},{-246,111.486},{-355.477,111.486}},color={255,0,255}));
    connect(cAVControlv2_5.isNight,schedule.isNight)
      annotation (Line(points={{-82.1933,-598.433},{-188,-598.433},{-188,66},{-187.8,66},{-187.8,105.543},{-355.645,105.543}},color={255,0,255}));
    connect(cAVControlv2_5.isSunday,schedule.isSunday)
      annotation (Line(points={{-82.1933,-611.967},{-82.1933,-612},{-198,-612},{-198,52.0333},{-199.8,52.0333},{-199.8,98.9143},{-355.814,98.9143}},color={255,0,255}));
    connect(cAVControlv2_2.T_return,system3CAV1.TR)
      annotation (Line(points={{-69.2333,-149.478},{-69.2333,-162.739},{-66.5854,-162.739},{-66.5854,-177.273}},color={0,0,127}));
    connect(cAVControlv2_2.HR_return,system3CAV1.HR)
      annotation (Line(points={{-60.6,-148.833},{-60.6,-160.739},{-60.6293,-160.739},{-60.6293,-176.8}},color={0,0,127}));
    connect(cAVControlv2_2.T_OA,system3CAV1.TOA)
      annotation (Line(points={{-52.7067,-149.156},{-52.7067,-161.578},{-53.4098,-161.578},{-53.4098,-177.273}},color={0,0,127}));
    connect(cAVControlv2_2.T_mixed,system3CAV1.TM)
      annotation (Line(points={{-44.32,-149.156},{-44.32,-163.578},{-47.2732,-163.578},{-47.2732,-177.036}},color={0,0,127}));
    connect(cAVControlv2_2.T_supp,system3CAV1.TS)
      annotation (Line(points={{-36.92,-149.156},{-36.92,-161.578},{-40.0537,-161.578},{-40.0537,-176.8}},color={0,0,127}));
    connect(cAVControlv2_2.CC_OnOff,system3CAV1.CoolingCoil_OnOff_Command)
      annotation (Line(points={{-22.7367,-149.317},{-22.7367,-162.497},{-28.322,-162.497},{-28.322,-177.036}},color={255,0,255}));
    connect(cAVControlv2_2.HC_Setpoint,system3CAV1.T_HeatingCoil_Command)
      annotation (Line(points={{-14.4733,-149.156},{-14.4733,-163.416},{-20.561,-163.416},{-20.561,-176.8}},color={0,0,127}));
    connect(cAVControlv2_2.Damper_Setting,system3CAV1.OA_Damper_mixing_command)
      annotation (Line(points={{-7.44333,-148.994},{-7.44333,-162.336},{-13.8829,-162.336},{-13.8829,-176.8}},color={0,0,127}));
    connect(cAVControlv2_3.T_return,system3CAV2.TR)
      annotation (Line(points={{-71.2333,-317.478},{-71.2333,-332.739},{-68.5854,-332.739},{-68.5854,-345.273}},color={0,0,127}));
    connect(cAVControlv2_3.HR_return,system3CAV2.HR)
      annotation (Line(points={{-62.6,-316.833},{-62.6,-332.739},{-62.6293,-332.739},{-62.6293,-344.8}},color={0,0,127}));
    connect(cAVControlv2_3.T_OA,system3CAV2.TOA)
      annotation (Line(points={{-54.7067,-317.156},{-54.7067,-332.578},{-55.4098,-332.578},{-55.4098,-345.273}},color={0,0,127}));
    connect(cAVControlv2_3.T_mixed,system3CAV2.TM)
      annotation (Line(points={{-46.32,-317.156},{-46.32,-331.578},{-49.2732,-331.578},{-49.2732,-345.036}},color={0,0,127}));
    connect(cAVControlv2_3.T_supp,system3CAV2.TS)
      annotation (Line(points={{-38.92,-317.156},{-38.92,-329.578},{-42.0537,-329.578},{-42.0537,-344.8}},color={0,0,127}));
    connect(cAVControlv2_3.CC_OnOff,system3CAV2.CoolingCoil_OnOff_Command)
      annotation (Line(points={{-24.7367,-317.317},{-24.7367,-329.497},{-30.322,-329.497},{-30.322,-345.036}},color={255,0,255}));
    connect(cAVControlv2_3.HC_Setpoint,system3CAV2.T_HeatingCoil_Command)
      annotation (Line(points={{-16.4733,-317.156},{-16.4733,-330.417},{-22.561,-330.417},{-22.561,-344.8}},color={0,0,127}));
    connect(cAVControlv2_3.Damper_Setting,system3CAV2.OA_Damper_mixing_command)
      annotation (Line(points={{-9.44333,-316.994},{-9.44333,-331.336},{-15.8829,-331.336},{-15.8829,-344.8}},color={0,0,127}));
    connect(cAVControlv2_4.T_return,system3CAV3.TR)
      annotation (Line(points={{-73.2333,-483.478},{-73.2333,-497.739},{-70.5854,-497.739},{-70.5854,-511.273}},color={0,0,127}));
    connect(cAVControlv2_4.HR_return,system3CAV3.HR)
      annotation (Line(points={{-64.6,-482.833},{-64.6,-498.739},{-64.6293,-498.739},{-64.6293,-510.8}},color={0,0,127}));
    connect(cAVControlv2_4.T_OA,system3CAV3.TOA)
      annotation (Line(points={{-56.7067,-483.156},{-56.7067,-496.578},{-57.4098,-496.578},{-57.4098,-511.273}},color={0,0,127}));
    connect(cAVControlv2_4.T_mixed,system3CAV3.TM)
      annotation (Line(points={{-48.32,-483.156},{-48.32,-498.578},{-51.2732,-498.578},{-51.2732,-511.036}},color={0,0,127}));
    connect(cAVControlv2_4.T_supp,system3CAV3.TS)
      annotation (Line(points={{-40.92,-483.156},{-40.92,-497.578},{-44.0537,-497.578},{-44.0537,-510.8}},color={0,0,127}));
    connect(cAVControlv2_4.CC_OnOff,system3CAV3.CoolingCoil_OnOff_Command)
      annotation (Line(points={{-26.7367,-483.317},{-26.7367,-497.497},{-32.322,-497.497},{-32.322,-511.036}},color={255,0,255}));
    connect(cAVControlv2_4.HC_Setpoint,system3CAV3.T_HeatingCoil_Command)
      annotation (Line(points={{-18.4733,-483.156},{-18.4733,-497.417},{-24.561,-497.417},{-24.561,-510.8}},color={0,0,127}));
    connect(cAVControlv2_4.Damper_Setting,system3CAV3.OA_Damper_mixing_command)
      annotation (Line(points={{-11.4433,-482.994},{-11.4433,-496.336},{-17.8829,-496.336},{-17.8829,-510.8}},color={0,0,127}));
    connect(cAVControlv2_5.T_return,system3CAV4.TR)
      annotation (Line(points={{-79.2333,-645.478},{-79.2333,-658.739},{-76.5854,-658.739},{-76.5854,-673.273}},color={0,0,127}));
    connect(cAVControlv2_5.HR_return,system3CAV4.HR)
      annotation (Line(points={{-70.6,-644.833},{-70.6,-659.739},{-70.6293,-659.739},{-70.6293,-672.8}},color={0,0,127}));
    connect(cAVControlv2_5.T_OA,system3CAV4.TOA)
      annotation (Line(points={{-62.7067,-645.156},{-62.7067,-658.578},{-63.4098,-658.578},{-63.4098,-673.273}},color={0,0,127}));
    connect(cAVControlv2_5.T_mixed,system3CAV4.TM)
      annotation (Line(points={{-54.32,-645.156},{-54.32,-659.578},{-57.2732,-659.578},{-57.2732,-673.036}},color={0,0,127}));
    connect(cAVControlv2_5.T_supp,system3CAV4.TS)
      annotation (Line(points={{-46.92,-645.156},{-46.92,-659.578},{-50.0537,-659.578},{-50.0537,-672.8}},color={0,0,127}));
    connect(cAVControlv2_5.CC_OnOff,system3CAV4.CoolingCoil_OnOff_Command)
      annotation (Line(points={{-32.7367,-645.317},{-32.7367,-658.497},{-38.322,-658.497},{-38.322,-673.036}},color={255,0,255}));
    connect(cAVControlv2_5.HC_Setpoint,system3CAV4.T_HeatingCoil_Command)
      annotation (Line(points={{-24.4733,-645.156},{-24.4733,-658.417},{-30.561,-658.417},{-30.561,-672.8}},color={0,0,127}));
    connect(cAVControlv2_5.Damper_Setting,system3CAV4.OA_Damper_mixing_command)
      annotation (Line(points={{-17.4433,-644.994},{-17.4433,-659.336},{-23.8829,-659.336},{-23.8829,-672.8}},color={0,0,127}));
    connect(cAVControlv2_1.VFR_setting,system3CAV.Fan_Flowrate_setpoint)
      annotation (Line(points={{3.19,19.3278},{3.19,8.6639},{2.40488,8.6639},{2.40488,-20.8}},color={0,0,127}));
    connect(cAVControlv2_2.VFR_setting,system3CAV1.Fan_Flowrate_setpoint)
      annotation (Line(points={{1.19,-148.672},{1.19,-160.336},{-3.59512,-160.336},{-3.59512,-176.8}},color={0,0,127}));
    connect(cAVControlv2_3.VFR_setting,system3CAV2.Fan_Flowrate_setpoint)
      annotation (Line(points={{-0.81,-316.672},{-0.81,-328.336},{-5.59512,-328.336},{-5.59512,-344.8}},color={0,0,127}));
    connect(cAVControlv2_4.VFR_setting,system3CAV3.Fan_Flowrate_setpoint)
      annotation (Line(points={{-2.81,-482.672},{-2.81,-495.336},{-7.59512,-495.336},{-7.59512,-510.8}},color={0,0,127}));
    connect(cAVControlv2_5.VFR_setting,system3CAV4.Fan_Flowrate_setpoint)
      annotation (Line(points={{-8.81,-644.672},{-8.81,-656.336},{-13.5951,-656.336},{-13.5951,-672.8}},color={0,0,127}));
    connect(system3CAV.OA_VFR,cAVControlv2_1.OA_VFR)
      annotation (Line(points={{-28.278,-20.8},{-28.278,6.6},{-28.0133,6.6},{-28.0133,18.8444}},color={0,0,127}));
    connect(system3CAV1.OA_VFR,cAVControlv2_2.OA_VFR)
      annotation (Line(points={{-34.278,-176.8},{-34.278,-164.4},{-30.0133,-164.4},{-30.0133,-149.156}},color={0,0,127}));
    connect(system3CAV2.OA_VFR,cAVControlv2_3.OA_VFR)
      annotation (Line(points={{-36.278,-344.8},{-36.278,-331.4},{-32.0133,-331.4},{-32.0133,-317.156}},color={0,0,127}));
    connect(system3CAV3.OA_VFR,cAVControlv2_4.OA_VFR)
      annotation (Line(points={{-38.278,-510.8},{-38.278,-498.4},{-34.0133,-498.4},{-34.0133,-483.156}},color={0,0,127}));
    connect(system3CAV4.OA_VFR,cAVControlv2_5.OA_VFR)
      annotation (Line(points={{-44.278,-672.8},{-44.278,-660.4},{-40.0133,-660.4},{-40.0133,-645.156}},color={0,0,127}));
    connect(infCore4.port_a1,out4.ports[3])
      annotation (Line(points={{-248,-658},{-336,-658},{-336,-719},{-424,-719}},color={0,127,255}));
    connect(infCore4.port_b2,out4.ports[4])
      annotation (Line(points={{-248,-670},{-336,-670},{-336,-721},{-424,-721}},color={0,127,255}));
    connect(infCoreACH4.y,infCore4.ACS)
      annotation (Line(points={{-261,-634},{-254,-634},{-254,-654},{-249,-654}},color={0,0,127}));
    connect(infCore3.port_a1,out3.ports[3])
      annotation (Line(points={{-254,-494},{-350,-494},{-350,-549},{-446,-549}},color={0,127,255}));
    connect(infCore3.port_b2,out3.ports[4])
      annotation (Line(points={{-254,-506},{-350,-506},{-350,-551},{-446,-551}},color={0,127,255}));
    connect(infCoreACH3.y,infCore3.ACS)
      annotation (Line(points={{-267,-470},{-267,-481},{-255,-481},{-255,-490}},color={0,0,127}));
    connect(infCore2.port_a1,out2.ports[3])
      annotation (Line(points={{-258,-316},{-340,-316},{-340,-387},{-420,-387}},color={0,127,255}));
    connect(infCore2.port_b2,out2.ports[4])
      annotation (Line(points={{-258,-328},{-340,-328},{-340,-389},{-420,-389}},color={0,127,255}));
    connect(infCoreACH2.y,infCore2.ACS)
      annotation (Line(points={{-271,-292},{-266,-292},{-266,-312},{-259,-312}},color={0,0,127}));
    connect(infCore1.port_a1,out1.ports[3])
      annotation (Line(points={{-254,-144},{-340,-144},{-340,-215},{-422,-215}},color={0,127,255}));
    connect(infCore1.port_b2,out1.ports[4])
      annotation (Line(points={{-254,-156},{-340,-156},{-340,-217},{-422,-217}},color={0,127,255}));
    connect(infCoreACH1.y,infCore1.ACS)
      annotation (Line(points={{-267,-120},{-262,-120},{-262,-140},{-255,-140}},color={0,0,127}));
    connect(system3CAV.TR,cAVControlv2_1.T_return)
      annotation (Line(points={{-60.5854,-21.2727},{-60.5854,2.36365},{-67.2333,2.36365},{-67.2333,18.5222}},color={0,0,127}));
    connect(system3CAV.port_supply,vol_cz.ports[1])
      annotation (Line(points={{9.26341,-59.0909},{59.6317,-59.0909},{59.6317,-58},{112,-58}},color={0,127,255}));
    connect(system3CAV.port_return,vol_cz.ports[2])
      annotation (Line(points={{9.4439,-69.9636},{62.7219,-69.9636},{62.7219,-58},{116,-58}},color={0,127,255}));
    connect(system3CAV1.port_supply,vol_pz1.ports[1])
      annotation (Line(points={{3.26341,-215.091},{53.6317,-215.091},{53.6317,-212},{101,-212}},color={0,127,255}));
    connect(system3CAV1.port_return,vol_pz1.ports[2])
      annotation (Line(points={{3.4439,-225.964},{55.7219,-225.964},{55.7219,-212},{103,-212}},color={0,127,255}));
    connect(infCore1.port_b1,vol_pz1.ports[3])
      annotation (Line(points={{-234,-144},{-64,-144},{-64,-212},{105,-212}},color={0,127,255}));
    connect(infCore1.port_a2,vol_pz1.ports[4])
      annotation (Line(points={{-234,-156},{-64,-156},{-64,-212},{107,-212}},color={0,127,255}));
    connect(system3CAV2.port_supply,vol_pz2.ports[1])
      annotation (Line(points={{1.26341,-383.091},{54.6317,-383.091},{54.6317,-372},{103,-372}},color={0,127,255}));
    connect(system3CAV2.port_return,vol_pz2.ports[2])
      annotation (Line(points={{1.4439,-393.964},{54.7219,-393.964},{54.7219,-372},{105,-372}},color={0,127,255}));
    connect(infCore2.port_b1,vol_pz2.ports[3])
      annotation (Line(points={{-238,-316},{-64,-316},{-64,-372},{107,-372}},color={0,127,255}));
    connect(infCore2.port_a2,vol_pz2.ports[4])
      annotation (Line(points={{-238,-328},{-64,-328},{-64,-372},{109,-372}},color={0,127,255}));
    connect(system3CAV3.port_supply,vol_pz3.ports[1])
      annotation (Line(points={{-0.736585,-549.091},{56.6317,-549.091},{56.6317,-536},{111,-536}},color={0,127,255}));
    connect(system3CAV3.port_return,vol_pz3.ports[2])
      annotation (Line(points={{-0.556098,-559.964},{57.722,-559.964},{57.722,-536},{113,-536}},color={0,127,255}));
    connect(infCore3.port_b1,vol_pz3.ports[3])
      annotation (Line(points={{-234,-494},{-58,-494},{-58,-536},{115,-536}},color={0,127,255}));
    connect(infCore3.port_a2,vol_pz3.ports[4])
      annotation (Line(points={{-234,-506},{-60,-506},{-60,-536},{117,-536}},color={0,127,255}));
    connect(system3CAV4.port_supply,vol_pz4.ports[1])
      annotation (Line(points={{-6.73659,-711.091},{47.6317,-711.091},{47.6317,-690},{99,-690}},color={0,127,255}));
    connect(system3CAV4.port_return,vol_pz4.ports[2])
      annotation (Line(points={{-6.5561,-721.964},{48.7219,-721.964},{48.7219,-690},{101,-690}},color={0,127,255}));
    connect(infCore4.port_b1,vol_pz4.ports[3])
      annotation (Line(points={{-228,-658},{-62,-658},{-62,-690},{103,-690}},color={0,127,255}));
    connect(infCore4.port_a2,vol_pz4.ports[4])
      annotation (Line(points={{-228,-670},{-62,-670},{-62,-690},{105,-690}},color={0,127,255}));
    connect(prescribedHeatFlow.port,vol_cz.heatPort)
      annotation (Line(points={{78,-36},{84,-36},{84,-48},{104,-48}},color={191,0,0}));
    connect(combiTimeTable.y[1],prescribedHeatFlow.Q_flow)
      annotation (Line(points={{49,2},{56,2},{56,-36},{58,-36}},color={0,0,127}));
    connect(combiTimeTable1.y[1],prescribedHeatFlow1.Q_flow)
      annotation (Line(points={{49,-156},{56,-156},{56,-194},{58,-194}},color={0,0,127}));
    connect(prescribedHeatFlow1.port,vol_pz1.heatPort)
      annotation (Line(points={{78,-194},{88,-194},{88,-202},{94,-202}},color={191,0,0}));
    connect(combiTimeTable2.y[1],prescribedHeatFlow2.Q_flow)
      annotation (Line(points={{53,-322},{60,-322},{60,-360},{62,-360}},color={0,0,127}));
    connect(prescribedHeatFlow2.port,vol_pz2.heatPort)
      annotation (Line(points={{82,-360},{92,-360},{92,-362},{96,-362}},color={191,0,0}));
    connect(combiTimeTable3.y[1],prescribedHeatFlow3.Q_flow)
      annotation (Line(points={{47,-484},{54,-484},{54,-522},{56,-522}},color={0,0,127}));
    connect(prescribedHeatFlow3.port,vol_pz3.heatPort)
      annotation (Line(points={{76,-522},{90,-522},{90,-526},{104,-526}},color={191,0,0}));
    connect(combiTimeTable4.y[1],prescribedHeatFlow4.Q_flow)
      annotation (Line(points={{47,-640},{54,-640},{54,-678},{56,-678}},color={0,0,127}));
    connect(prescribedHeatFlow4.port,vol_pz4.heatPort)
      annotation (Line(points={{76,-678},{86,-678},{86,-680},{92,-680}},color={191,0,0}));
    annotation (
      Icon(
        coordinateSystem(
          preserveAspectRatio=false,
          extent={{-580,-760},{180,240}})),
      Diagram(
        coordinateSystem(
          preserveAspectRatio=false,
          extent={{-580,-760},{180,240}}),
        graphics={
          Rectangle(
            extent={{82,188},{156,-692}},
            lineColor={28,108,200},
            fillColor={28,108,200},
            fillPattern=FillPattern.CrossDiag),
          Text(
            extent={{80,198},{160,230}},
            lineColor={28,108,200},
            fillColor={28,108,200},
            fillPattern=FillPattern.CrossDiag,
            textString="Spawn")}),
      experiment(
        StopTime=604800,
        Interval=60,
        __Dymola_Algorithm="Dassl"));
  end SOM2_noSpawn_01;
  annotation (
    uses(
      Buildings(
        version="7.0.0"),
      ModelicaServices(
        version="3.2.3"),
      Modelica(
        version="3.2.3")));
end MODRLC_NoSpawn;
