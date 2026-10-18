# OData V2 Service for Guardian Objects

## Project Setup
1. **Create a new SEGW project**: 
   - Namespace: `Z`
   - Project Name: `ZGW_GUARDIAN_OBJ`

## Data Model
2. **Define Entity Types**:
   - **GuardianObject** mapped to `/SIVIS/GT_OB`
     - Key: `OBJ_ID`
     - Fields: `OBJ_TYPE_ID`, `SUB_TYPE_ID`, `EXPIRY_DATE`, `BRGRU`
   - **GuardianQuickInfo** mapped to `/SIVIS/GT_OB_QIN`
     - Key: `OBJ_ID`
     - Fields: `S1`, `S2`, `S3`, `S4`, `L1`, `L2`, `L3`, `L4`, `H1`, `H2`

3. **Create Association**:
   - `Object_QuickInfo` between `GuardianObject(OBJ_ID)` and `GuardianQuickInfo(OBJ_ID)` with cardinality `1..1` or `1..0..1`.

4. **Generate Entity Sets**:
   - `GuardianObjects`
   - `GuardianQuickInfos`

## Runtime Classes
5. **Generate Classes**:
   - MPC / MPC_EXT (metadata provider)
   - DPC / DPC_EXT (data provider)

6. **Implement Methods**:
   - `GET_ENTITYSET` and `GET_ENTITY` for `GuardianObjects` with inner join or read + lookup into `/SIVIS/GT_OB_QIN`.
   - Implement navigation property handling to fetch Quick Info for a given `OBJ_ID`.
   - Handle `$filter`, `$select`, `$orderby`, and paging.
   - Map `STRING` fields `H1/H2` carefully for OData V2; provide a safe length-limited proxy if needed.

## Annotations for Smart Controls / Fiori
7. **Provide Annotations**:
   - Local annotation XML or metadata extensions in MPC_EXT.
   - Include: LineItem, Identification, FieldGroup for Quick Info.
   - Assign proper labels and value semantics (e.g., date for `EXPIRY_DATE`).

8. **Confirm Annotation Model**:
   - Load in `/IWFND/MAINT_SERVICE` metadata and ensure consumability by smart controls.

## Service Registration
9. **Activate and Register Service**:
   - Use `/IWFND/MAINT_SERVICE`.
   - Test URLs: `.../sap/opu/odata/sap/ZGW_GUARDIAN_OBJ_SRV/$metadata`, `GuardianObjects`, navigation to QuickInfo.

## Fiori UI (Smart Controls)
10. **Create List Report-like App**:
    - Use SmartTable bound to `GuardianObjects`.
    - Detail binding for Object Page-like view consuming navigation to `GuardianQuickInfo`.

11. **Minimal manifest.json Configuration**:
    - Data source configuration pointing to the SEGW service.
    - Annotation references (local or component-based).

## Authorization & Filtering
12. **Leverage BRGRU for Authorization Filtering**:
    - Implement in DPC_EXT based on user roles.
    - Client handling is implicit; avoid exposing `MANDT`.

## Validation & Performance
13. **Verify**:
    - Key definition, navigation, and `$expand` behavior.
    - Check response payload for types mapping and annotation consumption.
    - Consider selective reads and `$select` to reduce payload.
    - Ensure proper transport and package assignment.
