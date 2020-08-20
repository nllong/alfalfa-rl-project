within spawn_fmu_control.Loads.B5a6b99ec37f4de7f94020090;
model coupling
  "Example illustrating the coupling of Spawn building loads infinite cooling and heating sources with no ETS"
  extends Modelica.Icons.Example;
  package MediumW=Buildings.Media.Water
    "Source side medium";
  building bui(
    T_aChiWat_nominal=280.15,
    T_bChiWat_nominal=285.15,
    nPorts_aHeaWat=1,
    nPorts_bHeaWat=1,
    nPorts_aChiWat=1,
    nPorts_bChiWat=1,
    have_pum=true)
    "Building spawn model"
    annotation (Placement(transformation(extent={{40,-40},{60,-20}})));
  Buildings.Fluid.Sources.Boundary_pT sinHeaWat(
    redeclare package Medium=MediumW,
    nPorts=1)
    "Sink for heating water"
    annotation (Placement(transformation(extent={{10,-10},{-10,10}},rotation=0,origin={136,-54})));
  Buildings.Fluid.Sources.Boundary_pT sinChiWat(
    redeclare package Medium=MediumW,
    nPorts=1)
    "Sink for chilled water"
    annotation (Placement(transformation(extent={{10,-10},{-10,10}},rotation=0,origin={136,-84})));
  Modelica.Blocks.Sources.RealExpression THeaWatSup(
    y=max(
      bui.terUni.T_aHeaWat_nominal))
    "Heating water supply temperature"
    annotation (Placement(transformation(extent={{-106,-60},{-86,-40}})));
  Modelica.Blocks.Sources.RealExpression TChiWatSup(
    y=min(
      bui.terUni.T_aChiWat_nominal))
    "Chilled water supply temperature"
    annotation (Placement(transformation(extent={{-108,-88},{-88,-68}})));
  Buildings.Fluid.Sources.Boundary_pT supHeaWat(
    redeclare package Medium=MediumW,
    use_T_in=true,
    nPorts=1)
    "Heating water supply"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},rotation=0,origin={-44,-50})));
  Buildings.Fluid.Sources.Boundary_pT supChiWat(
    redeclare package Medium=MediumW,
    use_T_in=true,
    nPorts=1)
    "Chilled water supply"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},rotation=0,origin={-44,-80})));
  Buildings.Utilities.IO.SignalExchange.Read
                      PPum(
    y(unit="W"),
    KPIs=Buildings.Utilities.IO.SignalExchange.SignalTypes.SignalsForKPIs.ElectricPower,

    description="Pump electrical power")
    annotation (Placement(transformation(extent={{138,38},{158,58}})));
  Buildings.Utilities.IO.SignalExchange.Read
                      PHea(
    y(unit="W"),
    KPIs=Buildings.Utilities.IO.SignalExchange.SignalTypes.SignalsForKPIs.ElectricPower,

    description="Heater power")
    annotation (Placement(transformation(extent={{138,14},{158,34}})));
  Buildings.Utilities.IO.SignalExchange.Read
                      PCoo(
    y(unit="W"),
    KPIs=Buildings.Utilities.IO.SignalExchange.SignalTypes.SignalsForKPIs.ElectricPower,

    description="Cooling electrical power")
    annotation (Placement(transformation(extent={{138,-12},{158,8}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant TSetZn1(k=20 + 273)
    "Minimum temperature setpoint"
    annotation (Placement(transformation(extent={{-110,34},{-90,54}})));
  Buildings.Utilities.IO.SignalExchange.Overwrite oveTSetZn1(u(
      unit="K",
      min=273.15 + 10,
      max=273.15 + 35), description="Heating setpoint")
    annotation (Placement(transformation(extent={{-62,34},{-42,54}})));
  Buildings.Utilities.IO.SignalExchange.Read senTSetZn1(
    y(unit="K"),
    KPIs=Buildings.Utilities.IO.SignalExchange.SignalTypes.SignalsForKPIs.None,

    description="Room heating setpoint") annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={-52,16})));
equation
   connect(supHeaWat.T_in,THeaWatSup.y)
    annotation (Line(points={{-56,-46},{-78,-46},{-78,-50},{-85,-50}},
                                                                  color={0,0,127}));
  connect(TChiWatSup.y,supChiWat.T_in)
    annotation (Line(points={{-87,-78},{-70,-78},{-70,-76},{-56,-76}},color={0,0,127}));
  connect(bui.ports_bChiWat[1],sinChiWat.ports[1])
    annotation (Line(points={{60,-36},{96,-36},{96,-84},{126,-84}},  color={0,127,255}));
  connect(bui.ports_bHeaWat[1],sinHeaWat.ports[1])
    annotation (Line(points={{60,-32},{104,-32},{104,-54},{126,-54}},
                                                                   color={0,127,255}));
  connect(supHeaWat.ports[1],bui.ports_aHeaWat[1])
    annotation (Line(points={{-34,-50},{-10,-50},{-10,-32},{40,-32}},
                                                                   color={0,127,255}));
  connect(supChiWat.ports[1],bui.ports_aChiWat[1])
    annotation (Line(points={{-34,-80},{-10,-80},{-10,-36},{40,-36}},color={0,127,255}));
  connect(bui.PPum, PPum.u) annotation (Line(points={{60.6667,-28},{60.6667,47},
          {136,47},{136,48}}, color={0,0,127}));
  connect(bui.QHea_flow, PHea.u) annotation (Line(points={{60.6667,-21.3333},{
          64.3333,-21.3333},{64.3333,24},{136,24}}, color={0,0,127}));
  connect(bui.QCoo_flow, PCoo.u) annotation (Line(points={{60.6667,-22.6667},{
          60.6667,-2.3333},{136,-2.3333},{136,-2}}, color={0,0,127}));
  connect(TSetZn1.y, oveTSetZn1.u)
    annotation (Line(points={{-88,44},{-64,44}}, color={0,0,127}));
  connect(oveTSetZn1.y, bui.THeaZn1) annotation (Line(points={{-41,44},{-2,44},
          {-2,-23.9333},{40.0667,-23.9333}}, color={0,0,127}));
  connect(senTSetZn1.u, bui.THeaZn1) annotation (Line(points={{-40,16},{-40,44},
          {-2,44},{-2,-23.9333},{40.0667,-23.9333}}, color={0,0,127}));
  annotation (
    Diagram(
      coordinateSystem(
        preserveAspectRatio=false,
        extent={{-120,-100},{160,60}}),
      graphics={
        Text(
          extent={{-46,36},{86,10}},
          lineColor={28,108,200},
          textString="")}),
    __Dymola_Commands(
      file="modelica://spawn_fmu_control/Loads/Resources/Scripts/B5a6b99ec37f4de7f94020090/Dymola/RunSpawnCouplingBuilding.mos"  "Simulate and plot"),
    experiment(
      StopTime=604800,
      Tolerance=1e-06),
    Documentation(
      info="<html>
<p>
This example illustrates the use of
<a href=\"modelica://Buildings.Applications.DHC.Loads.BaseClasses.PartialBuilding\">
Buildings.Applications.DHC.Loads.BaseClasses.PartialBuilding</a>,
<a href=\"modelica://Buildings.Applications.DHC.Loads.BaseClasses.PartialTerminalUnit\">
Buildings.Applications.DHC.Loads.BaseClasses.PartialTerminalUnit</a>
and
<a href=\"modelica://Buildings.Applications.DHC.Loads.FlowDistribution\">
Buildings.Applications.DHC.Loads.FlowDistribution</a>
in a configuration with:
</p>
<ul>
<li>
six-zone building model based on EnergyPlus envelope model (from
GeoJSON export),
</li>
<li>
secondary pumps.
</li>
</ul>
<p>
Simulation with Dymola requires minimum version 2020x and setting
<code>Hidden.AvoidDoubleComputation=true</code>, see
<a href=\"modelica://Buildings.ThermalZones.EnergyPlus.UsersGuide\">
Buildings.ThermalZones.EnergyPlus.UsersGuide</a>.
</p>
</html>",
      revisions="<html>
<ul>
<li>
March 21, 2020, by Nicholas Long:<br/>
GeoJson-Modelica translator template first implementation, infinite source to building (no ETS).
</li>
<li>
February 21, 2020, by Antoine Gautier:<br/>
Model first implementation.
</li>
</ul>
</html>"));
end coupling;
