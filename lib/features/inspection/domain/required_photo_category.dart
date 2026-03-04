enum RequiredPhotoCategory {
  exteriorFront('Exterior Front'),
  exteriorRear('Exterior Rear'),
  exteriorLeft('Exterior Left'),
  exteriorRight('Exterior Right'),
  roofSlopeMain('Roof Slope Main'),
  roofDefect('Roof Defect'),
  waterHeaterTprValve('Water Heater TPR Valve'),
  plumbingUnderSink('Plumbing Under Sink'),
  electricalPanelLabel('Electrical Panel Label'),
  electricalPanelOpen('Electrical Panel Open'),
  hvacDataPlate('HVAC Data Plate'),
  windRoofDeck('Wind Mit Roof Deck Attachment'),
  windRoofToWall('Wind Mit Roof To Wall Attachment'),
  windOpeningProtection('Wind Mit Opening Protection');

  const RequiredPhotoCategory(this.label);

  final String label;
}

