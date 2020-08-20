within spawn_fmu_control.Loads.B5a6b99ec37f4de7f94020090;
model building
  "n-zone EnergyPlus building model based on URBANopt GeoJSON export, with distribution pumps"
  extends Buildings.Applications.DHC.Loads.BaseClasses.PartialBuilding(
    redeclare package Medium=Buildings.Media.Water,
    final have_eleHea=false,
    final have_eleCoo=false,
    final have_weaBus=false);
  replaceable package MediumW=Buildings.Media.Water
    "Source side medium";
  replaceable package MediumA=Buildings.Media.Air
    "Load side medium";
  parameter Integer nZon=5
    "Number of conditioned thermal zones";
  parameter Integer facSca[nZon]=fill(
    5,
    nZon)
    "Scaling factor to be applied to on each extensive quantity";
  parameter Modelica.SIunits.MassFlowRate mLoa_flow_nominal[nZon]={(-1*QCoo_flow_nominal[i]*0.22)/(3500) for i in 1:nZon}
    "Load side mass flow rate at nominal conditions"
    annotation (Dialog(group="Nominal condition"));
  parameter Modelica.SIunits.TemperatureDifference delTBuiCoo=5
    "Nominal building supply and return chilled water temperature difference";
  parameter Modelica.SIunits.TemperatureDifference delTDisCoo=9
    "Nominal district supply and return water temperature difference";
  parameter Modelica.SIunits.Temperature T_aChiWat_nominal
    "Supply chilled water nominal temperature";
  parameter Modelica.SIunits.Temperature T_bChiWat_nominal
    "Return chilled water nominal temperature";
  parameter Modelica.SIunits.HeatFlowRate QHea_flow_nominal[nZon]=fill(
    3000,
    nZon) ./ facSca
    "Design heating heat flow rate (>=0)"
    annotation (Dialog(group="Nominal condition"));
  parameter Modelica.SIunits.HeatFlowRate QCoo_flow_nominal[nZon]=fill(
    -8750,
    nZon) ./ facSca
    "Design cooling heat flow rate (<=0)"
    annotation (Dialog(group="Nominal condition"));
  parameter String idfName="modelica://spawn_fmu_control/Loads/Resources/Data/B5a6b99ec37f4de7f94020090/RefBldgSmallOfficeNew2004_Chicago.idf"
    "Path of the IDF file";
  parameter String weaName="modelica://spawn_fmu_control/Loads/Resources/Data/B5a6b99ec37f4de7f94020090/USA_IL_Chicago-OHare.Intl.AP.725300_TMY3.mos"
    "Path of the weather file";
  // TODO: Minimum and Maximum TSet: make a function of the outdoor air temperature, type of building,occupancy schedule or woking/idle days?
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant minTSet[nZon](k=fill(20
         + 273.15, nZon)) "Minimum temperature setpoint"
    annotation (Placement(transformation(extent={{-288,82},{-268,102}})));
    // TODO: Dehardcode
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant maxTSet[nZon](
    k=fill(
      24+273.15,
      nZon))
    "Maximum temperature setpoint"
    annotation (Placement(transformation(extent={{-220,20},{-200,40}})));
    // TODO: Dehardcode
  Modelica.Blocks.Sources.Constant qConGai_flow(
    k=0)
    "Convective heat gain"
    annotation (Placement(transformation(extent={{-66,128},{-46,148}})));
  Modelica.Blocks.Sources.Constant qRadGai_flow(
    k=0)
    "Radiative heat gain"
    annotation (Placement(transformation(extent={{-66,168},{-46,188}})));
  Modelica.Blocks.Routing.Multiplex3 multiplex3_1
    annotation (Placement(transformation(extent={{-20,128},{0,148}})));
  Modelica.Blocks.Sources.Constant qLatGai_flow(
    k=0)
    "Latent heat gain"
    annotation (Placement(transformation(extent={{-66,88},{-46,108}})));
  // TODO: apply a dynamic layout
  Buildings.ThermalZones.EnergyPlus.ThermalZone znCore_ZN(
    redeclare package Medium=MediumA,
    nPorts=2,
    zoneName="Core_ZN")
    "Thermal zone"
     annotation (Placement(transformation(extent={{40,6},{80,46}})));
  Buildings.ThermalZones.EnergyPlus.ThermalZone znPerimeter_ZN_1(
    redeclare package Medium=MediumA,
    nPorts=2,
    zoneName="Perimeter_ZN_1")
    "Thermal zone"
     annotation (Placement(transformation(extent={{40,60},{80,100}})));
  Buildings.ThermalZones.EnergyPlus.ThermalZone znPerimeter_ZN_2(
    redeclare package Medium=MediumA,
    nPorts=2,
    zoneName="Perimeter_ZN_2")
    "Thermal zone"
     annotation (Placement(transformation(extent={{40,-50},{80,-10}})));
  Buildings.ThermalZones.EnergyPlus.ThermalZone znPerimeter_ZN_3(
    redeclare package Medium=MediumA,
    nPorts=2,
    zoneName="Perimeter_ZN_3")
    "Thermal zone"
     annotation (Placement(transformation(extent={{38,-102},{78,-62}})));
  Buildings.ThermalZones.EnergyPlus.ThermalZone znPerimeter_ZN_4(
    redeclare package Medium=MediumA,
    nPorts=2,
    zoneName="Perimeter_ZN_4")
    "Thermal zone"
     annotation (Placement(transformation(extent={{40,-150},{80,-110}})));
  inner Buildings.ThermalZones.EnergyPlus.Building building(
    idfName=Modelica.Utilities.Files.loadResource(
      idfName),
    weaName=Modelica.Utilities.Files.loadResource(
      weaName),
    showWeatherData=false)
    "Building outer component"
    annotation (Placement(transformation(extent={{-250,254},{-230,274}})));
  Buildings.Controls.OBC.CDL.Continuous.MultiSum mulSum(
    nin=nZon)
    annotation (Placement(transformation(extent={{260,110},{280,130}})));
  Buildings.Controls.OBC.CDL.Continuous.MultiSum mulSum3(
    nin=2) if have_pum
    annotation (Placement(transformation(extent={{260,70},{280,90}})));
  Buildings.Applications.DHC.Loads.Examples.BaseClasses.FanCoil4Pipe terUni[nZon](
    each T_aChiWat_nominal=T_aChiWat_nominal,
    each T_bChiWat_nominal=T_bChiWat_nominal,
    redeclare each final package Medium1=MediumW,
    redeclare each final package Medium2=MediumA,
    each fan(
      show_T=true),
    final facSca=facSca,
    final QHea_flow_nominal=QHea_flow_nominal,
    final QCoo_flow_nominal=QCoo_flow_nominal,
    each T_aLoaHea_nominal=293.15,
    each T_aLoaCoo_nominal=297.15,
    each T_bHeaWat_nominal=308.15,
    each T_aHeaWat_nominal=313.15,
    final mLoaHea_flow_nominal=mLoa_flow_nominal,
    final mLoaCoo_flow_nominal=mLoa_flow_nominal)
    "Terminal unit"
    annotation (Placement(transformation(extent={{-140,-2},{-120,20}})));
  Buildings.Applications.DHC.Loads.FlowDistribution disFloHea(
    redeclare package Medium=MediumW,
    m_flow_nominal=sum(
      terUni.mHeaWat_flow_nominal .* terUni.facSca),
    have_pum=have_pum,
    dp_nominal=100000,
    nPorts_a1=nZon,
    nPorts_b1=nZon)
    "Heating water distribution system"
    annotation (Placement(transformation(extent={{-236,-188},{-216,-168}})));
  Buildings.Applications.DHC.Loads.FlowDistribution disFloCoo(
    redeclare package Medium=MediumW,
    m_flow_nominal=sum(
      terUni.mChiWat_flow_nominal .* terUni.facSca),
    typDis=Buildings.Applications.DHC.Loads.Types.DistributionType.ChilledWater,
    dp_nominal=100000,
    have_pum=have_pum,
    nPorts_a1=nZon,
    nPorts_b1=nZon)
    "Chilled water distribution system"
    annotation (Placement(transformation(extent={{-160,-230},{-140,-210}})));
  Modelica.Blocks.Interfaces.RealInput THeaZn1
    annotation (Placement(transformation(extent={{-318,162},{-278,202}})));
equation
   connect(qRadGai_flow.y,multiplex3_1.u1[1])
    annotation (Line(points={{-45,178},{-26,178},{-26,145},{-22,145}},color={0,0,127},smooth=Smooth.None));
  connect(qConGai_flow.y,multiplex3_1.u2[1])
    annotation (Line(points={{-45,138},{-22,138}},smooth=Smooth.None));
  connect(qLatGai_flow.y,multiplex3_1.u3[1])
    annotation (Line(points={{-45,98},{-26,98},{-26,131},{-22,131}},color={0,0,127}));
  connect(disFloHea.port_a,ports_aHeaWat[1])
    annotation (Line(points={{-236,-178},{-280,-178},{-280,-60},{-300,-60}},
                                                                        color={0,127,255}));
  connect(disFloHea.port_b,ports_bHeaWat[1])
    annotation (Line(points={{-216,-178},{260,-178},{260,-60},{300,-60}},
                                                                     color={0,127,255}));
  connect(disFloCoo.port_a,ports_aChiWat[1])
    annotation (Line(points={{-160,-220},{-280,-220},{-280,-260},{-300,-260}},
                                                                        color={0,127,255}));
  connect(disFloCoo.port_b,ports_bChiWat[1])
    annotation (Line(points={{-140,-220},{280,-220},{280,-260},{300,-260}},
                                                                     color={0,127,255}));
  connect(mulSum.y,PFan)
    annotation (Line(points={{282,120},{302,120},{302,120},{320,120}},color={0,0,127}));
  if have_pum then
    connect(PPum,mulSum3.y)
      annotation (Line(points={{320,80},{302,80},{302,80},{282,80}},color={0,0,127}));
    connect(disFloHea.PPum,mulSum3.u[1])
      annotation (Line(points={{-215,-186},{220.5,-186},{220.5,81},{258,81}},color={0,0,127}));
    connect(disFloCoo.PPum,mulSum3.u[2])
      annotation (Line(points={{-139,-228},{224,-228},{224,79},{258,79}},color={0,0,127}));
  end if;
  connect(disFloHea.QActTot_flow,QHea_flow)
    annotation (Line(points={{-215,-184},{-2,-184},{-2,-182},{212,-182},{212,280},{320,280}},color={0,0,127}));
  connect(disFloCoo.QActTot_flow,QCoo_flow)
    annotation (Line(points={{-139,-226},{28,-226},{28,-224},{216,-224},{216,240},{320,240}},color={0,0,127}));
  for i in 1:nZon loop
    connect(terUni[i].PFan,mulSum.u[i])
       annotation (Line(points={{-119.167,9},{-100,9},{-100,220},{220,220},{220,
            120},{258,120}},                                                                            color={0,0,127}));
    connect(disFloCoo.ports_a1[i],terUni[i].port_bChiWat)
       annotation (Line(points={{-140,-214},{-38,-214},{-38,1.66667},{-120,1.66667}},color={0,127,255}));
    connect(disFloCoo.ports_b1[i],terUni[i].port_aChiWat)
       annotation (Line(points={{-160,-214},{-260,-214},{-260,1.66667},{-140,1.66667}},color={0,127,255}));
    connect(disFloHea.ports_a1[i],terUni[i].port_bHeaWat)
       annotation (Line(points={{-216,-172},{-40,-172},{-40,-0.166667},{-120,-0.166667}},color={0,127,255}));
    connect(disFloHea.ports_b1[i],terUni[i].port_aHeaWat)
       annotation (Line(points={{-236,-172},{-260,-172},{-260,-0.166667},{-140,-0.166667}},color={0,127,255}));
    connect(terUni[i].mReqChiWat_flow,disFloCoo.mReq_flow[i])
       annotation (Line(points={{-119.167,3.5},{-104,3.5},{-104,-80},{-180,-80},
            {-180,-224},{-161,-224}},                                                                    color={0,0,127}));
    connect(terUni[i].mReqHeaWat_flow,disFloHea.mReq_flow[i])
       annotation (Line(points={{-119.167,5.33333},{-100,5.33333},{-100,-90.5},
            {-237,-90.5},{-237,-182}},                                                                   color={0,0,127}));

    connect(terUni[i].TSetCoo,maxTSet[i].y)
       annotation (Line(points={{-140.833,12.6667},{-164,12.6667},{-164,30},{
            -198,30}},                                                                 color={0,0,127}));
  end for;
  //----------------Depending on number of thermal zones-----------------
  connect(multiplex3_1.y,znCore_ZN.qGai_flow)
     annotation (Line(points={{1,138},{20,138},{20,36},{38,36}},color={0,0,127}));
  connect(znCore_ZN.ports[1],terUni[1].port_aLoa)
     annotation (Line(points={{58,6.9},{-8,6.9},{-8,18.1667},{-120,18.1667}},      color={0,127,255}));
  connect(znCore_ZN.ports[2],terUni[1].port_bLoa)
     annotation (Line(points={{62,6.9},{-20,6.9},{-20,18.1667},{-140,18.1667}},      color={0,127,255}));
  connect(znCore_ZN.TAir,terUni[1].TSen)
     annotation (Line(points={{81,39.8},{80,39.8},{80,160},{-152,160},{-152,
          10.8333},{-140.833,10.8333}},                                                                  color={0,0,127}));
  connect(multiplex3_1.y,znPerimeter_ZN_1.qGai_flow)
     annotation (Line(points={{1,138},{20,138},{20,90},{38,90}},color={0,0,127}));
  connect(znPerimeter_ZN_1.ports[1],terUni[2].port_aLoa)
     annotation (Line(points={{58,60.9},{-8,60.9},{-8,18.1667},{-120,18.1667}},    color={0,127,255}));
  connect(znPerimeter_ZN_1.ports[2],terUni[2].port_bLoa)
     annotation (Line(points={{62,60.9},{-20,60.9},{-20,18.1667},{-140,18.1667}},    color={0,127,255}));
  connect(znPerimeter_ZN_1.TAir,terUni[2].TSen)
     annotation (Line(points={{81,93.8},{80,93.8},{80,160},{-152,160},{-152,
          10.8333},{-140.833,10.8333}},                                                                  color={0,0,127}));
  connect(multiplex3_1.y,znPerimeter_ZN_2.qGai_flow)
     annotation (Line(points={{1,138},{20,138},{20,-20},{38,-20}},
                                                                color={0,0,127}));
  connect(znPerimeter_ZN_2.ports[1],terUni[3].port_aLoa)
     annotation (Line(points={{58,-49.1},{-8,-49.1},{-8,18.1667},{-120,18.1667}},  color={0,127,255}));
  connect(znPerimeter_ZN_2.ports[2],terUni[3].port_bLoa)
     annotation (Line(points={{62,-49.1},{-20,-49.1},{-20,18.1667},{-140,
          18.1667}},                                                                 color={0,127,255}));
  connect(znPerimeter_ZN_2.TAir,terUni[3].TSen)
     annotation (Line(points={{81,-16.2},{80,-16.2},{80,160},{-152,160},{-152,
          10.8333},{-140.833,10.8333}},                                                                  color={0,0,127}));
  connect(multiplex3_1.y,znPerimeter_ZN_3.qGai_flow)
     annotation (Line(points={{1,138},{20,138},{20,-72},{36,-72}},
                                                                color={0,0,127}));
  connect(znPerimeter_ZN_3.ports[1],terUni[4].port_aLoa)
     annotation (Line(points={{56,-101.1},{-8,-101.1},{-8,18.1667},{-120,
          18.1667}},                                                               color={0,127,255}));
  connect(znPerimeter_ZN_3.ports[2],terUni[4].port_bLoa)
     annotation (Line(points={{60,-101.1},{-20,-101.1},{-20,18.1667},{-140,
          18.1667}},                                                                 color={0,127,255}));
  connect(znPerimeter_ZN_3.TAir,terUni[4].TSen)
     annotation (Line(points={{79,-68.2},{80,-68.2},{80,160},{-152,160},{-152,
          10.8333},{-140.833,10.8333}},                                                                  color={0,0,127}));
  connect(multiplex3_1.y,znPerimeter_ZN_4.qGai_flow)
     annotation (Line(points={{1,138},{20,138},{20,-120},{38,-120}},
                                                                color={0,0,127}));
  connect(znPerimeter_ZN_4.ports[1],terUni[5].port_aLoa)
     annotation (Line(points={{58,-149.1},{-8,-149.1},{-8,18.1667},{-120,
          18.1667}},                                                               color={0,127,255}));
  connect(znPerimeter_ZN_4.ports[2],terUni[5].port_bLoa)
     annotation (Line(points={{62,-149.1},{-20,-149.1},{-20,18.1667},{-140,
          18.1667}},                                                                 color={0,127,255}));
  connect(znPerimeter_ZN_4.TAir,terUni[5].TSen)
     annotation (Line(points={{81,-116.2},{80,-116.2},{80,160},{-152,160},{-152,
          10.8333},{-140.833,10.8333}},                                                                  color={0,0,127}));
  connect(minTSet[2].y, terUni[2].TSetHea) annotation (Line(points={{-266,92},{
          -160,92},{-160,14.5},{-140.833,14.5}},
                                            color={0,0,127}));
  connect(minTSet[3].y, terUni[3].TSetHea) annotation (Line(points={{-266,92},{
          -160,92},{-160,14.5},{-140.833,14.5}},
                                            color={0,0,127}));
  connect(minTSet[4].y, terUni[4].TSetHea) annotation (Line(points={{-266,92},{
          -160,92},{-160,14.5},{-140.833,14.5}},
                                            color={0,0,127}));
  connect(minTSet[5].y, terUni[5].TSetHea) annotation (Line(points={{-266,92},{
          -160,92},{-160,14.5},{-140.833,14.5}},
                                            color={0,0,127}));
  connect(THeaZn1, terUni[1].TSetHea) annotation (Line(points={{-298,182},{-154,
          182},{-154,14.5},{-140.833,14.5}}, color={0,0,127}));
  annotation (
    Diagram(
      coordinateSystem(
        extent={{-300,-300},{300,300}})),
    Icon(
      coordinateSystem(
        extent={{-300,-300},{300,300}}),
      graphics={
        Bitmap(
          extent={{-72,-88},{50,55}},
          fileName="modelica://Buildings/Resources/Images/ThermalZones/EnergyPlus/EnergyPlusLogo.png")}),
    Documentation(
      info="<html>
<p>
 This is a simplified building model based on EnergyPlus
 building envelope model.
 It was generated from translating a GeoJSON model specified within URBANopt UI.
 The heating and cooling loads are computed with a four-pipe
 fan coil unit model derived from
 <a href=\"modelica://Buildings.Applications.DHC.Loads.BaseClasses.PartialTerminalUnit\">
 Buildings.Applications.DHC.Loads.BaseClasses.PartialTerminalUnit</a>
 and connected to the room model by means of fluid ports.
</p>
</html>",
      revisions="<html>
<ul>
<li>
March 12, 2020: Nicholas Long<br/>
Updated implementation to handle template needed for GeoJSON to Modelica.
</li>
<li>
February 21, 2020, by Antoine Gautier:<br/>
First implementation.
</li>
</ul>
</html>"));
end building;
