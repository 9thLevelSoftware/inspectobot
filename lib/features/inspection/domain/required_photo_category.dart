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
  windPermitYear('Wind Mit Permit Year'),

  // WDO
  wdoPropertyExterior('WDO Property Exterior'),
  wdoInfestationEvidence('WDO Infestation Evidence'),
  wdoDamageArea('WDO Damage Area'),
  wdoInaccessibleArea('WDO Inaccessible Area'),
  wdoNoticePosting('WDO Notice Posting'),

  // Sinkhole
  sinkholeFrontElevation('Sinkhole Front Elevation'),
  sinkholeRearElevation('Sinkhole Rear Elevation'),
  sinkholeChecklistItem('Sinkhole Checklist Item'),
  sinkholeGarageCrack('Sinkhole Garage Crack'),
  sinkholeAdjacentStructure('Sinkhole Adjacent Structure'),

  // Mold
  moldAffectedArea('Mold Affected Area'),
  moldMoistureSource('Mold Moisture Source'),
  moldMoistureReading('Mold Moisture Reading'),
  moldGrowthEvidence('Mold Growth Evidence'),
  moldLabReport('Mold Lab Report'),

  // General
  generalFrontElevation('General Front Elevation'),
  generalElectricalPanel('General Electrical Panel'),
  generalDataPlate('General Data Plate'),
  generalDeficiency('General Deficiency'),
  generalPressureTest('General Pressure Test'),
  generalRoomPhoto('General Room Photo');

  const RequiredPhotoCategory(this.label);

  final String label;
}

