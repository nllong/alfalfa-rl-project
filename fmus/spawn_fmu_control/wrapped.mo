within spawn_fmu_control;
model wrapped "Wrapped model"
 // Input overwrite
 Modelica.Blocks.Interfaces.RealInput oveTSetZn1_u(unit="K", min=283.15, max=308.15) "Heating setpoint";
 Modelica.Blocks.Interfaces.BooleanInput oveTSetZn1_activate "Activation for Heating setpoint";

 // Out read
 Modelica.Blocks.Interfaces.RealOutput PHea_y(unit="W") = mod.PHea.y "Heater power";
 Modelica.Blocks.Interfaces.RealOutput PFan_y(unit="W") = mod.PFan.y "Fan electrical power";
 Modelica.Blocks.Interfaces.RealOutput PCoo_y(unit="W") = mod.PCoo.y "Cooling electrical power";
    Modelica.Blocks.Interfaces.RealOutput PPum_y(unit="W") = mod.PPum.y "Pump electrical power";
 Modelica.Blocks.Interfaces.RealOutput senTSetZn1_y(unit="K") = mod.senTSetZn1.y "Zn1 heating setpoint";

 // Original model
 Loads.CoupledSpawnBuilding.coupling mod(
  oveTSetZn1(uExt(y=oveTSetZn1_u),activate(y=oveTSetZn1_activate)))
       "Original model with overwrites";
end wrapped;
