# TCODE_USAGE Fiori Migration Plan

This folder contains the first backend-oriented migration work for the existing SAP GUI ALV report based on the transaction usage collector data.

## Current status

Completed:
1. Keep the logic that reads `SWNC_COLLECTOR_GET_AGGREGATES`
2. Move that logic into an ABAP class

The current class is:

- `zcl_tcode_usage_loader`

It is responsible for:
- calling `SWNC_COLLECTOR_GET_AGGREGATES`
- reading the collected workload data
- filtering `Z*` transaction codes
- aggregating usage counts
- returning a result table

The class is now being tested and debugged to confirm that the data-fetch path works correctly before moving to the Fiori layer.

## Next open steps

The following migration steps are still pending:

3. Store the aggregated result in a custom table or another CDS-accessible source
4. Build a CDS/RAP entity on top of that data
5. Add Fiori annotations to the CDS/RAP entity
6. Generate the Fiori Elements List Report
7. Replace the Launchpad entry from the ALV report to the Fiori app

## Notes for the current implementation

- The old ALV report is still the UI entry point.
- The class is now the reusable backend data loader.
- The UI layer should not be the source of truth for the Fiori migration.
- For the next stage, the runtime result must become a stable backend service model.

## Important reminder

Before moving to CDS/RAP, the class should be validated in ADT/VS Code by:
- activating the class
- creating a simple test report
- executing it
- verifying that the returned transaction codes and counts are correct

## Suggested next prompt for continuing in another VS Code session

Use this prompt in the next VS Code session:

"Continue the migration for the `tcode_usage` project. Step 3 is next: create a custom table to persist the aggregated usage result from `zcl_tcode_usage_loader`. Then create a CDS view or RAP entity on top of that data, add Fiori annotations, and prepare the List Report generation. Keep the work incremental and explain each ABAP object and its purpose as we go."

## Goal

The final target is to replace the SAP GUI ALV report with a Fiori Elements List Report app, using a backend service model instead of an internal table displayed directly from a report.