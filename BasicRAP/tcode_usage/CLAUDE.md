# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**tcode_usage** is a backend migration project: converting an existing SAP GUI ALV report (transaction usage collector) into a **Fiori Elements List Report** using RAP (REST API Programming).

This folder contains the **first phase**: the reusable backend data loader (`zcl_tcode_usage_loader`), validation via test reports, and initial persistence to a custom database table.

## Architecture Overview

### Current Components

- **zcl_tcode_usage_loader** (class)
  - Calls SAP function `SWNC_COLLECTOR_GET_AGGREGATES` to fetch workload data
  - Filters transaction codes matching `Z*` pattern (custom/client-specific transactions)
  - Aggregates execution counts
  - Returns a typed table `tt_tcode_count` (tcode + count)
  - No side effects; pure data-fetch logic

- **zdt_tcode_usage** (custom database table)
  - Persists aggregated usage results with metadata (period, program, load_id, timestamp, user)
  - Used by the persist test to store history for CDS/RAP querying

- **Test Reports**
  - `ZTEST_TCODE_USAGE_FETCH`: validates data fetching from the workload collector
  - `ZTEST_TCODE_USAGE_PERSIST`: validates end-to-end flow (fetch → join with TSTC → persist to table)

### Data Flow

```
SWNC_COLLECTOR_GET_AGGREGATES → zcl_tcode_usage_loader.load()
           ↓
    [Filter Z* | Aggregate counts]
           ↓
    tt_tcode_count (internal table)
           ↓
    [Optional] Join with TSTC for program names → zdt_tcode_usage (persist)
           ↓
    [Next phase] CDS view → RAP entity → Fiori List Report
```

## Development Workflow

### Activate & Test Code in ADT/VS Code

1. **Activate the class:**
   - Right-click `zcl_tcode_usage_loader.abap` → Activate (Ctrl+F3)
   - Confirm no errors

2. **Run the fetch test:**
   - Right-click `ZTEST_TCODE_USAGE_FETCH.abap` → Run as ABAP Program (Ctrl+F9)
   - Verify output shows Z-transaction codes and counts
   - **Expected**: See transaction codes like Z* with exec counts

3. **Run the persist test:**
   - Right-click `ZTEST_TCODE_USAGE_PERSIST.abap` → Run as ABAP Program (Ctrl+F9)
   - Verify it writes rows to `zdt_tcode_usage`
   - Check table contents: SE11 or `SELECT * FROM zdt_tcode_usage` in a test report

### Common ABAP Patterns in Use

- **Modern ABAP Syntax**: classes, inline declarations (`DATA(...)`), VALUE expressions, FOR loops
- **Hashed Tables**: used for efficient lookups (e.g., aggregation by tcode)
- **Field-Symbols** `<ls_field>`: loop-assign for in-place mutations
- **SET-BASED SQL**: `SELECT ... FOR ALL ENTRIES IN` for batch lookups
- **Exception Handling**: `cx_root` for propagating unexpected errors
- **Idempotent Persistence**: DELETE old period data before INSERT (safe re-run)

## Next Steps in the Migration

The **readme.md** outlines the remaining phases:

1. ✅ **Phase 1 (done)**: Data loader class + test validation
2. ⏳ **Phase 2** (next): Create CDS view or RAP entity on top of `zdt_tcode_usage`
   - Add Fiori annotations (title, description, UI.LineItem, etc.)
   - Generate OData service
3. ⏳ **Phase 3**: Generate Fiori Elements List Report from CDS/RAP
4. ⏳ **Phase 4**: Redirect Launchpad entry from old ALV to new Fiori app

When continuing, use **incremental steps**: explain each ABAP object and its purpose before adding it.

## Key Files

| File | Purpose |
|------|---------|
| `zcl_tcode_usage_loader.abap` | Main backend loader (do not change lightly) |
| `ZTEST_TCODE_USAGE_FETCH.abap` | Validate fetch logic |
| `ZTEST_TCODE_USAGE_PERSIST.abap` | Validate fetch + persist flow |
| `readme.md` | High-level migration plan and status |

## Important Reminders

- The old ALV report is still the UI entry point; do not remove it until the Fiori app is ready.
- The class is the **source of truth** for data logic; UI changes should not affect the loader.
- Always activate code in ADT before testing.
- Use SE11 or a test report to inspect table `zdt_tcode_usage` after running persist tests.
- This project is part of a larger **ABAP_SKILLS** learning repository; keep examples clear and well-commented.
