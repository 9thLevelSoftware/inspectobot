enum RequiredPhotoCategory {
  exteriorFront('Exterior Front'),
  exteriorRear('Exterior Rear'),
  exteriorLeft('Exterior Left'),
  exteriorRight('Exterior Right'),
  roofSlopeMain('Roof Slope Main'),
  roofSlopeSecondary('Roof Slope Secondary'),
  roofDefect('Roof Defect'),
  waterHeaterTprValve('Water Heater TPR Valve'),
  plumbingUnderSink('Plumbing Under Sink'),
  electricalPanelLabel('Electrical Panel Label'),
  electricalPanelOpen('Electrical Panel Open'),
  hvacDataPlate('HVAC Data Plate'),
  hazardPhoto('Hazard Photo'),
  windRoofDeck('Wind Mit Roof Deck Attachment'),
  windRoofToWall('Wind Mit Roof To Wall Attachment'),
  windOpeningProtection('Wind Mit Opening Protection'),
  windRoofShape('Wind Mit Roof Shape'),
  windSecondaryWaterResistance('Wind Mit Secondary Water Resistance'),
  windOpeningType('Wind Mit Opening Type'),
  windPermitYear('Wind Mit Permit Year');

  const RequiredPhotoCategory(this.label);

  final String label;
}

