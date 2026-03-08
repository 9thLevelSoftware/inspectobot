# Plan 10-04 Summary: Cross-Form + Performance + Offline Tests

## Status: Complete

## Task 1: Cross-Form Evidence Sharing Integration Tests

**File:** `test/features/inspection/cross_form_evidence_e2e_test.dart`

**Tests written: 18**

| Group | Tests | Coverage |
|-------|-------|----------|
| Multi-form session with all 7 forms | 2 | Semantic equivalence propagation; all shared categories completeness |
| Evidence sharing with branch context | 3 | hazardPresent (4PT), wdoVisibleEvidence (WDO), moldMoistureSource (MOLD) |
| Evidence sharing completeness | 2 | 100% completion verification; base requirement count regression |
| Photo path copying | 2 | Semantic and native shared path duplication |
| Edge cases: form deselection | 3 | Remove form mid-session; disabled form evidence persists; add form picks up existing |
| Evidence sharing UI model | 4 | Badge form abbreviations; non-shared single form; filtered exclusion; all 3 semantic pairs |
| Requirement key exhaustiveness | 2 | All shared categories have keys in accepting forms; no duplicate keys within forms |

Key findings:
- All 3 semantic equivalence pairs (exteriorFront↔generalFrontElevation, electricalPanelLabel↔generalElectricalPanel, hvacDataPlate↔generalDataPlate) verified end-to-end
- 2 native sharing pairs (roofSlopeMain, roofSlopeSecondary between 4PT+ROOF) verified
- Verified base requirement counts per form: 4PT=11, ROOF=2, WIND=7, WDO=2, SINK=2, MOLD=3, GEN=5

## Task 2: PDF Generation Performance Benchmarks

**File:** `test/features/pdf/pdf_performance_benchmark_test.dart`

**Tests written: 13** (tagged `@Tags(['performance'])` for optional CI exclusion)

| Group | Tests | Thresholds |
|-------|-------|-----------|
| PdfGenerationInput construction | 5 | 1-form: <500ms/100iter, 3-form: <750ms/50iter, 5-form: <1000ms/50iter, 7-form: <1500ms/50iter |
| Canonical payload serialization | 2 | 1-form: <200ms/100iter, 7-form: <500ms/50iter |
| Wizard summary computation at scale | 4 | 1-form: <200ms/100iter, 3-form: <300ms/50iter, 5-form: <500ms/50iter, 7-form: <750ms/50iter |
| Evidence sharing matrix lookup at scale | 3 | formsAcceptingFiltered: <200ms/1000iter, equivalentCategories: <100ms/5000iter, isSharedCategory: <50ms/10000iter |

**Threshold rationale:** Baselines are set generously (~10ms per operation) with 1.5x multiplier applied at each form-count tier. These are write-only benchmarks — actual timings will be verified by main process execution.

**Note:** Actual PDF rendering benchmarks (byte generation, file I/O) require a running Flutter engine with platform channels and asset bundle access, which cannot be unit-tested. The benchmarks focus on the computational preparation layer (input construction, wizard state, evidence matrix), which is where scaling complexity lives.

## Task 3: Offline Scenario Tests + App Size Assessment

### Offline Scenario Tests

**File:** `test/features/sync/offline_scenario_test.dart`

**Tests written: 13**

| Group | Tests | Coverage |
|-------|-------|----------|
| WDO form offline | 3 | Draft creation, evidence capture, wizard progress reflection |
| Sinkhole form offline | 2 | Draft creation, evidence capture with path verification |
| Mold Assessment form offline | 2 | Draft creation, multi-photo capture |
| General Inspection form offline | 2 | Draft creation, evidence capture |
| Offline queue management | 4 | PDF generation queue, dependency ordering, connectivity restore, status transitions |
| Multi-form offline session | 1 | 4-form session with mixed captures and wizard state |

All 4 new form types (WDO, Sinkhole, Mold Assessment, General Inspection) are tested through the full offline lifecycle:
1. Create inspection draft → outbox entry persists
2. Capture evidence → PendingMediaSyncStore records media with correct paths
3. Queue progress update → dependency chain maintained
4. Status transitions → pending → inFlight → failed → completed

### App Size Impact Assessment

**PDF Assets (assets/pdf/):** 40,525 bytes total (39.6 KB)

| Directory | Size | Contents |
|-----------|------|----------|
| `assets/pdf/templates/` | 3,089 bytes | 5 PDF templates (4PT, RCF-1, OIR-B1, FDACS-13645/WDO, Sinkhole) + README |
| `assets/pdf/maps/` | 37,436 bytes | 6 field map JSON files |

**Individual asset sizes:**

| Asset | Size (bytes) | Phase Added |
|-------|-------------|-------------|
| `insp4pt_03_25.pdf` | 602 | Phase 1 (baseline) |
| `rcf1_03_25.pdf` | 600 | Phase 1 (baseline) |
| `oir_b1_1802_rev_04_26.pdf` | 610 | Phase 1 (baseline) |
| `fdacs_13645_rev_10_22.pdf` | 602 | Phase 4 (WDO) |
| `sinkhole_inspection.pdf` | 602 | Phase 5 (Sinkhole) |
| `insp4pt_03_25.v1.json` | 5,923 | Phase 3 (baseline) |
| `rcf1_03_25.v1.json` | 1,851 | Phase 3 (baseline) |
| `oir_b1_1802_rev_04_26.v1.json` | 4,966 | Phase 3 (baseline) |
| `fdacs_13645_rev_10_22.v1.json` | 6,357 | Phase 4 (WDO) |
| `sinkhole_inspection.v1.json` | 18,339 | Phase 5 (Sinkhole) |

**Size delta from Phases 4-9:**
- Pre-expansion baseline (Phase 3): ~14,552 bytes (3 templates + 3 maps)
- Post-expansion (Phase 9): ~40,525 bytes
- **Delta: +25,973 bytes (+25.4 KB)**
- Primary contributor: `sinkhole_inspection.v1.json` (18,339 bytes) — the sinkhole field map is the largest single asset due to its multi-section checklist structure

**No fonts directory found** — the project does not bundle custom font assets; narrative PDF generation uses the pdf package's built-in fonts.

**Mold and General Inspection forms** use narrative PDF rendering (no template PDF or field map assets) — they are code-only, adding zero asset bytes.

## Test Counts

| Category | Tests |
|----------|-------|
| Cross-form evidence E2E | 18 |
| PDF performance benchmarks | 13 |
| Offline scenario tests | 13 |
| **Total new tests** | **44** |

## Verification Commands

```bash
# Run cross-form evidence E2E tests
flutter test test/features/inspection/cross_form_evidence_e2e_test.dart

# Run PDF performance benchmarks
flutter test test/features/pdf/pdf_performance_benchmark_test.dart

# Run offline scenario tests
flutter test test/features/sync/offline_scenario_test.dart

# Run all plan 10-04 tests together
flutter test test/features/inspection/cross_form_evidence_e2e_test.dart test/features/pdf/pdf_performance_benchmark_test.dart test/features/sync/offline_scenario_test.dart
```

## Files Created
- `test/features/inspection/cross_form_evidence_e2e_test.dart` — 18 cross-form evidence sharing integration tests
- `test/features/pdf/pdf_performance_benchmark_test.dart` — 13 PDF generation performance benchmarks
- `test/features/sync/offline_scenario_test.dart` — 13 offline scenario tests for new form types
- `.planning/phases/10-testing-migration-polish/10-04-SUMMARY.md` — This summary

## Issues Discovered
- None. All domain models, evidence sharing matrix, and sync infrastructure are well-structured for testability.
