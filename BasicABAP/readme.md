# BasicABAP — Reports & Examples

A small collection of beginner ABAP examples and a simple ALV report used for learning ABAP procedural and OO concepts.

## Files

- `helloWelt.abap` — z_hello_world  
	Purpose: Minimal "Hello, World!" demo report to show basic `REPORT` structure.  
	How to run: Execute report `z_hello_world` in SE38/SE80.

- `ZTEMP_IB_HEADER_ALV.abap` — ztemp_ib_header_alv  
	Purpose: Reads selected fields from table `zdt_ib_header`, applies hard-coded filters, and displays results in an ALV using `cl_salv_table`. Used to explore supplier ↔ carrier relationships.  
	Key details: `ld_lines` controls max rows; WHERE clause currently filters on `date_reg >= '20210101'` and a hard-coded `spedytor` value. Results are sorted by `date_doc` and `ib_number`.  
	How to adapt: Add selection-screen parameters or replace hard-coded values to query different periods or BP relationships.

- `CLASS player.abap` — `player` class example  
	Purpose: Simple ABAP Objects example demonstrating a constructor, instance method `write_player_details`, class method `display_list_of_players`, and `CLASS-DATA` table storing instances.  
	Usage: Instantiate with `NEW player( name = 'X' country = 'Y' club = 'Z' )`, then call `player=>display_list_of_players( )`.

## Notes & Suggestions
- `ZTEMP_IB_HEADER_ALV.abap` is the most useful for practical exploration — consider parameterizing the WHERE clause (selection-screen or method parameters) instead of hard-coded values for reuse.  
- Keep small demo files (like `helloWelt.abap`) as teaching references; add short inline comments if you plan to share them with others.

## Changes & History
- README created/updated to document the `BasicABAP` folder (2026-07-06).

----
If you want, I can also:
- generate a patch to add selection-screen parameters to `ZTEMP_IB_HEADER_ALV.abap`, or
- consolidate documentation in the repository root `README.md`.

