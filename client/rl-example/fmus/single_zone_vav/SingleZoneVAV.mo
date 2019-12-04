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
    Room                                                           zon(
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
    Buildings.Utilities.IO.SignalExchange.Read TRooRad(
      y(unit="K"),
      description="Room rad temperature",
      KPIs=Buildings.Utilities.IO.SignalExchange.SignalTypes.SignalsForKPIs.RadiativeZoneTemperature)
      annotation (Placement(transformation(extent={{120,-38},{140,-18}})));
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
    connect(zon.TRooRad, TRooRad.u) annotation (Line(points={{81,-3.4},{99.5,
            -3.4},{99.5,-28},{118,-28}}, color={0,0,127}));
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

  model Room "BESTest Case 600 with fluid ports for air HVAC and internal load"

    replaceable package MediumA = Buildings.Media.Air "Medium model";

    parameter Modelica.SIunits.MassFlowRate mAir_flow_nominal
      "Design airflow rate of system";

    parameter Modelica.SIunits.Angle lat "Building latitude";

    parameter Modelica.SIunits.Angle S_=
      Buildings.Types.Azimuth.S "Azimuth for south walls";
    parameter Modelica.SIunits.Angle E_=
      Buildings.Types.Azimuth.E "Azimuth for east walls";
    parameter Modelica.SIunits.Angle W_=
      Buildings.Types.Azimuth.W "Azimuth for west walls";
    parameter Modelica.SIunits.Angle N_=
      Buildings.Types.Azimuth.N "Azimuth for north walls";
    parameter Modelica.SIunits.Angle C_=
      Buildings.Types.Tilt.Ceiling "Tilt for ceiling";
    parameter Modelica.SIunits.Angle F_=
      Buildings.Types.Tilt.Floor "Tilt for floor";
    parameter Modelica.SIunits.Angle Z_=
      Buildings.Types.Tilt.Wall "Tilt for wall";
    parameter Integer nConExtWin = 1 "Number of constructions with a window";
    parameter Integer nConBou = 1
      "Number of surface that are connected to constructions that are modeled inside the room";
    parameter Buildings.HeatTransfer.Data.OpaqueConstructions.Generic matExtWal(
      nLay=3,
      absIR_a=0.9,
      absIR_b=0.9,
      absSol_a=0.6,
      absSol_b=0.6,
      material={
        Buildings.HeatTransfer.Data.Solids.Generic(
          x=0.009,
          k=0.140,
          c=900,
          d=530,
          nStaRef=Buildings.ThermalZones.Detailed.Validation.BESTEST.nStaRef),
        Buildings.HeatTransfer.Data.Solids.Generic(
          x=0.066,
          k=0.040,
          c=840,
          d=12,
          nStaRef=Buildings.ThermalZones.Detailed.Validation.BESTEST.nStaRef),
        Buildings.HeatTransfer.Data.Solids.Generic(
          x=0.012,
          k=0.160,
          c=840,
          d=950,
          nStaRef=Buildings.ThermalZones.Detailed.Validation.BESTEST.nStaRef)})
      "Exterior wall"
      annotation (Placement(transformation(extent={{100,80},{114,94}})));

    parameter Buildings.HeatTransfer.Data.OpaqueConstructions.Generic matFlo(
      final nLay= 2,
      absIR_a=0.9,
      absIR_b=0.9,
      absSol_a=0.6,
      absSol_b=0.6,
      material={
        Buildings.HeatTransfer.Data.Solids.Generic(
          x=1.003,
          k=0.040,
          c=0,
          d=0,
          nStaRef=Buildings.ThermalZones.Detailed.Validation.BESTEST.nStaRef),
       Buildings.HeatTransfer.Data.Solids.Generic(
          x=0.025,
          k=0.140,
          c=1200,
          d=650,
          nStaRef=Buildings.ThermalZones.Detailed.Validation.BESTEST.nStaRef)})
      "Floor"
      annotation (Placement(transformation(extent={{160,80},{174,94}})));
    parameter Buildings.HeatTransfer.Data.Solids.Generic soil(
      x=2,
      k=1.3,
      c=800,
      d=1500) "Soil properties"
      annotation (Placement(transformation(extent={{100,60},{120,80}})));

    parameter Buildings.HeatTransfer.Data.OpaqueConstructions.Generic roof(
      nLay=3,
      absIR_a=0.9,
      absIR_b=0.9,
      absSol_a=0.6,
      absSol_b=0.6,
      material={
        Buildings.HeatTransfer.Data.Solids.Generic(
          x=0.019,
          k=0.140,
          c=900,
          d=530,
          nStaRef=Buildings.ThermalZones.Detailed.Validation.BESTEST.nStaRef),
       Buildings.HeatTransfer.Data.Solids.Generic(
          x=0.1118,
          k=0.040,
          c=840,
          d=12,
          nStaRef=Buildings.ThermalZones.Detailed.Validation.BESTEST.nStaRef),
       Buildings.HeatTransfer.Data.Solids.Generic(
          x=0.010,
          k=0.160,
          c=840,
          d=950,
          nStaRef=Buildings.ThermalZones.Detailed.Validation.BESTEST.nStaRef)})
      "Roof"
      annotation (Placement(transformation(extent={{140,80},{154,94}})));

    parameter Buildings.ThermalZones.Detailed.Validation.BESTEST.Data.Win600 window600(
      UFra=3,
      haveExteriorShade=false,
      haveInteriorShade=false) "Window"
      annotation (Placement(transformation(extent={{120,80},{134,94}})));
    Buildings.HeatTransfer.Conduction.SingleLayer soi(
      A=48,
      material=soil,
      steadyStateInitial=true,
      stateAtSurface_a=false,
      stateAtSurface_b=true,
      T_a_start=283.15,
      T_b_start=283.75) "2 m deep soil (per definition on p.4 of ASHRAE 140-2007)"
      annotation (Placement(transformation(
          extent={{12.5,-12.5},{-7.5,7.5}},
          rotation=-90,
          origin={70.5,-47.5})));

    Modelica.Fluid.Interfaces.FluidPort_a supplyAir(redeclare final package
        Medium = MediumA) "Supply air"
      annotation (Placement(transformation(extent={{-210,10},{-190,30}}),
          iconTransformation(extent={{-210,10},{-190,30}})));
    Modelica.Fluid.Interfaces.FluidPort_b returnAir(redeclare final package
        Medium = MediumA) "Return air"
      annotation (Placement(transformation(extent={{-210,-30},{-190,-10}}),
          iconTransformation(extent={{-210,-30},{-190,-10}})));

    Buildings.BoundaryConditions.WeatherData.Bus weaBus
      "Weather data bus"
      annotation (Placement(transformation(extent={{-148,172},{-132,188}}),
          iconTransformation(extent={{-148,172},{-132,188}})));

    Modelica.Blocks.Interfaces.RealOutput TRooAir "Room air temperature"
      annotation (Placement(transformation(extent={{200,-10},{220,10}}),
          iconTransformation(extent={{200,-10},{220,10}})));

    Buildings.ThermalZones.Detailed.MixedAir roo(
      redeclare package Medium = MediumA,
      nPorts=5,
      hRoo=2.7,
      nConExtWin=nConExtWin,
      nConBou=1,
      energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
      AFlo=48,
      datConBou(
        layers={matFlo},
        each A=48,
        each til=F_),
      datConExt(
        layers={roof,matExtWal,matExtWal,matExtWal},
        A={48,6*2.7,6*2.7,8*2.7},
        til={C_,Z_,Z_,Z_},
        azi={S_,W_,E_,N_}),
      nConExt=4,
      nConPar=0,
      nSurBou=0,
      datConExtWin(
        layers={matExtWal},
        A={8*2.7},
        glaSys={window600},
        wWin={2*3},
        hWin={2},
        fFra={0.001},
        til={Z_},
        azi={S_}),
      massDynamics=Modelica.Fluid.Types.Dynamics.SteadyState,
      lat=lat,
      intConMod=Buildings.HeatTransfer.Types.InteriorConvection.Temperature,
      extConMod=Buildings.HeatTransfer.Types.ExteriorConvection.TemperatureWind,
      steadyStateWindow=false)
      "Room model for Case 600"
      annotation (Placement(transformation(extent={{34,-26},{86,26}})));

    Modelica.Blocks.Sources.Constant qConGai_flow(k=192/48) "Convective heat gain"
      annotation (Placement(transformation(extent={{-120,90},{-100,110}})));

    Modelica.Blocks.Sources.Constant qRadGai_flow(k=288/48) "Radiative heat gain"
      annotation (Placement(transformation(extent={{-120,120},{-100,140}})));

    Modelica.Blocks.Routing.Multiplex3 mul "Multiplex"
      annotation (Placement(transformation(extent={{0,80},{22,102}})));

    Modelica.Blocks.Sources.Constant qLatGai_flow(k=96/48) "Latent heat gain"
      annotation (Placement(transformation(extent={{-120,60},{-100,80}})));
    Modelica.Thermal.HeatTransfer.Sources.FixedTemperature TSoi[nConBou](
      each T= 283.15) "Boundary condition for construction"
      annotation (Placement(transformation(
          extent={{0,0},{-20,20}},
          origin={140,-80})));

    Buildings.Fluid.Sources.MassFlowSource_WeatherData sinInf(
      redeclare package Medium = MediumA,
      nPorts=1,
      use_m_flow_in=true) "Sink model for air infiltration"
      annotation (Placement(transformation(extent={{-40,-20},{-20,0}})));
    Modelica.Blocks.Sources.Constant InfiltrationRate(k=48*2.7*0.5/3600)
      "0.41 ACH adjusted for the altitude (0.5 at sea level)"
      annotation (Placement(transformation(extent={{-180,-94},{-160,-74}})));
    Modelica.Blocks.Math.Product product
      annotation (Placement(transformation(extent={{-120,-100},{-100,-80}})));
    Buildings.Fluid.Sensors.Density density(redeclare package Medium = MediumA)
      "Air density inside the building"
      annotation (Placement(transformation(extent={{0,-100},{-20,-80}})));

    Modelica.Thermal.HeatTransfer.Sensors.TemperatureSensor senTZon
      "Zone air temperature sensor"
      annotation (Placement(transformation(extent={{160,-10},{180,10}})));

    Buildings.Fluid.Sources.MassFlowSource_WeatherData souInf(
      redeclare package Medium = MediumA,
      use_m_flow_in=true,
      nPorts=1) "Source model for air infiltration"
      annotation (Placement(transformation(extent={{-40,-60},{-20,-40}})));

    Buildings.Air.Systems.SingleZone.VAV.Examples.BaseClasses.InternalLoads intLoad
      "Internal loads"
      annotation (Placement(transformation(extent={{-120,150},{-100,170}})));
    Modelica.Thermal.HeatTransfer.Sensors.TemperatureSensor senTZonRad
      "Zone rad air temperature sensor"
      annotation (Placement(transformation(extent={{162,-40},{182,-20}})));
    Modelica.Blocks.Interfaces.RealOutput TRooRad "Room rad temperature"
      annotation (Placement(transformation(extent={{200,-40},{220,-20}}),
          iconTransformation(extent={{200,-44},{220,-24}})));
  protected
    Modelica.Blocks.Math.Product pro1 "Product for internal gain"
      annotation (Placement(transformation(extent={{-40,120},{-20,140}})));
    Modelica.Blocks.Math.Product pro2 "Product for internal gain"
      annotation (Placement(transformation(extent={{-40,60},{-20,80}})));
    Modelica.Blocks.Math.Product pro3 "Product for internal gain"
      annotation (Placement(transformation(extent={{-80,80},{-60,100}})));

    Modelica.Blocks.Math.Gain gaiInf(final k=-1) "Gain for infiltration"
      annotation (Placement(transformation(extent={{-80,-100},{-60,-80}})));

  equation
    connect(mul.y, roo.qGai_flow) annotation (Line(
        points={{23.1,91},{28,91},{28,10.4},{31.92,10.4}},
        color={0,0,127},
        smooth=Smooth.None));
    connect(density.port, roo.ports[1])  annotation (Line(
        points={{-10,-100},{2,-100},{2,-17.16},{40.5,-17.16}},
        color={0,127,255},
        smooth=Smooth.None));
    connect(density.d, product.u2) annotation (Line(
        points={{-21,-90},{-40,-90},{-40,-114},{-132,-114},{-132,-96},{-122,-96}},
        color={0,0,127},
        smooth=Smooth.None));
    connect(TSoi[1].port, soi.port_a) annotation (Line(
        points={{120,-70},{68,-70},{68,-60}},
        color={191,0,0},
        smooth=Smooth.None));
    connect(soi.port_b, roo.surf_conBou[1]) annotation (Line(
        points={{68,-40},{68,-20.8},{67.8,-20.8}},
        color={191,0,0},
        smooth=Smooth.None));

    connect(sinInf.ports[1], roo.ports[2]) annotation (Line(points={{-20,-10},{14,
            -10},{14,-15.08},{40.5,-15.08}},color={0,127,255}));
    connect(weaBus,sinInf. weaBus) annotation (Line(
        points={{-140,180},{-140,-10},{-40,-10},{-40,-9.8}},
        color={255,204,51},
        thickness=0.5), Text(
        textString="%first",
        index=-1,
        extent={{-6,3},{-6,3}}));
    connect(weaBus, roo.weaBus) annotation (Line(
        points={{-140,180},{82,180},{82,112},{83.27,112},{83.27,23.27}},
        color={255,204,51},
        thickness=0.5), Text(
        textString="%first",
        index=-1,
        extent={{-6,3},{-6,3}}));

    connect(senTZon.T, TRooAir) annotation (Line(points={{180,0},{210,0}},
                      color={0,0,127}));
    connect(senTZon.port, roo.heaPorAir) annotation (Line(points={{160,0},{58.7,0}},
                               color={191,0,0}));
    connect(qRadGai_flow.y, pro1.u1) annotation (Line(points={{-99,130},{-80,130},
            {-80,136},{-42,136}}, color={0,0,127}));
    connect(qLatGai_flow.y, pro2.u1) annotation (Line(points={{-99,70},{-70,70},{
            -70,76},{-42,76}}, color={0,0,127}));
    connect(qConGai_flow.y, pro3.u1) annotation (Line(points={{-99,100},{-94,100},
            {-94,96},{-82,96}}, color={0,0,127}));
    connect(intLoad.y[1], pro2.u2) annotation (Line(points={{-99,160},{-90,160},{
            -90,64},{-42,64}}, color={0,0,127}));
    connect(pro1.y, mul.u1[1]) annotation (Line(points={{-19,130},{-12,130},{-12,
            98.7},{-2.2,98.7}}, color={0,0,127}));
    connect(pro3.y, mul.u2[1]) annotation (Line(points={{-59,90},{-58,90},{-58,91},
            {-2.2,91}}, color={0,0,127}));
    connect(pro2.y, mul.u3[1]) annotation (Line(points={{-19,70},{-12,70},{-12,
            83.3},{-2.2,83.3}}, color={0,0,127}));
    connect(souInf.weaBus, weaBus) annotation (Line(
        points={{-40,-49.8},{-56,-49.8},{-56,-42},{-140,-42},{-140,180}},
        color={255,204,51},
        thickness=0.5));
    connect(souInf.ports[1], roo.ports[3]) annotation (Line(points={{-20,-50},{-6,
            -50},{-6,-13},{40.5,-13}},      color={0,127,255}));
    connect(product.y, gaiInf.u)
      annotation (Line(points={{-99,-90},{-82,-90}},     color={0,0,127}));
    connect(gaiInf.y, souInf.m_flow_in) annotation (Line(points={{-59,-90},{-46,-90},
            {-46,-42},{-40,-42}},          color={0,0,127}));
    connect(product.y, sinInf.m_flow_in) annotation (Line(points={{-99,-90},{-92,-90},
            {-92,-2},{-40,-2}},                color={0,0,127}));
    connect(supplyAir, roo.ports[4]) annotation (Line(points={{-200,20},{-120,20},
            {-120,48},{0,48},{0,-10.92},{40.5,-10.92}},color={0,127,255}));
    connect(returnAir, roo.ports[5]) annotation (Line(points={{-200,-20},{-114,-20},
            {-114,42},{-2,42},{-2,-8.84},{40.5,-8.84}},
          color={0,127,255}));
    connect(InfiltrationRate.y, product.u1)
      annotation (Line(points={{-159,-84},{-122,-84}}, color={0,0,127}));
    connect(intLoad.y[1], pro1.u2) annotation (Line(points={{-99,160},{-90,160},{
            -90,124},{-42,124}}, color={0,0,127}));
    connect(pro3.u2, intLoad.y[1]) annotation (Line(points={{-82,84},{-90,84},{-90,
            160},{-99,160}}, color={0,0,127}));
    connect(roo.heaPorRad, senTZonRad.port) annotation (Line(points={{58.7,
            -4.94},{111.35,-4.94},{111.35,-30},{162,-30}}, color={191,0,0}));
    connect(senTZonRad.T, TRooRad)
      annotation (Line(points={{182,-30},{210,-30}}, color={0,0,127}));
  annotation (Documentation(info="<html>
<p>
This is a single zone model based on the envelope of the BESTEST Case 600
building, though it has some modifications.  Supply and return air ports are
included for simulation with air-based HVAC systems.  Heating and cooling
setpoints and internal loads are time-varying according to an assumed
occupancy schedule.
</p>
<p>
This zone model utilizes schedules and constructions from
the <code>Schedules</code> and <code>Constructions</code> packages.
</p>
</html>",   revisions="<html>
<ul>
<li>
June 21, 2017, by Michael Wetter:<br/>
Refactored implementation.
</li>
<li>
June 1, 2017, by David Blum:<br/>
First implementation.
</li>
</ul>
</html>"),
      Diagram(coordinateSystem(extent={{-200,-200},{200,200}})),
      Icon(coordinateSystem(extent={{-200,-200},{200,200}}),
          graphics={
          Rectangle(
            extent={{-158,-160},{162,160}},
            lineColor={95,95,95},
            fillColor={95,95,95},
            fillPattern=FillPattern.Solid),
          Rectangle(
            extent={{-138,138},{142,-140}},
            pattern=LinePattern.None,
            lineColor={117,148,176},
            fillColor={170,213,255},
            fillPattern=FillPattern.Sphere),
          Rectangle(
            extent={{142,70},{162,-70}},
            lineColor={95,95,95},
            fillColor={255,255,255},
            fillPattern=FillPattern.Solid),
          Rectangle(
            extent={{148,70},{156,-70}},
            lineColor={95,95,95},
            fillColor={170,213,255},
            fillPattern=FillPattern.Solid)}));
  end Room;
  annotation (uses(Modelica(version="3.2.2"),
      IBPSA(version="3.0.0"),
      Buildings(version="7.0.0")),
    version="1",
    conversion(noneFromVersion=""));
end SingleZoneVAV;
