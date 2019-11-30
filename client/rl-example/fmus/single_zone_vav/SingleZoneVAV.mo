within ;
package SingleZoneVAV
  "This package contains models for the SingleZoneVAV testcase in BOPTEST."
  model TestCaseSupervisory
    "Based on Buildings.Air.Systems.SingleZone.VAV.Examples.ChillerDXHeatingEconomizer."

    package MediumA = Buildings.Media.Air "Buildings library air media package";
    package MediumW = Buildings.Media.Water "Buildings library air media package";

    parameter Modelica.SIunits.Temperature TSupChi_nominal=279.15
      "Design value for chiller leaving water temperature";

    Buildings.Air.Systems.SingleZone.VAV.ChillerDXHeatingEconomizerController con(
      minOAFra=0.2,
      kFan=4,
      kEco=4,
      kHea=4,
      TSupChi_nominal=TSupChi_nominal,
      TSetSupAir=286.15) "Controller"
      annotation (Placement(transformation(extent={{-112,-10},{-92,10}})));
    Buildings.Air.Systems.SingleZone.VAV.ChillerDXHeatingEconomizer hvac(
      redeclare package MediumA = MediumA,
      redeclare package MediumW = MediumW,
      mAir_flow_nominal=0.75,
      etaHea_nominal=0.99,
      QHea_flow_nominal=7000,
      QCoo_flow_nominal=-7000,
      TSupChi_nominal=TSupChi_nominal)   "Single zone VAV system"
      annotation (Placement(transformation(extent={{-38,-20},{2,20}})));
    Buildings.Air.Systems.SingleZone.VAV.Examples.BaseClasses.Room zon(
        mAir_flow_nominal=0.75,
        lat=weaDat.lat) "Thermal envelope of single zone"
      annotation (Placement(transformation(extent={{40,-20},{80,20}})));
    Buildings.BoundaryConditions.WeatherData.ReaderTMY3 weaDat(
        computeWetBulbTemperature=false, filNam=
          Modelica.Utilities.Files.loadResource(
          "Resources/weatherdata/DRYCOLD.mos"))
      annotation (Placement(transformation(extent={{-160,120},{-140,140}})));
    Modelica.Blocks.Continuous.Integrator EFan "Total fan energy"
      annotation (Placement(transformation(extent={{40,-50},{60,-30}})));
    Modelica.Blocks.Continuous.Integrator EHea "Total heating energy"
      annotation (Placement(transformation(extent={{40,-80},{60,-60}})));
    Modelica.Blocks.Continuous.Integrator ECoo "Total cooling energy"
      annotation (Placement(transformation(extent={{40,-110},{60,-90}})));
    Modelica.Blocks.Math.MultiSum EHVAC(nu=4)  "Total HVAC energy"
      annotation (Placement(transformation(extent={{80,-70},{100,-50}})));
    Modelica.Blocks.Continuous.Integrator EPum "Total pump energy"
      annotation (Placement(transformation(extent={{40,-140},{60,-120}})));

    Buildings.BoundaryConditions.WeatherData.Bus weaBus "Weather data bus"
      annotation (Placement(transformation(extent={{-134,120},{-114,140}})));

    Modelica.Blocks.Sources.CombiTimeTable TSetRooHea(
      smoothness=Modelica.Blocks.Types.Smoothness.ConstantSegments,
      extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
      table=[0,22 + 273.15; 8*3600,22 + 273.15; 18*3600,22 + 273.15; 24*3600,22
           + 273.15]) "Heating setpoint for room temperature"
      annotation (Placement(transformation(extent={{-180,20},{-160,40}})));
    Modelica.Blocks.Sources.CombiTimeTable TSetRooCoo(
      smoothness=Modelica.Blocks.Types.Smoothness.ConstantSegments,
      extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
      table=[0,23 + 273.15; 8*3600,23 + 273.15; 18*3600,23 + 273.15; 24*3600,23
           + 273.15]) "Cooling setpoint for room temperature"
      annotation (Placement(transformation(extent={{-180,-20},{-160,0}})));
    Buildings.Utilities.IO.SignalExchange.Overwrite
                             oveTSetRooHea(
                              u(
        unit="K",
        min=273.15 + 10,
        max=273.15 + 35), description="Heating setpoint")
      annotation (Placement(transformation(extent={{-152,20},{-132,40}})));
    Buildings.Utilities.IO.SignalExchange.Overwrite
                             oveTSetRooCoo(
                              u(
        unit="K",
        min=273.15 + 10,
        max=273.15 + 35), description="Cooling setpoint")
      annotation (Placement(transformation(extent={{-152,-20},{-132,0}})));
    Buildings.Utilities.IO.SignalExchange.Read
                        PPum(y(unit="W"),
      KPIs=Buildings.Utilities.IO.SignalExchange.SignalTypes.SignalsForKPIs.ElectricPower,
      description="Pump electrical power")
      annotation (Placement(transformation(extent={{120,70},{140,90}})));
    Buildings.Utilities.IO.SignalExchange.Read
                        PCoo(y(unit="W"),
      KPIs=Buildings.Utilities.IO.SignalExchange.SignalTypes.SignalsForKPIs.ElectricPower,
      description="Cooling electrical power")
      annotation (Placement(transformation(extent={{140,90},{160,110}})));
    Buildings.Utilities.IO.SignalExchange.Read
                        PHea(y(unit="W"),
      KPIs=Buildings.Utilities.IO.SignalExchange.SignalTypes.SignalsForKPIs.ElectricPower,
      description="Heater power")
      annotation (Placement(transformation(extent={{120,110},{140,130}})));
    Buildings.Utilities.IO.SignalExchange.Read
                        PFan(y(unit="W"),
      KPIs=Buildings.Utilities.IO.SignalExchange.SignalTypes.SignalsForKPIs.ElectricPower,
      description="Fan electrical power")
      annotation (Placement(transformation(extent={{140,130},{160,150}})));
    Buildings.Utilities.IO.SignalExchange.Read TRooAir(               y(unit="K"),
      KPIs=Buildings.Utilities.IO.SignalExchange.SignalTypes.SignalsForKPIs.AirZoneTemperature,
      description="Room air temperature")
      annotation (Placement(transformation(extent={{120,-10},{140,10}})));
    Buildings.Utilities.IO.SignalExchange.Read senTSetRooCoo(
      y(unit="K"),
      KPIs=Buildings.Utilities.IO.SignalExchange.SignalTypes.SignalsForKPIs.None,
      description="Room cooling setpoint")
      annotation (Placement(transformation(extent={{-10,-10},{10,10}},
          rotation=180,
          origin={-142,-36})));
    Buildings.Utilities.IO.SignalExchange.Read senTSetRooHea(
      y(unit="K"),
      KPIs=Buildings.Utilities.IO.SignalExchange.SignalTypes.SignalsForKPIs.None,
      description="Room heating setpoint")
      annotation (Placement(transformation(extent={{-10,-10},{10,10}},
          rotation=180,
          origin={-142,64})));
    Buildings.Utilities.IO.SignalExchange.Read ECumuHVAC(
      y(unit="Wh"),
      description="Cumulative HVAV Energy",
      KPIs=Buildings.Utilities.IO.SignalExchange.SignalTypes.SignalsForKPIs.None)
      annotation (Placement(transformation(extent={{120,-70},{140,-50}})));

    Buildings.Utilities.IO.SignalExchange.Read TOutdoorDB(
      KPIs=Buildings.Utilities.IO.SignalExchange.SignalTypes.SignalsForKPIs.None,
      y(unit="K"),
      description="Outdoor Drybulb")
      annotation (Placement(transformation(extent={{120,28},{140,48}})));

    Buildings.Utilities.IO.SignalExchange.Read senUSetFan(
      y(unit="K"),
      KPIs=Buildings.Utilities.IO.SignalExchange.SignalTypes.SignalsForKPIs.None,
      description="Fan Control Setpoint")
      annotation (Placement(transformation(extent={{-30,42},{-10,62}})));

    Buildings.Utilities.IO.SignalExchange.Overwrite oveUSetFan(u(
        unit="Fraction",
        min=0,
        max=10), description="Override Fan Control")
      annotation (Placement(transformation(extent={{-70,52},{-50,72}})));
  equation
    connect(weaDat.weaBus, weaBus) annotation (Line(
        points={{-140,130},{-124,130}},
        color={255,204,51},
        thickness=0.5), Text(
        string="%second",
        index=1,
        extent={{6,3},{6,3}}));

    connect(con.yHea, hvac.uHea) annotation (Line(points={{-91,6},{-56,6},{-56,
            12},{-40,12}},             color={0,0,127}));
    connect(con.yCooCoiVal, hvac.uCooVal) annotation (Line(points={{-91,0},{-54,
            0},{-54,5},{-40,5}},          color={0,0,127}));
    connect(con.yOutAirFra, hvac.uEco) annotation (Line(points={{-91,3},{-50,3},
            {-50,-2},{-40,-2}},            color={0,0,127}));
    connect(hvac.chiOn, con.chiOn) annotation (Line(points={{-40,-10},{-60,-10},
            {-60,-4},{-91,-4}},                               color={255,0,255}));
    connect(con.TSetSupChi, hvac.TSetChi) annotation (Line(points={{-91,-8},{
            -70,-8},{-70,-15},{-40,-15}},       color={0,0,127}));
    connect(con.TMix, hvac.TMix) annotation (Line(points={{-114,2},{-122,2},{
            -122,-40},{10,-40},{10,-4},{3,-4}},             color={0,0,127}));

    connect(hvac.supplyAir, zon.supplyAir) annotation (Line(points={{2,8},{10,8},
            {10,2},{40,2}},          color={0,127,255}));
    connect(hvac.returnAir, zon.returnAir) annotation (Line(points={{2,0},{6,0},
            {6,-2},{40,-2}},         color={0,127,255}));

    connect(con.TOut, weaBus.TDryBul) annotation (Line(points={{-114,-2},{-124,
            -2},{-124,130}},              color={0,0,127}));
    connect(hvac.weaBus, weaBus) annotation (Line(
        points={{-34,17.8},{-34,130},{-124,130}},
        color={255,204,51},
        thickness=0.5));
    connect(zon.weaBus, weaBus) annotation (Line(
        points={{46,18},{42,18},{42,130},{-124,130}},
        color={255,204,51},
        thickness=0.5));
    connect(con.TSup, hvac.TSup) annotation (Line(points={{-114,-9},{-118,-9},{
            -118,-32},{4,-32},{4,-8},{3,-8}},
          color={0,0,127}));
    connect(con.TRoo, zon.TRooAir) annotation (Line(points={{-114,-6},{-120,-6},
            {-120,-36},{6,-36},{6,-22},{90,-22},{90,0},{81,0}},     color={0,0,
            127}));

    connect(hvac.PFan, EFan.u) annotation (Line(points={{3,18},{24,18},{24,-40},
            {38,-40}}, color={0,0,127}));
    connect(hvac.QHea_flow, EHea.u) annotation (Line(points={{3,16},{22,16},{22,
            -70},{38,-70}},
                       color={0,0,127}));
    connect(hvac.PCoo, ECoo.u) annotation (Line(points={{3,14},{20,14},{20,-100},
            {38,-100}},color={0,0,127}));
    connect(hvac.PPum, EPum.u) annotation (Line(points={{3,12},{18,12},{18,-130},
            {38,-130}},  color={0,0,127}));

    connect(EFan.y, EHVAC.u[1]) annotation (Line(points={{61,-40},{70,-40},{70,-54.75},
            {80,-54.75}},         color={0,0,127}));
    connect(EHea.y, EHVAC.u[2])
      annotation (Line(points={{61,-70},{64,-70},{64,-60},{66,-60},{66,-60},{80,-60},
            {80,-58.25}},                                      color={0,0,127}));
    connect(ECoo.y, EHVAC.u[3]) annotation (Line(points={{61,-100},{70,-100},{70,-61.75},
            {80,-61.75}},         color={0,0,127}));
    connect(EPum.y, EHVAC.u[4]) annotation (Line(points={{61,-130},{74,-130},{74,-65.25},
            {80,-65.25}},         color={0,0,127}));
    connect(TSetRooHea.y[1], oveTSetRooHea.u)
      annotation (Line(points={{-159,30},{-154,30}}, color={0,0,127}));
    connect(oveTSetRooHea.y, con.TSetRooHea) annotation (Line(points={{-131,30},
            {-126,30},{-126,10},{-114,10}}, color={0,0,127}));
    connect(TSetRooCoo.y[1], oveTSetRooCoo.u)
      annotation (Line(points={{-159,-10},{-154,-10}}, color={0,0,127}));
    connect(oveTSetRooCoo.y, con.TSetRooCoo) annotation (Line(points={{-131,-10},
            {-126,-10},{-126,6},{-114,6}}, color={0,0,127}));
    connect(hvac.PPum, PPum.u) annotation (Line(points={{3,12},{18,12},{18,80},
            {118,80}}, color={0,0,127}));
    connect(hvac.PCoo, PCoo.u) annotation (Line(points={{3,14},{14,14},{14,100},
            {138,100}}, color={0,0,127}));
    connect(hvac.QHea_flow, PHea.u) annotation (Line(points={{3,16},{10,16},{10,
            120},{118,120}}, color={0,0,127}));
    connect(hvac.PFan, PFan.u) annotation (Line(points={{3,18},{6,18},{6,140},{
            138,140}}, color={0,0,127}));
    connect(zon.TRooAir, TRooAir.u)
      annotation (Line(points={{81,0},{118,0}}, color={0,0,127}));
    connect(oveTSetRooCoo.y, senTSetRooCoo.u) annotation (Line(points={{-131,
            -10},{-126,-10},{-126,-36},{-130,-36}}, color={0,0,127}));
    connect(oveTSetRooHea.y, senTSetRooHea.u) annotation (Line(points={{-131,30},
            {-126,30},{-126,64},{-130,64}}, color={0,0,127}));
    connect(EHVAC.y, ECumuHVAC.u)
      annotation (Line(points={{101.7,-60},{118,-60}}, color={0,0,127}));
    connect(TOutdoorDB.u, weaBus.TDryBul) annotation (Line(points={{118,38},{
            -124,38},{-124,130}}, color={0,0,127}), Text(
        string="%second",
        index=1,
        extent={{-6,3},{-6,3}},
        horizontalAlignment=TextAlignment.Right));
    connect(con.yFan, oveUSetFan.u) annotation (Line(points={{-91,9},{-91,18.5},
            {-72,18.5},{-72,62}}, color={0,0,127}));
    connect(oveUSetFan.y, hvac.uFan) annotation (Line(points={{-49,62},{-46,62},
            {-46,18},{-40,18}}, color={0,0,127}));
    connect(senUSetFan.u, hvac.uFan) annotation (Line(points={{-32,52},{-40,52},
            {-40,28},{-46,28},{-46,18},{-40,18}}, color={0,0,127}));
    annotation (
      experiment(
        StopTime=504800,
        Interval=3600,
        Tolerance=1e-06),
        __Dymola_Commands(file="modelica://Buildings/Resources/Scripts/Dymola/Air/Systems/SingleZone/VAV/Examples/ChillerDXHeatingEconomizer.mos"
          "Simulate and plot"),
       Documentation(info="<html>
<p>
The thermal zone is based on the BESTEST Case 600 envelope, while the HVAC
system is based on a conventional VAV system with air cooled chiller and
economizer.  See documentation for the specific models for more information.
</p>
</html>",   revisions="<html>
<ul>
<li>
September 14, 2018, by David Blum:<br/>
First implementation.
</li>
</ul>
</html>"),
      Diagram(coordinateSystem(extent={{-160,-160},{120,140}})),
      Icon(coordinateSystem(extent={{-160,-160},{120,140}}), graphics={
          Rectangle(
            extent={{-160,140},{120,-160}},
            lineColor={0,0,0},
            fillColor={255,255,255},
            fillPattern=FillPattern.Solid),
          Polygon(lineColor = {0,0,255},
                  fillColor = {75,138,73},
                  pattern = LinePattern.None,
                  fillPattern = FillPattern.Solid,
                  points = {{-36,60},{64,0},{-36,-60},{-36,60}}),
          Ellipse(lineColor = {75,138,73},
                  fillColor={255,255,255},
                  fillPattern = FillPattern.Solid,
                  extent={{-116,-110},{84,90}}),
          Polygon(lineColor = {0,0,255},
                  fillColor = {75,138,73},
                  pattern = LinePattern.None,
                  fillPattern = FillPattern.Solid,
                  points={{-52,50},{48,-10},{-52,-70},{-52,50}})}));
  end TestCaseSupervisory;

  annotation (uses(Modelica(version="3.2.2"),
      IBPSA(version="3.0.0"),
      Buildings(version="7.0.0")),
    version="1",
    conversion(noneFromVersion=""));
end SingleZoneVAV;
