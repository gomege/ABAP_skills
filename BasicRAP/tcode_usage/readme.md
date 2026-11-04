# TCODE_USAGE – from ALV report to Fiori Elements

A learning exercise: start with a classic SAP GUI ALV report that shows how often Z-transactions are used, and take it step by step to a **Fiori Elements List Report** on a **RAP** backend.

## Current status

The Fiori Elements app based on table `zdt_tcode_usage` is **deployed, published in the Fiori Launchpad and working**.

Done:
1. Read workload data with `SWNC_COLLECTOR_GET_AGGREGATES`
2. Move that logic into the reusable class `zcl_tcode_usage_loader`
3. Persist the aggregated result in table `zdt_tcode_usage` (report `ZTEST_TCODE_USAGE_PERSIST`)
4. Build the CDS views on top of the table, with Fiori annotations
5. Expose the service and generate the Fiori Elements List Report
6. Publish the app in the Fiori Launchpad

## Road ahead

- Keep testing the app and the data load
- Learn and implement **ABAP Unit tests** (e.g. for `zcl_tcode_usage_loader`)
- Learn and implement **access control** (CDS access control / authorisations)
- Then move the app from the sandbox system to a production system
- Since there is no private data from any company, this can be moved to an IDES system to continue learning usage of ABAPGit

## Database table `zdt_tcode_usage`

The table exists only in the SAP system; there is no source file for it in this repo.

| Field | Key | Data element / type | Notes |
|---|---|---|---|
| MANDT | ✓ | MANDT | Client |
| PERIOD_START | ✓ | DATS | First day of the period |
| TCODE | ✓ | TCODE | CHAR 20, same as TSTC-TCODE |
| PERIOD_END | | DATS | Last day of the loaded range |
| ABAP_PROGRAM | | PROGRAMM | CHAR 40, filled from TSTC-PGMNA |
| EXEC_COUNT | | INT4 | Execution count |
| LOAD_ID | | CHAR 20 | Run identifier (time stamp of the load) |
| CREATED_AT | | TIMESTAMPL | Time of the load |
| CREATED_BY | | SYUNAME | User who ran the load |
