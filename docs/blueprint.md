Absolutely — here are **all five deliverables** (wireframes, Supabase SQL schema, Flutter architecture, AI agent prompts, and PDF coordinate mapping plan), built directly from your PDF blueprint. 

I also cross-checked the **latest public form sources** your doc references (Citizens March 20, 2025 update; OIR-B1-1802 Rev 04/26 adopted version effective April 1, 2026). ([Public][1])

---

## 1) UI wireframes (screen-by-screen)

### A. Auth & Onboarding

**1. Welcome / Sign In**

* Email + password
* “Forgot password”
* “Create account”

**2. Create account**

* Email/password
* Inspector profile:

  * Name
  * Company name
  * Florida license type + license #
  * Phone
* Save → dashboard

**3. Signature setup**

* Draw signature (canvas)
* Save as PNG to `users.signature_url`
* Store signature metadata (hash/timestamp/IP per your non-repudiation plan) 

---

### B. Dashboard & Inspectspection” primary button

* “In Progress” list
* “Completed / Delivered” list
* Quick filters: Draft / Completed / Sync pending

**5. New Inspection (Create)**

* Inspection types (multi-select):

  * 4-Point (Insp4pt 03 25)
  * Roof Condition (RCF-1 03 25)
  * Wind Mitigation (OIR-B1-1802 Rev 04/26, effective 4/1/2026) ([Public][1])
* Client name + phone + email
* Property address (with validation/autocomplete)
* Inspection date
* Year built
* Save → Wizard start

**6. Inspection Summary (Hub)**

* Progress bar for each enabled form
* Required photo checklist (red/green)
* “Generate PDF” disabled until required items met (your doc’s compliance gate) 

---

### C. Linear Wizard (state-machine UI)

This is the “flashlight + phone” optimized flow your doc describes. ard Step Template (reusable)**

* Top: step name + “Why it matters” tooltip (optional)
* Middle: required inputs
* Boto” / “Next”
* Hard validation: cannot proceed if required input/photo missing

#### 4-Point Wizard Sections (Insp4pt 03 25)

**8. Exterior elevations**

* Capture: Front/Rear/Left/Right photos (required) 

**9. Roofing**

* Predominant material
* Secondary roof present? (yes/no → conditional fields)
* Permit dates (including p
* Capture: each roof slope photos (required) 

**10. Plumbing**

* Supply system age
* Draincomplete re-pipe
* Water heater age
* PEX year
* Capture:

  * Water heater photo **with TPR valve visible** (required) 
  * Under-sink plumequired) 

**11. Electrical**

* Wiring typnum, single-strand aluminum, multi-strand aluminum, cloth, 
* If single-strand aluminum → remediation proof required (COPALUM/AlumiConn) 
* Capture:
  gible (required) 

  * Panel “deadfront removed”

**12. HVAC**

* Heating system type
* Ma 
* Hazard bifurcatice true → “professionally installed?” required cies**
* Add hazard entries (type, notes)
* Each hazard requires photo evidence tion Wizard (RCF-1 03 25)
  **14. Roof condition**
* Predominant + secondary covering data
* Roof age, remaipartial replacement 
* Checklist booleans (cracking, cupping, granule loss, soft spots, etc.) 
* Photos: each sl

#### Wind Mitigation Wizard (OIR-B1-1802 Rev. 7-category flow**

1. Roof slope (≥6:12 vs <6
2. Roof covering(s): permit date + product approval # + install year 
3. Roof deck attacases 
4. Roof-to-wall attachment type 
5. Roof geometry classification ptions kest level A–Z with standards refer

Each category requiper your doc’s compliance-first approach). , Generate, Deliver
**16. Review & Validation**

* “Missing requirements” list:

  * missing fields Inline jump to fix

**17. Signature**

* Inspector signature auto from profile OR draw again
* Optional client acknowledgement signature
* Store signature object with hash/timestamp/IP 

**18. Generate PDF**

* Select output(s): 4-Point / Roof / Wind
* “Generate” button
* Progress indicator
* Result: PDF pre*
* Share methods:

  * Download
  * Email (agent/client)
  * Secure link (time-limited)
* Log delivery + downloads (audit trail; breach response readiness) 

---

## 2) Supabase PostgreSQL schema (SQL, production-ready baseline)

> Includes: multi-tenant isolation, normalized tat hooks, and audit logging. It mirrors the tables your doc proposes and expands them to be build-ready. 

```sql
-- Extensions
create extension if not exists pgcrypto;

-- ---------- ENUMS ----------
do $$ begin
  create type i:contentReference[oaicite:61]{index=61}t','in_progress','completed','delivered','archived');
exception when duplicate_object then null; end $$;

do $$ begin
  create type form_type as enum ('four_point','roof_condition','wind_mitigation');
exception when duplicate_object then null; end $$;

do $$ begin
  create type media_kind as enum ('photo','signature','attachment');
exception when duplicate_object then null; end $$;

-- ---------- USERS (profile augment; Supabase auth.users is canonical) ----------
create table if not exists public.user_profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  company_name text,
  license_type text,
  license_number text,
  phone text,
  signature_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ---------- INSPECTIONS ----------
create table if not exists public.inspections (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  client_name text,
  client_email text,
  client_phone text,
  property_address text not null,
  inspection_date date not null,
  year_built int,
  status inspection_status not null default 'draft',
  -- Which forms are included in this inspection visit
  forms_enabled form_type[] not null default '{}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_inspections_user on public.inspections(user_id);
create index if not exists idx_inspections_status on public.inspections(status);

-- ---------- 4-POINT FORM ----------
create table if not exists public.form_four_point (
  id uuid primary key default gen_random_uuid(),
  inspection_id uuid not null unique references public.inspections(id) on delete cascade,

  -- Electrical
  electrical_wiring_types text[] not null default '{}',
  aluminum_single_strand_present boolean,
  al_remediation_certified boolean, -- required if single-strand aluminum selected

  -- Plumbing
  plumbing_supply_age_years int,
  plumbing_drain_age_years int,
  plumbing_drain_status text, -- 'original' | 'partial_repipe' | 'full_repipe'
  plumbing_pex_year int, -- mandatory integer if PEX selected
  water_heater_age_years int,

  -- HVAC
  hvac_type text,
  hvac_wood_stove_present boolean,
  hvac_wood_stove_professional_install boolean, -- required if stove present

  -- Roof
  roof_predominant_material text,
  roof_secondary_material text,
  roof_last_permit_date date,
  roof_secondary_last_permit_date date,

  -- Notes / hazards summary
  notes text,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ---------- ROOF CONDITION (RCF-1) ----------
create table if not exists public.form_roof_condition (
  id uuid primary key default gen_random_uuid(),
  inspection_id uuid not null unique references public.inspections(id) on delete cascade,

  predominant_covering text,
  secondary_covering text,
  roof_age_years int,
  remaining_life_years int,
  last_update_date date,
  last_permit_date date,
  partial_replacement_percent int, -- 0-100

  -- condition checklist
  cracking boolean,
  cupping_curling boolean,
  granule_loss boolean,
  exposed_asphalt boolean,
  exposed_felt boolean,
  missing_loose_cracked boolean,
  soft_spots boolean,
  hail_damage boolean,
  visible_leaks boolean,

  notes text,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ---------- WIND MITIGATION (OIR-B1-1802 Rev 04/26) ----------
create table if not exists public.form_wind_mitigation (
  id uuid primary key default gen_random_uuid(),
  inspection_id uuid not null unique references public.inspections(id) on delete cascade,

  -- 1 Roof slope
  roof_slope_gte_6_12 boolean,

  -- 2 Roof covering(s)
  roof_coverings text[] not null default '{}', -- supports multiple coverings
  roof_permit_application_date date,
  roof_product_approval_number text,
  roof_install_year int,

  -- 3 Roof deck attachment
  roof_deck_attachment_level text, -- 'A'..'E' plus special
  roof_deck_attachment_detail text,

  -- 4 Roof-to-wall attachment
  roof_to_wall_attachment_type text, -- toe-nail/clip/single-wrap/double-wrap/anchor/etc

  -- 5 Roof geometry
  roof_geometry text, -- hip/flat/other

  -- 6 SWR
  swr_present boolean,
  swr_method text, -- peel&stick, taped seams, spray foam, etc.

  -- 7 Opening protection weakest
  opening_protection_weakest text, -- A..Z
  opening_protection_standard_refs text,

  fortified_certificate_level text, -- roof/silver/gold (optional)
  fortified_certificate_media_asset_id uuid, -- optional attachment/photo

  notes text,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ---------- MEDIA ASSETS ----------
create table if not exists public.media_assets (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  inspection_id uuid references public.inspections(id) on delete cascade,

  kind media_kind not null default 'photo',
  form form_type, -- which form the asset supports (optional)
  category text not null, -- e.g., 'EXTERIOR_FRONT', 'TPR_VALVE', 'PANEL_OPEN'
  storage_path text not null, -- Supabase Storage path (private bucket recommended)
  storage_url text, -- optionally computed signed URL (do NOT store long-lived public URL if private)
  blur_hash text,

  width_px int,
  height_px int,
  byte_size int,
  captured_at timestamptz,
  created_at timestamptz not null default now()
);

create index if not exists idx_media_inspection on public.media_assets(inspection_id);
create index if not exists idx_media_category on public.media_assets(category);

-- ---------- SIGNATURES ----------
create table if not exists public.signatures (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  inspection_id uuid not null references public.inspections(id) on delete cascade,

  signer_role text not null, -- 'inspector'|'client'
  signed_name text,
  signature_media_asset_id uuid not null references public.media_assets(id) on delete restrict,

  signed_at timestamptz not null default now(),
  source_ip inet,
  signature_hash text, -- sha256 over (inspection_id + signer + media bytes + timestamp)
  created_at timestamptz not null default now()
);

-- ---------- AUDIT LOG ----------
create table if not exists public.audit_log (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  inspection_id uuid references public.inspections(id) on delete set null,
  action text not null, -- created/updated/generated_pdf/delivered/downloaded/etc
  details jsonb not null default '{}'::jsonb,
  occurred_at timestamptz not null default now()
);

-- ---------- UPDATED_AT trigger helper ----------
create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end; $$;

do $$ begin
  create trigger trg_user_profiles_updated
  before update on public.user_profiles
  for each row execute function public.set_updated_at();
exception when duplicate_object then null; end $$;

do $$ begin
  create trigger trg_inspections_updated
  before update on public.inspections
  for each row execute function public.set_updated_at();
exception when duplicate_object then null; end $$;

do $$ begin
  create trigger trg_four_point_updated
  before update on public.form_four_point
  for each row execute function public.set_updated_at();
exception when duplicate_object then null; end $$;

do $$ begin
  create trigger trg_roof_condition_updated
  before update on public.form_roof_condition
  for each row execute function public.set_updated_at();
exception when duplicate_object then null; end $$;

do $$ begin
  create trigger trg_wind_mit_updated
  before update on public.form_wind_mitigation
  for each row execute function public.set_updated_at();
exception when duplicate_object then null; end $$;

-- ---------- ROW LEVEL SECURITY ----------
alter table public.user_profiles enable row level security;
alter table public.inspections enable row level security;
alter table public.form_four_point enable row level security;
alter table public.form_roof_condition enable row level security;
alter table public.form_wind_mitigation enable row level security;
alter table public.media_assets enable row level security;
alter table public.signatures enable row level security;
alter table public.audit_log enable row level security;

-- Profiles
create policy "profiles_owner_read" on public.user_profiles
for select using (auth.uid() = user_id);

create policy "profiles_owner_write" on public.user_profiles
for insert with check (auth.uid() = user_id);

create policy "profiles_owner_update" on public.user_profiles
for update using (auth.uid() = user_id);

-- Inspections
create policy "inspections_owner_rw" on public.inspections
for all using (auth.uid() = user_id)
with check (auth.uid() = user_id);

-- Forms inherit ownership via inspection.user_id
create policy "four_point_owner_rw" on public.form_four_point
for all using (
  exists (select 1 from public.inspections i where i.id = inspection_id and i.user_id = auth.uid())
)
with check (
  exists (select 1 from public.inspections i where i.id = inspection_id and i.user_id = auth.uid())
);

create policy "roof_condition_owner_rw" on public.form_roof_condition
for all using (
  exists (select 1 from public.inspections i where i.id = inspection_id and i.user_id = auth.uid())
)
with check (
  exists (select 1 from public.inspections i where i.id = inspection_id and i.user_id = auth.uid())
);

create policy "wind_mit_owner_rw" on public.form_wind_mitigation
for all using (
  exists (select 1 from public.inspections i where i.id = inspection_id and i.user_id = auth.uid())
)
with check (
  exists (select 1 from public.inspections i where i.id = inspection_id and i.user_id = auth.uid())
);

-- Media
create policy "media_owner_rw" on public.media_assets
for all using (auth.uid() = user_id)
with check (auth.uid() = user_id);

-- Signatures
create policy "signatures_owner_rw" on public.signatures
for all using (auth.uid() = user_id)
with check (auth.uid() = user_id);

-- Audit
create policy "audit_owner_read" on public.audit_log
for select using (auth.uid() = user_id);

create policy "audit_owner_write" on public.audit_log
for insert with check (auth.uid() = user_id);
```

---

## 3) Flutter app architecture (folder structure + key modules)

This matches your recommended stack (Flutter/FlutterFlow + Supabase + aggressive client compression + PDF overlay). 

### A. Project structure (clean architecture-lite)

```text
lib/
  app/
    router.dart
    theme.dart
    dependency_inje:contentReference[oaicite:63]{index=63}/
      data/ (supabase_auth_repo.dart)
      ui/ (login_page.dart, signup_page.dart)
    profile/
      ui/ (profile_page.dart, signature_setup_page.dart)
      data/ (profile_repo.dart)
    inspections/
      ui/
        dashboard_page.dart
        new_inspection_page.dart
        inspection_hub_page.dart
      data/
        inspection_repo.dart
        sync_service.dart
      domain/
        models.dart (Inspection, EnabledForms, Status)
    wizard/
      ui/
        wizard_shell.dart
        steps/
          exterior_photos_step.dart
          four_point_roof_step.dart
          four_point_plumbing_step.dart
          four_point_electrical_step.dart
          four_point_hvac_step.dart
          hazards_step.dart
          roof_condition_step.dart
          windmit_1_roof_slope_step.dart
          windmit_2_covering_step.dart
          ...
      state/
        wizard_state.dart (state machine)
        validators.dart (required gates)
    media/
      camera_service.dart
      compress_service.dart
      upload_service.dart
      blurhash_service.dart
    pdf/
      templates/
        citizens_insp4pt_03_25.pdf
        citizens_rcf1_03_25.pdf
        oir_b1_1802_rev_04_26.pdf
      mapping/
        citizens_insp4pt_map.json
        citizens_rcf1_map.json
        oir_1802_map.json
      pdf_generate_service.dart
    delivery/
      share_service.dart
      email_service.dart
      secure_link_service.dart
  common/
    widgets/
    utils/
```

### B. Core services

* **WizardStateMachine**

  * ordered steps per enabled form
  * hard gates (“cannot proceed”)
* **CompressService**

  * takes local bytes → outputs JPEG 800x600 @ ~70% quality (your doc’s plan) 
* **UploadService**

  * stores in Supabase Storage, writes DB row in `media_assets`
* **PdfGenerateService**

  * loads tem via coordinate map (details below) 
* **Offline Sync**

  * local persistence for inspection record + pending media
  * upload + reconcile when online (especiayour offline notes) 

---

## 4) AI agent prompts (to build this fast with consistent output)

These are designed for “agentic” execution: eachs**, **non-goals**, and **acceptance criteria** so you don’t get bloat (a theme in your doc). 

### Prompt 1 — Product + UX Spec Generator

**Role:** Lead Product Designer (Insurtech / Field Tools)
**Input:** This PDF  Insp4pt 03 25, RCF-1 03 25, OIR-B1-1802 Rev 04/26). ([www.weshopinsurance.com][2])
**Task:** Produce a complete UX spec:

* screen list
* navigation model (state-machine)
* per-step required inputs/photos
* error states (missing photo, invalid data)
* accessibility (one-handed, gloves, bright sun)
  **Output format:** Markdown + checklist tables
  **Acceptance criteria:** Every required photo gate is explicit; “Generate PDF” is impossible until all gates pass.

### Prompt 2 — Supabase Engineer

**Role:** Staff Backend Engineer (Supabase/Postgres security)
**Task:**

* implement schema + RLS policies
* implement audit logging events
* implement signed URL access pattern for PDFs/media
  **Output:** SQL migrations + RLS tests
  **Acceptance criteria:** user cannot read any other user’s inspection rows; media is private; signed links expire.

### Prompt 3 — Flutter Performance Engineer

**Role:** Mobile performance specialist
**Task:**

* implement compression pipeline and prove memory behavior
* implement “capture → compress → upload → DB row”
* implement fast thumbnail rendering (optional Supabase image transforms)
  **Output:** Dart services + perf notes
  **Acceptance criteria:** 20-photo inspection stays responsive; no OOM; average photo upload < 250KB.

### Prompt 4 — PDF Overlay Engineer

**Role:** Document rendering engineer (PDF coordinate overlay)
**Task:**

* implement on-device PDF generation using `pdf` + `printing`
* support text, checkbox marks, and image placement from JSON coordinate map
* flatten output
  **Output:** `pdf_generate_service.dart` + JSON schema + sample mapping entries
  **Acceptance criteria:** generated PDFs match official template positions within ±2px.

### Prompt 5 — QA + Compliance Tester

**Role:** QA lead for regulated documents
**Task:**

* build test cases that mirror underwriter rejection reasons
* validate missing photo gates
* validate file size under 10MB
* validate signature metadata presence (hash/timestamp/IP)
  **Output:** Test plan + automated checks list
  **Acceptance criteria:** cannot produce a PDF missing any mandatory Citizens photos; wind mit categories always accompanied by photos.

---

## 5) PDF coordinate mapping (exact method + starter mapping schema)

### What I can and cannot do here

* I **can** give you a production-grade mapping system and generator approach.
* I **cannot** provide the *exact final X/Y coordinates* for every checkbox/image box without measuring the official blank PDFs in a coordinate tool (your doc correctly notes this must be done with a PDF coordinate helper). 

### A. The coordinate “truth”

PDF coordinate origin is bottom-left; you’ll measure placements and encode them. 

### B. Mapping file format (JSON)

Create one map per template:

* `citizens_insp4pt_:contentReference[oaicite:75]{index=75}json`
* `oir_1802_map.json` (Rev 04/26, effective 4/1/2026) ([FLOIR][3])

**Schema:**

```jso:contentReference[oaicite:77]{index=77}p4pt_03_25",
  "pageSize": {"w": 612, "h": 792},
  "pages": [
    {
      "page": 1,
      "fields": [
        {
          "key": "client_name",
          "type": "text",
          "x": 72,
          "y": 700,
          "fontSize": 10,
          "maxWidth": 250
        },
        {
          "key": "roof_slope_photo",
          "type": "image",
          "x": 300,
          "y": 420,
          "w": 240,
          "h": 160,
          "fit": "cover"
        },
        {
          "key": "aluminum_single_strand_checkbox",
          "type": "checkbox",
          "x": 110,
          "y": 510,
          "mark": "X",
          "fontSize": 12
        }
      ]
    }
  ]
}
```

### C. How to generate the coordinate map quickly

1. Download blank official PDFs (Citizens forms + OIR adopted version) ([www.weshopinsurance.com][2])
2. Open in a coordinate tool (e.g., PDF.co helper, Apryse coordinate inspector, SigniFlow measurement)
3. For each field/photo box:

   * capture x/y/w/h
   * define `key` that matches your DB + media category string (e.g., `TPR_VALVE`) 
4. Commit JSON maps to repo and version them as forms change

### D. Required photo categories (canonical “category” values)

Use a strict enum-like list so you can:

* enforce wizard capture
* route to correct PDF box

Recommended categories (minimum from your doc):

* `EXTERIOR_FRONT`, `EXTERIOR_REAR`, `EXTERIOR_LEFT`, `EXTERIOR_RIGHT`
* `ROOF_SLOPE_1`..`ROOF_SLOPE_N`
* `WATER_HEATER_TPR_VALVE`
* `PLUMBING_UNDER_SINK`
* `ELECTRICAL_PANEL_LABEL`
* `ELECTRICAL_PANEL_OPEN`
* `HVAC_DA:contentReference[oaicite:80]{index=80}_N` 

### E. File size target enforcement

Implement a post-generate check:

* if PDF > 10MB → re-encode images more aggressively or downscale further (your doc’s “actuarial file size constraint”) 

---

## Next step (so you can actually start building immediately)

If you tell me **which PDF generation path you want**:

* **On-device** (higher margin, offline, more engineering) — aligns with your doc’s “Option B” 
* **Cloud ) — aligns with “Option A” 

…I’ll output the **exact implementation skeleton** for that path:

* Dart services (compression/upload/pdf)
* the JSON mapping loa validator
* and the Supabase storage policy pattern (private bucket + signed URLs)

No need to re-explain anything — just reply: **“On-device”** or **“Cloud API”**.



[1]: https://www.citizensfla.com/-/20250320-roof-and-4-point-inspection-form-updates?utm_source=chatgpt.com "Roof and 4-Point Inspection Form Updates - Public"
[2]: https://www.weshopinsurance.com/news/33562/22904/Citizens_Four_Point_4_Inspection_Form_Florida_2025..pdf?utm_source=chatgpt.com "4-Point Inspection Form"
[3]: https://floir.gov/docs-sf/property-casualty-libraries/product-review/all-forms/form-oir-1802-adopted-version-%28no-watermark%29.pdf?Status=Master&utm_source=chatgpt.com "Uniform Mitigation Verification Inspection Form"
