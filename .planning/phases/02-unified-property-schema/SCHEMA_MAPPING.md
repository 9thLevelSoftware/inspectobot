# Field-to-Schema Mapping: Complete Inventory

> **Plan**: 02-05 Field-to-Schema Mapping + Validation Report
> **Phase**: 2 -- Unified Property Schema Design
> **Date**: 2026-03-07
> **Source**: FIELD_INVENTORY Sections 4.1-4.7, Plans 02-01 through 02-04

---

## 1. Schema Location Reference

Every field from the Phase 1 FIELD_INVENTORY maps to one of three schema locations:

| Schema Location | Description | Strongly Typed | Count |
|----------------|-------------|----------------|-------|
| `UniversalPropertyFields.{field}` | Present on 5+ of 7 forms | Yes (Dart class) | 8 fields |
| `SharedBuildingSystemFields.{field}` | Present on 2-4 forms | Yes (Dart class) | 13 fields |
| `FormDataKeys.{constant}` -> `formData[FormType].{key}` | Form-specific | No (Map<String, dynamic>) | 333 constants |
| Media module (`capturedPhotoPaths`, `capturedEvidencePaths`) | Photo/document evidence | N/A (media system) | ~55 photo/checkbox fields |

---

## 2. Four-Point Inspection (Insp4pt 03-25)

### 2.1 Currently Mapped Fields (27) -- Photo/Evidence + Shared

| # | FIELD_INVENTORY Key | Field Name | Schema Location | Schema Path/Key | Type | Required | Notes |
|---|-------------------|------------|----------------|-----------------|------|----------|-------|
| 1 | `text.client_name` | Client Name | `UniversalPropertyFields.clientName` | `universal.clientName` | String | Yes | Shared across all 7 forms |
| 2 | `text.property_address` | Property Address | `UniversalPropertyFields.propertyAddress` | `universal.propertyAddress` | String | Yes | Shared across all 7 forms |
| 3 | `signature.inspector` | Inspector Signature | `UniversalPropertyFields.inspectorSignaturePath` | `universal.inspectorSignaturePath` | String? | Yes | Shared across all 7 forms |
| 4 | `checkbox.photo_exterior_front` | Photo: Exterior Front (cb) | Media module | `capturedPhotoPaths[exteriorFront]` | N/A | Yes | Media module |
| 5 | `image.photo_exterior_front` | Photo: Exterior Front | Media module | `capturedEvidencePaths['photo:exterior_front']` | N/A | Yes | Media module |
| 6 | `checkbox.photo_exterior_rear` | Photo: Exterior Rear (cb) | Media module | `capturedPhotoPaths[exteriorRear]` | N/A | Yes | Media module |
| 7 | `image.photo_exterior_rear` | Photo: Exterior Rear | Media module | `capturedEvidencePaths['photo:exterior_rear']` | N/A | Yes | Media module |
| 8 | `checkbox.photo_exterior_left` | Photo: Exterior Left (cb) | Media module | `capturedPhotoPaths[exteriorLeft]` | N/A | Yes | Media module |
| 9 | `image.photo_exterior_left` | Photo: Exterior Left | Media module | `capturedEvidencePaths['photo:exterior_left']` | N/A | Yes | Media module |
| 10 | `checkbox.photo_exterior_right` | Photo: Exterior Right (cb) | Media module | `capturedPhotoPaths[exteriorRight]` | N/A | Yes | Media module |
| 11 | `image.photo_exterior_right` | Photo: Exterior Right | Media module | `capturedEvidencePaths['photo:exterior_right']` | N/A | Yes | Media module |
| 12 | `checkbox.photo_roof_slope_main` | Photo: Roof Main Slope (cb) | Media module | `capturedPhotoPaths[roofSlopeMain]` | N/A | Yes | Media module |
| 13 | `image.photo_roof_slope_main` | Photo: Roof Main Slope | Media module | `capturedEvidencePaths['photo:roof_slope_main']` | N/A | Yes | Media module |
| 14 | `checkbox.photo_roof_slope_secondary` | Photo: Roof Secondary Slope (cb) | Media module | `capturedPhotoPaths[roofSlopeSecondary]` | N/A | Yes | Media module |
| 15 | `image.photo_roof_slope_secondary` | Photo: Roof Secondary Slope | Media module | `capturedEvidencePaths['photo:roof_slope_secondary']` | N/A | Yes | Media module |
| 16 | `checkbox.photo_water_heater_tpr_valve` | Photo: Water Heater TPR (cb) | Media module | `capturedPhotoPaths[waterHeaterTprValve]` | N/A | Yes | Media module |
| 17 | `image.photo_water_heater_tpr_valve` | Photo: Water Heater TPR | Media module | `capturedEvidencePaths['photo:water_heater_tpr']` | N/A | Yes | Media module |
| 18 | `checkbox.photo_plumbing_under_sink` | Photo: Plumbing Under Sink (cb) | Media module | `capturedPhotoPaths[plumbingUnderSink]` | N/A | Yes | Media module |
| 19 | `image.photo_plumbing_under_sink` | Photo: Plumbing Under Sink | Media module | `capturedEvidencePaths['photo:plumbing_under_sink']` | N/A | Yes | Media module |
| 20 | `checkbox.photo_electrical_panel_label` | Photo: Elec Panel Label (cb) | Media module | `capturedPhotoPaths[electricalPanelLabel]` | N/A | Yes | Media module |
| 21 | `image.photo_electrical_panel_label` | Photo: Elec Panel Label | Media module | `capturedEvidencePaths['photo:elec_panel_label']` | N/A | Yes | Media module |
| 22 | `checkbox.photo_electrical_panel_open` | Photo: Elec Panel Open (cb) | Media module | `capturedPhotoPaths[electricalPanelOpen]` | N/A | Yes | Media module |
| 23 | `image.photo_electrical_panel_open` | Photo: Elec Panel Open | Media module | `capturedEvidencePaths['photo:elec_panel_open']` | N/A | Yes | Media module |
| 24 | `checkbox.photo_hvac_data_plate` | Photo: HVAC Data Plate (cb) | Media module | `capturedPhotoPaths[hvacDataPlate]` | N/A | Yes | Media module |
| 25 | `image.photo_hvac_data_plate` | Photo: HVAC Data Plate | Media module | `capturedEvidencePaths['photo:hvac_data_plate']` | N/A | Yes | Media module |
| 26 | `checkbox.photo_hazard_photo` | Photo: Hazard (cb) | Media module | `capturedPhotoPaths[hazardPhoto]` | N/A | Conditional | When hazard_present |
| 27 | `image.photo_hazard_photo` | Photo: Hazard | Media module | `capturedEvidencePaths['photo:hazard']` | N/A | Conditional | When hazard_present |

### 2.2 Gap Fields -- Header / Property Info (3)

| # | FIELD_INVENTORY Key | Field Name | Schema Location | Schema Path/Key | Type | Required | Notes |
|---|-------------------|------------|----------------|-----------------|------|----------|-------|
| 1 | `text.header_policy_number` | Application / Policy # | `SharedBuildingSystemFields.policyNumber` | `shared.policyNumber` | String? | Yes | Shared (4 forms) |
| 2 | `text.header_year_built` | Actual Year Built | `SharedBuildingSystemFields.yearBuilt` | `shared.yearBuilt` | int? | Yes | Shared (5 forms) |
| 3 | `date.header_date_inspected` | Date Inspected | `UniversalPropertyFields.inspectionDate` | `universal.inspectionDate` | DateTime | Yes | Universal |

### 2.3 Gap Fields -- Electrical System (33)

| # | FIELD_INVENTORY Key | Field Name | Schema Location | Schema Path/Key | Type | Required | Notes |
|---|-------------------|------------|----------------|-----------------|------|----------|-------|
| 1 | `radio.electrical_main_panel_type` | Main Panel Type | `SharedBuildingSystemFields.electricalPanelType` + `FormDataKeys.fp_electricalMainPanelType` | `shared.electricalPanelType` + `formData[fourPoint]['electrical.mainPanelType']` | String | Yes | Shared captures primary; form captures detail |
| 2 | `text.electrical_main_panel_amps` | Main Panel Total Amps | `SharedBuildingSystemFields.electricalPanelAmps` + `FormDataKeys.fp_electricalMainPanelAmps` | `shared.electricalPanelAmps` + `formData[fourPoint]['electrical.mainPanelAmps']` | int | Yes | Shared captures value; form mirrors it |
| 3 | `checkbox.electrical_main_amps_sufficient` | Amperage sufficient | `FormDataKeys.fp_electricalMainAmpsSufficient` | `formData[fourPoint]['electrical.mainAmpsSufficient']` | bool | Yes | Form-specific |
| 4 | `radio.electrical_second_panel_type` | Second Panel Type | `FormDataKeys.fp_electricalSecondPanelType` | `formData[fourPoint]['electrical.secondPanelType']` | String? | Conditional | When second panel exists |
| 5 | `text.electrical_second_panel_amps` | Second Panel Amps | `FormDataKeys.fp_electricalSecondPanelAmps` | `formData[fourPoint]['electrical.secondPanelAmps']` | int? | Conditional | When second panel exists |
| 6 | `checkbox.electrical_second_amps_sufficient` | Second Panel sufficient | `FormDataKeys.fp_electricalSecondAmpsSufficient` | `formData[fourPoint]['electrical.secondAmpsSufficient']` | bool? | Conditional | When second panel exists |
| 7 | `checkbox.electrical_cloth_wiring` | Cloth wiring | `FormDataKeys.fp_electricalClothWiring` | `formData[fourPoint]['electrical.clothWiring']` | bool | Yes | |
| 8 | `checkbox.electrical_knob_and_tube` | Knob and tube | `FormDataKeys.fp_electricalKnobAndTube` | `formData[fourPoint]['electrical.knobAndTube']` | bool | Yes | |
| 9 | `checkbox.electrical_aluminum_branch_wiring` | Aluminum branch wiring | `FormDataKeys.fp_electricalAluminumBranchWiring` | `formData[fourPoint]['electrical.aluminumBranchWiring']` | bool | Yes | |
| 10 | `text.electrical_aluminum_branch_details` | Aluminum wiring details | `FormDataKeys.fp_electricalAluminumBranchDetails` | `formData[fourPoint]['electrical.aluminumBranchDetails']` | String? | Conditional | When aluminum present |
| 11 | `checkbox.electrical_copalum_crimp` | COPALUM crimp | `FormDataKeys.fp_electricalCopalumCrimp` | `formData[fourPoint]['electrical.copalumCrimp']` | bool? | Conditional | When aluminum present |
| 12 | `checkbox.electrical_alumiconn` | AlumiConn | `FormDataKeys.fp_electricalAlumiconn` | `formData[fourPoint]['electrical.alumiconn']` | bool? | Conditional | When aluminum present |
| 13 | `checkbox.electrical_hazard_blowing_fuses` | Hazard: Blowing fuses | `FormDataKeys.fp_electricalHazardBlowingFuses` | `formData[fourPoint]['electrical.hazardBlowingFuses']` | bool | Yes | |
| 14 | `checkbox.electrical_hazard_tripping_breakers` | Hazard: Tripping breakers | `FormDataKeys.fp_electricalHazardTrippingBreakers` | `formData[fourPoint]['electrical.hazardTrippingBreakers']` | bool | Yes | |
| 15 | `checkbox.electrical_hazard_empty_sockets` | Hazard: Empty sockets | `FormDataKeys.fp_electricalHazardEmptySockets` | `formData[fourPoint]['electrical.hazardEmptySockets']` | bool | Yes | |
| 16 | `checkbox.electrical_hazard_loose_wiring` | Hazard: Loose wiring | `FormDataKeys.fp_electricalHazardLooseWiring` | `formData[fourPoint]['electrical.hazardLooseWiring']` | bool | Yes | |
| 17 | `checkbox.electrical_hazard_improper_grounding` | Hazard: Improper grounding | `FormDataKeys.fp_electricalHazardImproperGrounding` | `formData[fourPoint]['electrical.hazardImproperGrounding']` | bool | Yes | |
| 18 | `checkbox.electrical_hazard_corrosion` | Hazard: Corrosion | `FormDataKeys.fp_electricalHazardCorrosion` | `formData[fourPoint]['electrical.hazardCorrosion']` | bool | Yes | |
| 19 | `checkbox.electrical_hazard_over_fusing` | Hazard: Over fusing | `FormDataKeys.fp_electricalHazardOverFusing` | `formData[fourPoint]['electrical.hazardOverFusing']` | bool | Yes | |
| 20 | `checkbox.electrical_hazard_double_taps` | Hazard: Double taps | `FormDataKeys.fp_electricalHazardDoubleTaps` | `formData[fourPoint]['electrical.hazardDoubleTaps']` | bool | Yes | |
| 21 | `checkbox.electrical_hazard_exposed_wiring` | Hazard: Exposed wiring | `FormDataKeys.fp_electricalHazardExposedWiring` | `formData[fourPoint]['electrical.hazardExposedWiring']` | bool | Yes | |
| 22 | `checkbox.electrical_hazard_unsafe_wiring` | Hazard: Unsafe wiring | `FormDataKeys.fp_electricalHazardUnsafeWiring` | `formData[fourPoint]['electrical.hazardUnsafeWiring']` | bool | Yes | |
| 23 | `checkbox.electrical_hazard_improper_breaker_size` | Hazard: Improper breaker | `FormDataKeys.fp_electricalHazardImproperBreakerSize` | `formData[fourPoint]['electrical.hazardImproperBreakerSz']` | bool | Yes | |
| 24 | `checkbox.electrical_hazard_scorching` | Hazard: Scorching | `FormDataKeys.fp_electricalHazardScorching` | `formData[fourPoint]['electrical.hazardScorching']` | bool | Yes | |
| 25 | `checkbox.electrical_hazard_other` | Hazard: Other | `FormDataKeys.fp_electricalHazardOther` | `formData[fourPoint]['electrical.hazardOther']` | bool | Yes | |
| 26 | `text.electrical_hazard_other_desc` | Hazard: Other desc | `FormDataKeys.fp_electricalHazardOtherDesc` | `formData[fourPoint]['electrical.hazardOtherDesc']` | String? | Conditional | When hazardOther = true |
| 27 | `enum.electrical_general_condition` | General condition | `FormDataKeys.fp_electricalGeneralCondition` | `formData[fourPoint]['electrical.generalCondition']` | String | Yes | "satisfactory" or "unsatisfactory" |
| 28 | `text.electrical_main_panel_age` | Main Panel age | `FormDataKeys.fp_electricalMainPanelAge` | `formData[fourPoint]['electrical.mainPanelAge']` | String | Yes | |
| 29 | `text.electrical_main_panel_year_updated` | Main Panel year updated | `FormDataKeys.fp_electricalMainPanelYearUpdated` | `formData[fourPoint]['electrical.mainPanelYearUpdated']` | String | Yes | |
| 30 | `text.electrical_main_panel_brand` | Main Panel brand | `FormDataKeys.fp_electricalMainPanelBrand` | `formData[fourPoint]['electrical.mainPanelBrand']` | String | Yes | |
| 31 | `text.electrical_second_panel_age` | Second Panel age | `FormDataKeys.fp_electricalSecondPanelAge` | `formData[fourPoint]['electrical.secondPanelAge']` | String? | Conditional | When second panel exists |
| 32 | `text.electrical_second_panel_year_updated` | Second Panel year updated | `FormDataKeys.fp_electricalSecondPanelYearUpdated` | `formData[fourPoint]['electrical.secondPanelYearUpdated']` | String? | Conditional | When second panel exists |
| 33 | `text.electrical_second_panel_brand` | Second Panel brand | `FormDataKeys.fp_electricalSecondPanelBrand` | `formData[fourPoint]['electrical.secondPanelBrand']` | String? | Conditional | When second panel exists |

### 2.4 Gap Fields -- HVAC System (11)

| # | FIELD_INVENTORY Key | Field Name | Schema Location | Schema Path/Key | Type | Required | Notes |
|---|-------------------|------------|----------------|-----------------|------|----------|-------|
| 1 | `checkbox.hvac_central_ac` | Central AC | `FormDataKeys.fp_hvacCentralAc` | `formData[fourPoint]['hvac.centralAc']` | bool | Yes | |
| 2 | `checkbox.hvac_central_heat` | Central Heat | `FormDataKeys.fp_hvacCentralHeat` | `formData[fourPoint]['hvac.centralHeat']` | bool | Yes | |
| 3 | `text.hvac_primary_heat_source` | Primary heat source | `SharedBuildingSystemFields.hvacType` + `FormDataKeys.fp_hvacPrimaryHeatSource` | `shared.hvacType` + `formData[fourPoint]['hvac.primaryHeatSource']` | String | Yes | Shared captures type; form captures detail |
| 4 | `checkbox.hvac_good_working_order` | Good working order | `FormDataKeys.fp_hvacGoodWorkingOrder` | `formData[fourPoint]['hvac.goodWorkingOrder']` | bool | Yes | |
| 5 | `date.hvac_last_service_date` | Last service date | `FormDataKeys.fp_hvacLastServiceDate` | `formData[fourPoint]['hvac.lastServiceDate']` | String | Yes | |
| 6 | `checkbox.hvac_hazard_wood_stove_fireplace` | Hazard: Wood stove/fireplace | `FormDataKeys.fp_hvacHazardWoodStoveFireplace` | `formData[fourPoint]['hvac.hazardWoodStoveFireplace']` | bool | Yes | |
| 7 | `checkbox.hvac_hazard_space_heater_primary` | Hazard: Space heater primary | `FormDataKeys.fp_hvacHazardSpaceHeaterPrimary` | `formData[fourPoint]['hvac.hazardSpaceHeaterPrimary']` | bool | Yes | |
| 8 | `checkbox.hvac_hazard_source_portable` | Hazard: Portable source | `FormDataKeys.fp_hvacHazardSourcePortable` | `formData[fourPoint]['hvac.hazardSourcePortable']` | bool? | Conditional | When space heater = Yes |
| 9 | `checkbox.hvac_hazard_air_handler_blockage` | Hazard: Air handler blockage | `FormDataKeys.fp_hvacHazardAirHandlerBlockage` | `formData[fourPoint]['hvac.hazardAirHandlerBlockage']` | bool | Yes | |
| 10 | `text.hvac_system_age` | System age | `FormDataKeys.fp_hvacSystemAge` | `formData[fourPoint]['hvac.systemAge']` | String | Yes | |
| 11 | `text.hvac_year_updated` | Year updated | `FormDataKeys.fp_hvacYearUpdated` | `formData[fourPoint]['hvac.yearUpdated']` | String | Yes | |

### 2.5 Gap Fields -- Plumbing System (25)

| # | FIELD_INVENTORY Key | Field Name | Schema Location | Schema Path/Key | Type | Required | Notes |
|---|-------------------|------------|----------------|-----------------|------|----------|-------|
| 1 | `checkbox.plumbing_tpr_valve` | TPR valve | `FormDataKeys.fp_plumbingTprValve` | `formData[fourPoint]['plumbing.tprValve']` | bool | Yes | |
| 2 | `checkbox.plumbing_active_leak` | Active leak | `FormDataKeys.fp_plumbingActiveLeak` | `formData[fourPoint]['plumbing.activeLeak']` | bool | Yes | |
| 3 | `checkbox.plumbing_prior_leak` | Prior leak | `FormDataKeys.fp_plumbingPriorLeak` | `formData[fourPoint]['plumbing.priorLeak']` | bool | Yes | |
| 4 | `text.plumbing_water_heater_location` | Water heater location | `FormDataKeys.fp_plumbingWaterHeaterLocation` | `formData[fourPoint]['plumbing.waterHeaterLocation']` | String | Yes | |
| 5 | `rating.plumbing_fixture_dishwasher` | Fixture: Dishwasher | `FormDataKeys.fp_plumbingFixtureDishwasher` | `formData[fourPoint]['plumbing.fixtureDishwasher']` | String | Yes | "s"/"u"/"na" |
| 6 | `rating.plumbing_fixture_refrigerator` | Fixture: Refrigerator | `FormDataKeys.fp_plumbingFixtureRefrigerator` | `formData[fourPoint]['plumbing.fixtureRefrigerator']` | String | Yes | "s"/"u"/"na" |
| 7 | `rating.plumbing_fixture_washing_machine` | Fixture: Washing machine | `FormDataKeys.fp_plumbingFixtureWashingMachine` | `formData[fourPoint]['plumbing.fixtureWashingMachine']` | String | Yes | "s"/"u"/"na" |
| 8 | `rating.plumbing_fixture_water_heater` | Fixture: Water heater | `FormDataKeys.fp_plumbingFixtureWaterHeater` | `formData[fourPoint]['plumbing.fixtureWaterHeater']` | String | Yes | "s"/"u"/"na" |
| 9 | `rating.plumbing_fixture_showers_tubs` | Fixture: Showers/Tubs | `FormDataKeys.fp_plumbingFixtureShowersTubs` | `formData[fourPoint]['plumbing.fixtureShowersTubs']` | String | Yes | "s"/"u"/"na" |
| 10 | `rating.plumbing_fixture_toilets` | Fixture: Toilets | `FormDataKeys.fp_plumbingFixtureToilets` | `formData[fourPoint]['plumbing.fixtureToilets']` | String | Yes | "s"/"u"/"na" |
| 11 | `rating.plumbing_fixture_sinks` | Fixture: Sinks | `FormDataKeys.fp_plumbingFixtureSinks` | `formData[fourPoint]['plumbing.fixtureSinks']` | String | Yes | "s"/"u"/"na" |
| 12 | `rating.plumbing_fixture_sump_pump` | Fixture: Sump pump | `FormDataKeys.fp_plumbingFixtureSumpPump` | `formData[fourPoint]['plumbing.fixtureSumpPump']` | String | Yes | "s"/"u"/"na" |
| 13 | `rating.plumbing_fixture_main_shutoff` | Fixture: Main shut off | `FormDataKeys.fp_plumbingFixtureMainShutoff` | `formData[fourPoint]['plumbing.fixtureMainShutoff']` | String | Yes | "s"/"u"/"na" |
| 14 | `rating.plumbing_fixture_all_other` | Fixture: All other | `FormDataKeys.fp_plumbingFixtureAllOther` | `formData[fourPoint]['plumbing.fixtureAllOther']` | String | Yes | "s"/"u"/"na" |
| 15 | `text.plumbing_fixture_unsatisfactory_comments` | Fixture comments | `FormDataKeys.fp_plumbingFixtureUnsatisfactoryComments` | `formData[fourPoint]['plumbing.fixtureUnsatisfactoryComments']` | String? | Conditional | When any fixture = U |
| 16 | `text.plumbing_piping_age` | Piping age | `FormDataKeys.fp_plumbingPipingAge` | `formData[fourPoint]['plumbing.pipingAge']` | String | Yes | |
| 17 | `checkbox.plumbing_completely_repiped` | Completely re-piped | `FormDataKeys.fp_plumbingCompletelyRepiped` | `formData[fourPoint]['plumbing.completelyRepiped']` | bool | Yes | |
| 18 | `checkbox.plumbing_partially_repiped` | Partially re-piped | `FormDataKeys.fp_plumbingPartiallyRepiped` | `formData[fourPoint]['plumbing.partiallyRepiped']` | bool | Yes | |
| 19 | `text.plumbing_repipe_details` | Re-pipe details | `FormDataKeys.fp_plumbingRepipeDetails` | `formData[fourPoint]['plumbing.repipeDetails']` | String? | Conditional | When repiped |
| 20 | `checkbox.plumbing_pipe_copper` | Pipe: Copper | `SharedBuildingSystemFields.plumbingPipeMaterial` + `FormDataKeys.fp_plumbingPipeCopper` | `shared.plumbingPipeMaterial` + `formData[fourPoint]['plumbing.pipeCopper']` | bool | Yes | Shared captures primary; form captures each type |
| 21 | `checkbox.plumbing_pipe_pvc_cpvc` | Pipe: PVC/CPVC | `FormDataKeys.fp_plumbingPipePvcCpvc` | `formData[fourPoint]['plumbing.pipePvcCpvc']` | bool | Yes | |
| 22 | `checkbox.plumbing_pipe_galvanized` | Pipe: Galvanized | `FormDataKeys.fp_plumbingPipeGalvanized` | `formData[fourPoint]['plumbing.pipeGalvanized']` | bool | Yes | |
| 23 | `checkbox.plumbing_pipe_pex` | Pipe: PEX | `FormDataKeys.fp_plumbingPipePex` | `formData[fourPoint]['plumbing.pipePex']` | bool | Yes | |
| 24 | `checkbox.plumbing_pipe_polybutylene` | Pipe: Polybutylene | `FormDataKeys.fp_plumbingPipePolybutylene` | `formData[fourPoint]['plumbing.pipePolybutylene']` | bool | Yes | |
| 25 | `checkbox.plumbing_pipe_other` / `text.plumbing_pipe_other_desc` | Pipe: Other | `FormDataKeys.fp_plumbingPipeOther` + `FormDataKeys.fp_plumbingPipeOtherDesc` | `formData[fourPoint]['plumbing.pipeOther']` + `['plumbing.pipeOtherDesc']` | bool + String? | Yes | Compound field: 2 constants |

### 2.6 Gap Fields -- Roof (22 = primary + secondary mirror)

| # | FIELD_INVENTORY Key | Field Name | Schema Location | Schema Path/Key | Type | Required | Notes |
|---|-------------------|------------|----------------|-----------------|------|----------|-------|
| 1 | `text.roof_primary_covering_material` | Covering material | `SharedBuildingSystemFields.roofCoveringMaterial` | `shared.roofCoveringMaterial` | String? | Yes | Shared (3 forms) |
| 2 | `text.roof_primary_age` | Roof age | `SharedBuildingSystemFields.roofAge` | `shared.roofAge` | int? | Yes | Shared (3 forms) |
| 3 | `text.roof_primary_remaining_life` | Remaining useful life | `FormDataKeys.fp_roofPrimaryRemainingLife` | `formData[fourPoint]['roof.primaryRemainingLife']` | String | Yes | |
| 4 | `text.roof_primary_last_permit_date` | Last permit date | `FormDataKeys.fp_roofPrimaryLastPermitDate` | `formData[fourPoint]['roof.primaryLastPermitDate']` | String | Yes | |
| 5 | `text.roof_primary_last_update` | Last update | `FormDataKeys.fp_roofPrimaryLastUpdate` | `formData[fourPoint]['roof.primaryLastUpdate']` | String | Yes | |
| 6 | `checkbox.roof_primary_full_replacement` | Full replacement | `FormDataKeys.fp_roofPrimaryFullReplacement` | `formData[fourPoint]['roof.primaryFullReplacement']` | bool | Conditional | |
| 7 | `checkbox.roof_primary_partial_replacement` | Partial replacement | `FormDataKeys.fp_roofPrimaryPartialReplacement` | `formData[fourPoint]['roof.primaryPartialReplacement']` | bool | Conditional | |
| 8 | `text.roof_primary_replacement_pct` | Replacement % | `FormDataKeys.fp_roofPrimaryReplacementPct` | `formData[fourPoint]['roof.primaryReplacementPct']` | String? | Conditional | When partial |
| 9 | `enum.roof_primary_overall_condition` | Overall condition | `SharedBuildingSystemFields.roofCondition` + `FormDataKeys.fp_roofPrimaryOverallCondition` | `shared.roofCondition` + `formData[fourPoint]['roof.primaryOverallCondition']` | RatingScale / String | Yes | Shared stores normalized; form stores original |
| 10-17 | `checkbox.roof_primary_damage_*` (8 items) | Visible damage checkboxes | `FormDataKeys.fp_roofPrimaryDamage*` | `formData[fourPoint]['roof.primaryDamage*']` | bool | Yes | 8 damage type checkboxes |
| 18 | `checkbox.roof_primary_leaks` | Signs of leaks | `FormDataKeys.fp_roofPrimaryLeaks` | `formData[fourPoint]['roof.primaryLeaks']` | bool | Yes | |
| 19 | `checkbox.roof_primary_attic_underside_leaks` | Attic leaks | `FormDataKeys.fp_roofPrimaryAtticUndersideLeaks` | `formData[fourPoint]['roof.primaryAtticUndersideLeaks']` | bool | Yes | |
| 20 | `checkbox.roof_primary_interior_ceiling_leaks` | Interior leaks | `FormDataKeys.fp_roofPrimaryInteriorCeilingLeaks` | `formData[fourPoint]['roof.primaryInteriorCeilingLeaks']` | bool | Yes | |
| 21 | Secondary Roof (mirror) | All secondary roof fields | `FormDataKeys.fp_roofSecondary*` (20 constants) | `formData[fourPoint]['roofSecondary.*']` | Various | Conditional | When multiple roof coverings |
| 22 | `text.roof_additional_comments` | Comments | `UniversalPropertyFields.comments` | `universal.comments` | String? | No | Universal field |

### 2.7 Gap Fields -- Inspector Certification (6)

| # | FIELD_INVENTORY Key | Field Name | Schema Location | Schema Path/Key | Type | Required | Notes |
|---|-------------------|------------|----------------|-----------------|------|----------|-------|
| 1 | `text.inspector_title` | Title | `FormDataKeys.fp_inspectorTitle` | `formData[fourPoint]['inspector.title']` | String | Yes | Form-specific |
| 2 | `text.inspector_license_number` | License Number | `UniversalPropertyFields.inspectorLicenseNumber` | `universal.inspectorLicenseNumber` | String | Yes | Universal |
| 3 | `date.inspector_signature_date` | Date | `SharedBuildingSystemFields.signatureDate` | `shared.signatureDate` | DateTime? | Yes | Shared (4 forms) |
| 4 | `text.inspector_company_name` | Company Name | `UniversalPropertyFields.inspectorCompany` | `universal.inspectorCompany` | String | Yes | Universal |
| 5 | `text.inspector_license_type` | License Type | `FormDataKeys.fp_inspectorLicenseType` | `formData[fourPoint]['inspector.licenseType']` | String | Yes | Form-specific |
| 6 | `text.inspector_work_phone` | Work Phone | `SharedBuildingSystemFields.inspectorPhone` | `shared.inspectorPhone` | String? | Yes | Shared (4 forms) -- NOTE: 4-Point is not in the shared overlap per FIELD_INVENTORY 2.3, but Work Phone on certification block maps here |

### 2.8 Four-Point Count Verification

| Category | Count |
|----------|-------|
| Universal fields used | 8 (address, date, name, company, license, client, signature, comments) |
| Shared fields used | 11 (policy, year, signature_date, roof material/age/condition, panel type/amps, pipe material, water heater type, hvac type) |
| Form-specific FormDataKeys constants | 111 |
| Media/photo fields (excluded from formData) | 27 |
| **FIELD_INVENTORY total** | **~126 (27 mapped + ~99 gap)** |
| **Schema total** | 8 + 11 + 111 + 27 = **157 schema slots** |
| **Delta explanation** | Constants > inventory fields because: compound fields expand (e.g., hazardOther -> 2 constants), secondary roof mirrors all primary fields (20 more constants), pipe type checkboxes are both shared and form-specific |

---

## 3. Roof Condition Form (RCF-1 03-25)

### 3.1 Mapped Fields (8) + Gap Fields (20) -- Combined

| # | FIELD_INVENTORY Key | Field Name | Schema Location | Schema Path/Key | Type | Required | Notes |
|---|-------------------|------------|----------------|-----------------|------|----------|-------|
| 1 | `text.client_name` | Client Name | `UniversalPropertyFields.clientName` | `universal.clientName` | String | Yes | Universal |
| 2 | `signature.inspector` | Inspector Signature | `UniversalPropertyFields.inspectorSignaturePath` | `universal.inspectorSignaturePath` | String? | Yes | Universal |
| 3 | `checkbox.photo_roof_condition_main_slope` + `image` | Roof Main Slope photo pair | Media module | `capturedPhotoPaths[roofSlopeMain]` | N/A | Yes | Media |
| 4 | `checkbox.photo_roof_condition_secondary_slope` + `image` | Roof Secondary Slope photo pair | Media module | `capturedPhotoPaths[roofSlopeSecondary]` | N/A | Yes | Media |
| 5 | `checkbox.photo_roof_defect` + `image` | Roof Defect photo pair | Media module | `capturedPhotoPaths[roofDefect]` | N/A | Conditional | When roof_defect_present |
| 6 | `text.header_property_address` | Property Address | `UniversalPropertyFields.propertyAddress` | `universal.propertyAddress` | String | Yes | Universal |
| 7 | `text.header_policy_number` | Policy Number | `SharedBuildingSystemFields.policyNumber` | `shared.policyNumber` | String? | Yes | Shared |
| 8 | `date.header_inspection_date` | Inspection Date | `UniversalPropertyFields.inspectionDate` | `universal.inspectionDate` | DateTime | Yes | Universal |
| 9 | `text.header_year_built` | Year Built | `SharedBuildingSystemFields.yearBuilt` | `shared.yearBuilt` | int? | Yes | Shared |
| 10 | `text.roof_covering_material` | Covering Material | `SharedBuildingSystemFields.roofCoveringMaterial` | `shared.roofCoveringMaterial` | String? | Yes | Shared |
| 11 | `text.roof_age` | Roof Age | `SharedBuildingSystemFields.roofAge` | `shared.roofAge` | int? | Yes | Shared |
| 12 | `text.roof_remaining_life` | Remaining Life | `FormDataKeys.rc_roofRemainingLife` | `formData[roofCondition]['roof.remainingLife']` | String | Yes | Form-specific |
| 13 | `enum.roof_condition_rating` | Condition Rating | `SharedBuildingSystemFields.roofCondition` + `FormDataKeys.rc_roofConditionRating` | `shared.roofCondition` + `formData[roofCondition]['roof.conditionRating']` | RatingScale / String | Yes | Shared + form-specific |
| 14 | `checkbox.roof_prior_repairs` + desc | Prior Repairs | `FormDataKeys.rc_roofPriorRepairs` + `rc_roofPriorRepairsDesc` | `formData[roofCondition]['roof.priorRepairs']` + `['roof.priorRepairsDesc']` | bool + String? | Yes | |
| 15 | `checkbox.roof_leaks` + desc | Leaks | `FormDataKeys.rc_roofLeaks` + `rc_roofLeaksDesc` | `formData[roofCondition]['roof.leaks']` + `['roof.leaksDesc']` | bool + String? | Yes | |
| 16 | `checkbox.roof_wind_damage` + desc | Wind Damage | `FormDataKeys.rc_roofWindDamage` + `rc_roofWindDamageDesc` | `formData[roofCondition]['roof.windDamage']` + `['roof.windDamageDesc']` | bool + String? | Yes | |
| 17 | `checkbox.roof_hail_damage` + desc | Hail Damage | `FormDataKeys.rc_roofHailDamage` + `rc_roofHailDamageDesc` | `formData[roofCondition]['roof.hailDamage']` + `['roof.hailDamageDesc']` | bool + String? | Yes | |
| 18 | `text.roof_number_of_layers` | Number of Layers | `FormDataKeys.rc_roofNumberOfLayers` | `formData[roofCondition]['roof.numberOfLayers']` | String | Yes | |
| 19 | `enum.roof_flashing_condition` | Flashing Condition | `FormDataKeys.rc_roofFlashingCondition` | `formData[roofCondition]['roof.flashingCondition']` | String | Yes | |
| 20 | `enum.roof_soffit_fascia_condition` | Soffit/Fascia | `FormDataKeys.rc_roofSoffitFasciaCondition` | `formData[roofCondition]['roof.soffitFasciaCondition']` | String | Yes | |
| 21 | `enum.roof_gutters_downspouts` | Gutters/Downspouts | `FormDataKeys.rc_roofGuttersDownspouts` | `formData[roofCondition]['roof.guttersDownspouts']` | String | Yes | |
| 22 | `text.inspector_license_number` | License # | `UniversalPropertyFields.inspectorLicenseNumber` | `universal.inspectorLicenseNumber` | String | Yes | Universal |
| 23 | `text.inspector_company` | Company | `UniversalPropertyFields.inspectorCompany` | `universal.inspectorCompany` | String | Yes | Universal |
| 24 | `date.inspector_signature_date` | Date Signed | `SharedBuildingSystemFields.signatureDate` | `shared.signatureDate` | DateTime? | Yes | Shared |
| 25 | `text.roof_comments` | Comments | `FormDataKeys.rc_roofComments` | `formData[roofCondition]['roof.comments']` | String? | No | Form-specific comments (distinct from universal) |

**RCF-1 Count**: 8 universal + 6 shared + 15 form-specific + 6 media = **35 schema slots** against ~28 FIELD_INVENTORY fields. Delta: compound checkbox+text pairs expand to 2 constants each.

---

## 4. Wind Mitigation (OIR-B1-1802)

### 4.1 All Fields Combined (22 mapped + ~23 gap)

| # | FIELD_INVENTORY Key | Field Name | Schema Location | Schema Path/Key | Type | Required | Notes |
|---|-------------------|------------|----------------|-----------------|------|----------|-------|
| 1 | `text.client_name` | Client Name | `UniversalPropertyFields.clientName` | `universal.clientName` | String | Yes | Universal |
| 2 | `signature.inspector` | Inspector Signature | `UniversalPropertyFields.inspectorSignaturePath` | `universal.inspectorSignaturePath` | String? | Yes | Universal |
| 3-22 | `checkbox.photo_*` + `image.photo_*` + `document_*` | 20 photo/document evidence fields | Media module | `capturedPhotoPaths[wind*]` | N/A | Various | Media (7 always, 3 conditional) |
| 23 | `text.header_property_address` | Property Address | `UniversalPropertyFields.propertyAddress` | `universal.propertyAddress` | String | Yes | Universal |
| 24 | `text.header_policy_number` | Policy Number | `SharedBuildingSystemFields.policyNumber` | `shared.policyNumber` | String? | Yes | Shared |
| 25 | `date.header_inspection_date` | Inspection Date | `UniversalPropertyFields.inspectionDate` | `universal.inspectionDate` | DateTime | Yes | Universal |
| 26 | `text.header_year_built` | Year Built | `SharedBuildingSystemFields.yearBuilt` | `shared.yearBuilt` | int? | Yes | Shared |
| 27 | `radio.wind_q1_building_code` + text | Q1: Building Code | `FormDataKeys.wm_q1BuildingCode` + `wm_q1Year` | `formData[windMit]['q1.buildingCode']` + `['q1.year']` | String + String | Yes | |
| 28 | `radio.wind_q2_roof_covering` + text | Q2: Roof Covering | `FormDataKeys.wm_q2RoofCovering` + `wm_q2PermitDate` | `formData[windMit]['q2.roofCovering']` + `['q2.permitDate']` | String + String | Yes | |
| 29 | `radio.wind_q3_roof_deck_attachment` | Q3: Roof Deck | `FormDataKeys.wm_q3RoofDeckAttachment` | `formData[windMit]['q3.roofDeckAttachment']` | String | Yes | A/B/C/D |
| 30 | `radio.wind_q4_roof_wall_attachment` | Q4: Roof-to-Wall | `FormDataKeys.wm_q4RoofWallAttachment` | `formData[windMit]['q4.roofWallAttachment']` | String | Yes | |
| 31 | `radio.wind_q5_roof_geometry` | Q5: Roof Geometry | `FormDataKeys.wm_q5RoofGeometry` | `formData[windMit]['q5.roofGeometry']` | String | Yes | |
| 32 | `radio.wind_q6_secondary_water_resistance` | Q6: SWR | `FormDataKeys.wm_q6SecondaryWaterResistance` | `formData[windMit]['q6.secondaryWaterResistance']` | String | Yes | |
| 33 | `radio.wind_q7_opening_protection` | Q7: Opening Protection | `FormDataKeys.wm_q7OpeningProtection` | `formData[windMit]['q7.openingProtection']` | String | Yes | A/B/C/N |
| 34-37 | `numeric.wind_q7_*_count` (4 items) | Q7 opening counts | `FormDataKeys.wm_q7WindowCount` etc. | `formData[windMit]['q7.windowCount']` etc. | int | Yes | |
| 38 | `radio.wind_q8_opening_protection_scope` | Q8: Scope | `FormDataKeys.wm_q8OpeningProtectionScope` | `formData[windMit]['q8.openingProtectionScope']` | String | Yes | |
| 39 | `text.inspector_name` | Inspector Name | `UniversalPropertyFields.inspectorName` | `universal.inspectorName` | String | Yes | Universal |
| 40 | `text.inspector_license_number` | License Number | `UniversalPropertyFields.inspectorLicenseNumber` | `universal.inspectorLicenseNumber` | String | Yes | Universal |
| 41 | `date.inspector_signature_date` | Date Signed | `SharedBuildingSystemFields.signatureDate` | `shared.signatureDate` | DateTime? | Yes | Shared |
| 42 | `text.inspector_company` | Company | `UniversalPropertyFields.inspectorCompany` | `universal.inspectorCompany` | String | Yes | Universal |
| 43 | `text.inspector_phone` | Phone | `SharedBuildingSystemFields.inspectorPhone` | `shared.inspectorPhone` | String? | Yes | Shared |
| 44 | `checkbox.wind_reinspection` | Reinspection | `FormDataKeys.wm_inspectorReinspection` | `formData[windMit]['inspector.reinspection']` | bool | Yes | |
| 45 | `text.wind_comments` | Comments | `FormDataKeys.wm_inspectorComments` | `formData[windMit]['inspector.comments']` | String? | No | Form-specific |

**Wind Mit Count**: 8 universal + 4 shared + 16 form-specific + 20 media = **48 schema slots** against ~45 FIELD_INVENTORY fields.

---

## 5. WDO Inspection (FDACS-13645)

All 51 fields (49 unique + 2 repeats) mapped. Repeat fields (5.5 property_address, 5.6 inspection_date) map to the same universal fields and are excluded.

| # | FIELD_INVENTORY Key | Field Name | Schema Location | Schema Path/Key | Type | Required | Notes |
|---|-------------------|------------|----------------|-----------------|------|----------|-------|
| 1.1 | `text.wdo_company_name` | Company Name | `UniversalPropertyFields.inspectorCompany` | `universal.inspectorCompany` | String | Yes | Universal |
| 1.2 | `text.wdo_business_license` | Business License | `FormDataKeys.wdo_headerBusinessLicense` | `formData[wdo]['header.businessLicense']` | String | Yes | Form-specific |
| 1.3 | `text.wdo_company_address` | Company Address | `FormDataKeys.wdo_headerCompanyAddress` | `formData[wdo]['header.companyAddress']` | String | Yes | |
| 1.4 | `text.wdo_phone` | Phone | `SharedBuildingSystemFields.inspectorPhone` | `shared.inspectorPhone` | String? | Yes | Shared |
| 1.5 | `text.wdo_company_city_state_zip` | City/State/Zip | `FormDataKeys.wdo_headerCompanyCityStateZip` | `formData[wdo]['header.companyCityStateZip']` | String | Yes | |
| 1.6 | `date.wdo_inspection_date` | Inspection Date | `UniversalPropertyFields.inspectionDate` | `universal.inspectionDate` | DateTime | Yes | Universal |
| 1.7 | `text.wdo_inspector_name` | Inspector Name | `UniversalPropertyFields.inspectorName` | `universal.inspectorName` | String | Yes | Universal |
| 1.8 | `text.wdo_inspector_id_card` | ID Card Number | `UniversalPropertyFields.inspectorLicenseNumber` | `universal.inspectorLicenseNumber` | String | Yes | Universal (FDACS ID) |
| 1.9 | `text.wdo_property_address` | Property Address | `UniversalPropertyFields.propertyAddress` | `universal.propertyAddress` | String | Yes | Universal |
| 1.10 | `text.wdo_structures_inspected` | Structures Inspected | `FormDataKeys.wdo_headerStructuresInspected` | `formData[wdo]['header.structuresInspected']` | String | Yes | |
| 1.11 | `text.wdo_requested_by` | Requested by | `UniversalPropertyFields.clientName` | `universal.clientName` | String | Yes | Universal |
| 1.12 | `text.wdo_report_sent_to` | Report Sent to | `FormDataKeys.wdo_headerReportSentTo` | `formData[wdo]['header.reportSentTo']` | String? | Conditional | |
| 2.A | `checkbox.wdo_no_visible_signs` | No visible signs | `FormDataKeys.wdo_findingsNoVisibleSigns` | `formData[wdo]['findings.noVisibleSigns']` | bool | Yes | Mutex with 2.B |
| 2.B | `checkbox.wdo_visible_evidence` | Visible evidence | `FormDataKeys.wdo_findingsVisibleEvidence` | `formData[wdo]['findings.visibleEvidence']` | bool | Yes | Mutex with 2.A |
| 2.B.1 | `checkbox.wdo_live_wdo` | Live WDOs | `FormDataKeys.wdo_findingsLiveWdo` | `formData[wdo]['findings.liveWdo']` | bool? | Conditional | When 2.B |
| 2.B.1a | `text.wdo_live_wdo_description` | Live WDO desc | `FormDataKeys.wdo_findingsLiveWdoDescription` | `formData[wdo]['findings.liveWdoDescription']` | String? | Conditional | When 2.B.1 |
| 2.B.2 | `checkbox.wdo_evidence_of_wdo` | Evidence of WDO | `FormDataKeys.wdo_findingsEvidenceOfWdo` | `formData[wdo]['findings.evidenceOfWdo']` | bool? | Conditional | When 2.B |
| 2.B.2a | `text.wdo_evidence_description` | Evidence desc | `FormDataKeys.wdo_findingsEvidenceDescription` | `formData[wdo]['findings.evidenceDescription']` | String? | Conditional | When 2.B.2 |
| 2.B.3 | `checkbox.wdo_damage_by_wdo` | Damage by WDO | `FormDataKeys.wdo_findingsDamageByWdo` | `formData[wdo]['findings.damageByWdo']` | bool? | Conditional | When 2.B |
| 2.B.3a | `text.wdo_damage_description` | Damage desc | `FormDataKeys.wdo_findingsDamageDescription` | `formData[wdo]['findings.damageDescription']` | String? | Conditional | When 2.B.3 |
| 3.1-3.5 | Inaccessible areas (15 fields) | 5 areas x 3 fields | `FormDataKeys.wdo_inaccessible*` (15 constants) | `formData[wdo]['inaccessible.{area}.{flag/specificAreas/reason}']` | bool + String? x2 | Various | |
| 4.1 | `radio.wdo_previous_treatment` | Previous treatment | `FormDataKeys.wdo_treatmentPreviousTreatment` | `formData[wdo]['treatment.previousTreatment']` | bool | Yes | |
| 4.1a | `text.wdo_previous_treatment_desc` | Previous treatment desc | `FormDataKeys.wdo_treatmentPreviousDesc` | `formData[wdo]['treatment.previousDesc']` | String? | Conditional | When 4.1 = Yes |
| 4.2 | `text.wdo_notice_location` | Notice location | `FormDataKeys.wdo_treatmentNoticeLocation` | `formData[wdo]['treatment.noticeLocation']` | String | Yes | |
| 4.3 | `radio.wdo_treated_at_inspection` | Treated at inspection | `FormDataKeys.wdo_treatmentTreatedAtInspection` | `formData[wdo]['treatment.treatedAtInspection']` | bool | Yes | |
| 4.3a-f | Treatment sub-fields (7 fields) | Organism, pesticide, terms, methods, notice | `FormDataKeys.wdo_treatment*` (7 constants) | `formData[wdo]['treatment.*']` | Various | Conditional | When 4.3 = Yes |
| 5.1 | `text.wdo_comments` | Comments | `UniversalPropertyFields.comments` | `universal.comments` | String? | No | Universal |
| 5.3 | `signature.wdo_licensee` | Licensee signature | `FormDataKeys.wdo_certificationLicenseeSigPath` | `formData[wdo]['certification.licenseeSigPath']` | String? | Yes | WDO-specific signature |
| 5.4 | `date.wdo_signature_date` | Signature Date | `SharedBuildingSystemFields.signatureDate` | `shared.signatureDate` | DateTime? | Yes | Shared |
| 5.5 | `text.wdo_property_address_repeat` | Address (repeat) | `UniversalPropertyFields.propertyAddress` | `universal.propertyAddress` | String | Yes | Same as 1.9 |
| 5.6 | `date.wdo_inspection_date_repeat` | Date (repeat) | `UniversalPropertyFields.inspectionDate` | `universal.inspectionDate` | DateTime | Yes | Same as 1.6 |

**WDO Count**: 8 universal + 2 shared + 40 form-specific + 0 media = **50 schema slots** (51 inventory - 2 repeats + 1 compound expansion = 50).

---

## 6. Sinkhole Inspection (Citizens)

All 67 fields (59 confirmed + 8 inferred) mapped. Section 0 (property ID, 8 inferred fields) maps entirely to universal + shared.

| # | FIELD_INVENTORY Key | Field Name | Schema Location | Schema Path/Key | Type | Required | Notes |
|---|-------------------|------------|----------------|-----------------|------|----------|-------|
| 0.1 | `text.sk_insured_name` | Insured Name | `UniversalPropertyFields.clientName` | `universal.clientName` | String | Yes | Universal |
| 0.2 | `text.sk_property_address` | Property Address | `UniversalPropertyFields.propertyAddress` | `universal.propertyAddress` | String | Yes | Universal |
| 0.3 | `text.sk_policy_number` | Policy Number | `SharedBuildingSystemFields.policyNumber` | `shared.policyNumber` | String? | Yes | Shared |
| 0.4 | `date.sk_inspection_date` | Inspection Date | `UniversalPropertyFields.inspectionDate` | `universal.inspectionDate` | DateTime | Yes | Universal |
| 0.5 | `text.sk_inspector_name` | Inspector Name | `UniversalPropertyFields.inspectorName` | `universal.inspectorName` | String | Yes | Universal |
| 0.6 | `text.sk_inspector_license` | License Number | `UniversalPropertyFields.inspectorLicenseNumber` | `universal.inspectorLicenseNumber` | String | Yes | Universal |
| 0.7 | `text.sk_inspector_company` | Company | `UniversalPropertyFields.inspectorCompany` | `universal.inspectorCompany` | String | Yes | Universal |
| 0.8 | `text.sk_inspector_phone` | Phone | `SharedBuildingSystemFields.inspectorPhone` | `shared.inspectorPhone` | String? | Yes | Shared |
| 1.1-1.5 | Exterior checklist (10 fields) | 5 items x (ternary + detail) | `FormDataKeys.sk_exterior*` (10 constants) | `formData[sinkhole]['exterior.*']` | String + String? | Yes/Cond | Yes->Detail required |
| 1.4 | `yes_no_na.sk_1_4` | Foundation cracks | `SharedBuildingSystemFields.foundationCracks` + `FormDataKeys.sk_exteriorFoundationCracks` | `shared.foundationCracks` + `formData[sinkhole]['exterior.foundationCracks']` | bool? + String | Yes | Shared bool + form ternary |
| 2.1-2.8 | Interior checklist (16 fields) | 8 items x (ternary + detail) | `FormDataKeys.sk_interior*` (16 constants) | `formData[sinkhole]['interior.*']` | String + String? | Yes/Cond | |
| 3.1-3.2 | Garage checklist (4 fields) | 2 items x (ternary + detail) | `FormDataKeys.sk_garage*` (4 constants) | `formData[sinkhole]['garage.*']` | String + String? | Yes/Cond | |
| 4.1-4.4 | Appurtenant checklist (8 fields) | 4 items x (ternary + detail) | `FormDataKeys.sk_appurtenant*` (8 constants) | `formData[sinkhole]['appurtenant.*']` | String + String? | Yes/Cond | |
| 5.1-5.5 | Additional info (5 fields) | General condition, adjacent, sinkhole dist, findings, unable | `FormDataKeys.sk_additional*` (5 constants) | `formData[sinkhole]['additional.*']` | String | Various | |
| 6.1-6.4 | Scheduling attempts (16 fields) | 4 attempts x 4 fields | `FormDataKeys.sk_schedulingAttempt*` (16 constants) | `formData[sinkhole]['scheduling.attempts.{N}.*']` | String? | Conditional | When unable to schedule |

**Sinkhole Count**: 8 universal + 3 shared + 59 form-specific + 0 media = **70 schema slots** against 67 FIELD_INVENTORY fields. Delta: +3 from foundation_cracks appearing in both shared and form-specific.

---

## 7. Mold Assessment (Chapter 468, Part XVI)

All 21 fields mapped.

| # | FIELD_INVENTORY Key | Field Name | Schema Location | Schema Path/Key | Type | Required | Notes |
|---|-------------------|------------|----------------|-----------------|------|----------|-------|
| 1 | `text.mold_assessor_name` | Assessor Name | `UniversalPropertyFields.inspectorName` | `universal.inspectorName` | String | Yes | Universal |
| 2 | `text.mold_mrsa_license` | MRSA License | `UniversalPropertyFields.inspectorLicenseNumber` | `universal.inspectorLicenseNumber` | String | Yes | Universal |
| 3 | `text.mold_company_name` | Company Name | `UniversalPropertyFields.inspectorCompany` | `universal.inspectorCompany` | String | Yes | Universal |
| 4 | `text.mold_client_name` | Client Name | `UniversalPropertyFields.clientName` | `universal.clientName` | String | Yes | Universal |
| 5 | `text.mold_property_address` | Property Address | `UniversalPropertyFields.propertyAddress` | `universal.propertyAddress` | String | Yes | Universal |
| 6 | `date.mold_assessment_dates` | Assessment Date(s) | `UniversalPropertyFields.inspectionDate` + `FormDataKeys.ma_headerAssessmentEndDate` | `universal.inspectionDate` + `formData[mold]['header.assessmentEndDate']` | DateTime + String? | Yes | Start in universal; end in form-specific |
| 7 | `text.mold_weather_conditions` | Weather Conditions | `FormDataKeys.ma_headerWeatherConditions` | `formData[mold]['header.weatherConditions']` | String | Yes | |
| 8 | `text.mold_building_type` | Building Type | `FormDataKeys.ma_headerBuildingType` | `formData[mold]['header.buildingType']` | String | Yes | |
| 9 | `text.mold_building_age` | Building Age | `SharedBuildingSystemFields.yearBuilt` | `shared.yearBuilt` | int? | Yes | Converted from age to year at entry |
| 10 | `enum.mold_hvac_status` | HVAC Status | `FormDataKeys.ma_headerHvacStatus` | `formData[mold]['header.hvacStatus']` | String | Yes | |
| 11 | `list.mold_areas_assessed` | Areas Assessed | `FormDataKeys.ma_scopeAreasAssessed` | `formData[mold]['scope.areasAssessed']` | List<String> | Yes | |
| 12 | `list.mold_areas_not_assessed` | Areas Not Assessed | `FormDataKeys.ma_scopeAreasNotAssessed` | `formData[mold]['scope.areasNotAssessed']` | List<String> | Yes | |
| 13 | `list.mold_moisture_sources` | Moisture Sources | `FormDataKeys.ma_findingsMoistureSources` | `formData[mold]['findings.moistureSources']` | List<String>? | Conditional | When moisture found |
| 14 | `list.mold_moisture_readings` | Moisture Readings | `FormDataKeys.ma_findingsMoistureReadings` | `formData[mold]['findings.moistureReadings']` | List<String> | Yes | |
| 15 | `list.mold_visible_locations` | Visible Mold Locations | `FormDataKeys.ma_findingsVisibleLocations` | `formData[mold]['findings.visibleLocations']` | List<String>? | Conditional | When mold found |
| 16 | `list.mold_sample_locations` | Sample Locations | `FormDataKeys.ma_samplingSampleLocations` | `formData[mold]['sampling.sampleLocations']` | List<String>? | Conditional | When samples taken |
| 17 | `text.mold_lab_name` | Lab Name | `FormDataKeys.ma_samplingLabName` | `formData[mold]['sampling.labName']` | String? | Conditional | When samples taken |
| 18 | `text.mold_lab_report_number` | Lab Report Number | `FormDataKeys.ma_samplingLabReportNumber` | `formData[mold]['sampling.labReportNumber']` | String? | Conditional | When samples taken |
| 19 | `boolean.mold_remediation_recommended` | Remediation Recommended | `FormDataKeys.ma_remediationRecommended` | `formData[mold]['remediation.recommended']` | bool | Yes | |
| 20 | `text.mold_remediation_scope` | Remediation Scope | `FormDataKeys.ma_remediationScope` | `formData[mold]['remediation.scope']` | String? | Conditional | When recommended |
| 21 | `text.mold_reoccupancy_criteria` | Re-occupancy Criteria | `FormDataKeys.ma_remediationReoccupancyCriteria` | `formData[mold]['remediation.reoccupancyCriteria']` | String? | Conditional | When recommended |

**Mold Count**: 8 universal (6 used) + 1 shared + 16 form-specific + 0 media = **23 schema slots** against 21 FIELD_INVENTORY fields. Delta: +2 from assessmentEndDate (split from multi-day) and licenseType.

---

## 8. General Home Inspection (Rule 61-30.801)

### 8.1 Header Fields (10)

| # | FIELD_INVENTORY Key | Field Name | Schema Location | Schema Path/Key | Type | Required | Notes |
|---|-------------------|------------|----------------|-----------------|------|----------|-------|
| 1 | `text.gi_property_address` | Property Address | `UniversalPropertyFields.propertyAddress` | `universal.propertyAddress` | String | Yes | Universal |
| 2 | `text.gi_property_description` | Property Description | `FormDataKeys.gi_headerPropertyDescription` | `formData[general]['header.propertyDescription']` | String? | No | |
| 3 | `date.gi_inspection_date` | Inspection Date | `UniversalPropertyFields.inspectionDate` | `universal.inspectionDate` | DateTime | Yes | Universal |
| 4 | `time.gi_inspection_time` | Inspection Time | `FormDataKeys.gi_headerInspectionTime` | `formData[general]['header.inspectionTime']` | String | Yes | |
| 5 | `text.gi_report_number` | Report Number | `FormDataKeys.gi_headerReportNumber` | `formData[general]['header.reportNumber']` | String | Yes | |
| 6 | `text.gi_customer_names` | Customer Name(s) | `UniversalPropertyFields.clientName` | `universal.clientName` | String | Yes | Universal |
| 7 | `text.gi_inspector_company` | Company | `UniversalPropertyFields.inspectorCompany` | `universal.inspectorCompany` | String | Yes | Universal |
| 8 | `text.gi_inspector_name` | Inspector Name | `UniversalPropertyFields.inspectorName` | `universal.inspectorName` | String | Yes | Universal |
| 9 | `currency.gi_inspection_fee` | Inspection Fee | `FormDataKeys.gi_headerInspectionFee` | `formData[general]['header.inspectionFee']` | double | Yes | |
| 10 | `enum.gi_payment_method` | Payment Method | `FormDataKeys.gi_headerPaymentMethod` | `formData[general]['header.paymentMethod']` | String | Yes | |

### 8.2 Section Fields (12 sections)

Each of the 12 General Inspection sections maps as follows:

| Section | General Info Fields -> FormDataKeys | Checkpoints -> FormDataKeys | Notes -> FormDataKeys |
|---------|-------------------------------------|----------------------------|----------------------|
| Roof/Deck | `gi_roofDeckStyle`, `gi_roofDeckCovering`, `gi_roofDeckFlashing`, `gi_roofDeckGuttersDownspouts`, `gi_roofDeckObservationMethod` | `gi_roofDeckCheckpoints` | `gi_roofDeckNotes` |
| Electrical | `gi_electricalServiceLine`, `gi_electricalConductors`, `gi_electricalPanelLocation`, `gi_electricalPanelCapacity`, `gi_electricalConductorType`, `gi_electricalBranchConductor`, `gi_electricalSubPanelCircuits`, `gi_electricalGfci`, `gi_electricalSystemGround` | `gi_electricalCheckpoints` | `gi_electricalNotes` |
| Plumbing | `gi_plumbingMainLineMaterial`, `gi_plumbingDiameter`, `gi_plumbingValveLocation`, `gi_plumbingHoseBibLocations`, `gi_plumbingWasteLineMaterial`, `gi_plumbingFuelSystem`, `gi_plumbingPressureTestPsi`, `gi_plumbingPressureTestTime` | `gi_plumbingCheckpoints` | `gi_plumbingNotes` |
| Water Heater | `gi_waterHeaterManufacturer`, `gi_waterHeaterCapacity`, `gi_waterHeaterApproxAge`, `gi_waterHeaterPlumbingType`, `gi_waterHeaterEnclosureType`, `gi_waterHeaterFuelSystem`, `gi_waterHeaterBase` | `gi_waterHeaterCheckpoints` | `gi_waterHeaterNotes` |
| Heating | `gi_heatingLocation1..3`, `gi_heatingLocation1..3Manufacturer`, `gi_heatingType`, `gi_heatingFuelType` | `gi_heatingCheckpoints` | `gi_heatingNotes` |
| AC | `gi_acLocation1..3`, `gi_acLocation1..3Manufacturer`, `gi_acType`, `gi_acPower`, `gi_acDisconnect`, `gi_acDefects` | `gi_acCheckpoints` | `gi_acNotes` |
| Structure | (none -- rule-derived) | `gi_structureCheckpoints` | `gi_structureNotes` |
| Exterior | (none -- rule-derived) | `gi_exteriorCheckpoints` | `gi_exteriorNotes` |
| Interior | (none -- rule-derived) | `gi_interiorCheckpoints` | `gi_interiorNotes` |
| Insulation | (none -- rule-derived) | `gi_insulationCheckpoints` | `gi_insulationNotes` |
| Appliances | (none -- rule-derived) | `gi_appliancesCheckpoints` | `gi_appliancesNotes` |
| Life Safety | (none -- rule-derived) | `gi_lifeSafetyCheckpoints` | `gi_lifeSafetyNotes` |

Shared fields used by General Inspection: `yearBuilt`, `roofCoveringMaterial`, `roofAge`, `roofCondition`, `electricalPanelType`, `electricalPanelAmps`, `plumbingPipeMaterial`, `waterHeaterType`, `hvacType`, `foundationCracks`, `inspectorPhone` (11 of 13).

**General Count**: 8 universal (6 used) + 11 shared + 76 form-specific + 0 media = **95 schema slots** against ~150+ FIELD_INVENTORY fields. Delta: checkpoint compression (individual checkpoint items stored in List<Map> under single keys).

---

## 9. Cross-Form Field Sharing Summary

### 9.1 Universal Fields (8) -- Form Usage

| Field | 4P | RC | WM | WDO | SK | MA | GI | Count |
|-------|----|----|-----|-----|----|----|-----|-------|
| `propertyAddress` | x | x | x | x | x | x | x | 7 |
| `inspectionDate` | x | x | x | x | x | x | x | 7 |
| `inspectorName` | x | x | x | x | x | x | x | 7 |
| `inspectorCompany` | x | x | x | x | x | x | x | 7 |
| `inspectorSignaturePath` | x | x | x | x | x | x | x | 7 |
| `inspectorLicenseNumber` | x | x | x | x | x | x | . | 6 |
| `clientName` | x | x | x | x | x | x | x | 7 |
| `comments` | x | x | x | x | x | x | x | 7 |
| **Universal field-form mappings** | | | | | | | | **55** |

### 9.2 Shared Fields (13) -- Form Usage

| Field | 4P | RC | WM | WDO | SK | MA | GI | Count |
|-------|----|----|-----|-----|----|----|-----|-------|
| `yearBuilt` | x | x | x | . | . | x | x | 5 |
| `policyNumber` | x | x | x | . | x | . | . | 4 |
| `inspectorPhone` | . | . | x | x | x | . | x | 4 |
| `signatureDate` | x | x | x | x | . | . | . | 4 |
| `roofCoveringMaterial` | x | x | . | . | . | . | x | 3 |
| `roofAge` | x | x | . | . | . | . | x | 3 |
| `roofCondition` | x | x | . | . | . | . | x | 3 |
| `electricalPanelType` | x | . | . | . | . | . | x | 2 |
| `electricalPanelAmps` | x | . | . | . | . | . | x | 2 |
| `plumbingPipeMaterial` | x | . | . | . | . | . | x | 2 |
| `waterHeaterType` | x | . | . | . | . | . | x | 2 |
| `hvacType` | x | . | . | . | . | . | x | 2 |
| `foundationCracks` | . | . | . | . | x | . | x | 2 |
| **Shared field-form mappings** | | | | | | | | **38** |

### 9.3 Form-Specific Constants

| Form Type | FormDataKeys Constants |
|-----------|----------------------|
| 4-Point | 111 |
| Roof Condition | 15 |
| Wind Mitigation | 16 |
| WDO | 40 |
| Sinkhole | 59 |
| Mold Assessment | 16 |
| General Inspection | 76 |
| **Total** | **333** |

---

## 10. Grand Total Count Verification

| Category | Count | Method |
|----------|-------|--------|
| Universal field-form mappings | 55 | 8 fields x ~7 forms each = 55 individual usages |
| Shared field-form mappings | 38 | 13 fields x (2-5 forms each) = 38 individual usages |
| Form-specific FormDataKeys constants | 333 | Sum of all form-specific constants |
| **Total unique schema slots** | **426** | 8 + 13 + 333 = 354 unique fields; 426 includes per-form usage of shared/universal |
| **FIELD_INVENTORY total** | **~486** | From Section 1.1 (approximate) |
| **Delta** | **~60 fewer schema slots** | Explained below |

### Delta Explanation

The ~60 difference between FIELD_INVENTORY (~486) and total unique schema slots (354) is accounted for:

1. **Photo/evidence fields (~55)**: All `checkbox.photo_*` and `image.photo_*` fields from 4-Point (24), RCF-1 (6), Wind Mit (18) plus implied evidence fields for other forms are managed by the media module, not formData. They do not generate FormDataKeys constants.

2. **Repeat fields (2)**: WDO fields 5.5 and 5.6 are repeats of property address and inspection date.

3. **General Inspection checkpoint compression (~75)**: The ~150+ fields in General Inspection include individual checkpoint items (e.g., 12 Electrical items). These are compressed into `List<Map>` values stored under single keys (e.g., `electrical.checkpoints`), reducing ~95 individual checkpoint items to 12 checkpoint keys.

4. **Offset by expansions (+~15)**: Compound fields (checkbox+text pairs) expand to 2 constants each, and secondary roof mirrors all primary fields.

**Net**: 486 - 55 (media) - 2 (repeats) - 75 (checkpoint compression) + 15 (expansions) = ~369, which aligns with the 354 unique fields + overhead from dual-location fields (shared + form-specific copies).
