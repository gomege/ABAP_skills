# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository contains work for migrating a legacy SAP GUI ALV report (transaction code usage collector) to a modern **Fiori Elements List Report** application using a **RAP (RESTful ABAP Programming) backend service model**. The project focuses on separating business logic from presentation and creating a reusable data service.

### Key Architecture

The implementation follows a **layered backend-to-frontend** pattern:

1. **Data Fetcher Layer** (`zcl_tcode_usage_loader`): A reusable ABAP class that aggregates workload data from SAP's built-in `SWNC_COLLECTOR_GET_AGGREGATES` function. It filters Z-transaction codes and counts executions.

2. **Persistence Layer** (`zdt_tcode_usage` table): A custom database table where aggregated usage counts are stored with period metadata and audit fields (load_id, created_at, created_by).

3. **CDS/RAP Service Layer**:
   - `ZI_TCODE_USAGE_R`: Root interface view (CDS) projecting directly from the database table
   - `ZC_TCODE_USAGE`: Consumption view with UI annotations and Fiori metadata
   - RAP entity (contract: transactional_query) enabling full service exposure

4. **Fiori Elements UI**: Generated List Report that will replace the legacy ALV report.

## Project Status & Next Steps

**Completed:**
- Data loader class (`zcl_tcode_usage_loader`) with filtering and aggregation logic
- Custom persistence table (`zdt_tcode_usage`)
- CDS interface and consumption views with Fiori annotations
- Test/validation report (`ZTEST_TCODE_USAGE_PERSIST`)

**Pending:**
- Comprehensive testing of data-fetch path (activate class, run test report, verify data correctness)
- RAP entity activation and Fiori List Report generation
- Replace launchpad entry to point to new Fiori app instead of legacy ALV

## Key Files & Their Purposes

| File | Purpose |
|------|---------|
| `zcl_tcode_usage_loader.abap` | Fetches aggregated usage from SWNC collector; filters Z-transactions; returns result table |
| `ZTEST_TCODE_USAGE_PERSIST.abap` | Test report that loads data via the class, enriches with program names, persists to table |
| `ZI_TCODE_USAGE_R.acds` | Root CDS interface view; direct projection from zdt_tcode_usage table |
| `ZC_TCODE_USAGE_UI.acds` | Consumption view with full Fiori annotations (@UI, @Search, @Metadata) for List Report |
| `ZSIC_TCODE_USAGE.acds` | Service interface CDS (likely for RAP projection) |
| `tcode_usage/readme.md` | Detailed migration plan and current status |

## ABAP Conventions & Notes

- **Type declarations**: Use explicit `DATA` statements for public types/objects; use `DATA(...)` only where the type is assigned inline in the same statement.
- **Table operations**: Prefer set-based operations (SELECT...FOR ALL ENTRIES, bulk INSERT/DELETE) over row-by-row loops where possible.
- **Aggregation**: The loader uses HASHED TABLE with unique keys for efficient aggregation (UPDATE in place rather than append duplicates).
- **Idempotent persistence**: Test report uses DELETE-then-INSERT pattern per period to allow re-runs without duplicates.
- **Audit fields**: All persisted rows carry load_id, created_at, created_by for traceability.

## Common Development Workflows

### Activating/Testing Changes in ADT/VS Code

1. After modifying the loader class, activate it via the ADT editor.
2. Run the test report (`ZTEST_TCODE_USAGE_PERSIST`) to validate the data-fetch and persistence path.
3. Check the database table `zdt_tcode_usage` to verify row counts and correctness.
4. Monitor sys-subrc returns and commit/rollback behavior for error handling.

### CDS/RAP Iteration

- Modify CDS views and annotations in the `.acds` files.
- Activate the views and the RAP entity.
- Use ADT's RAP tooling to preview metadata and generate the Fiori List Report.
- Test List Report search, sort, and filtering against the service.

### Migration Phase Boundaries

The project has clear phase boundaries. **Always work incrementally**: complete one phase, validate it (activate, test, inspect DB), then move to the next phase. Do not skip testing between phases.

## Notes for Future Work

- The legacy ALV report remains the UI entry point until the Fiori app is ready to be switched in the launchpad.
- The class and data model are separate from UI concerns; they can be extended independently for other use cases (e.g., reports, analytics queries).
- Period handling in the persistence layer uses month-start and month-end dates; ensure period calculations remain accurate if the aggregation window changes.
- Load IDs allow tracking which batch/run persisted a set of rows, useful for auditing and re-runs.
