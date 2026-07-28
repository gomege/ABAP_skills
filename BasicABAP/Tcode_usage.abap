*&---------------------------------------------------------------------*
*& Report ZRR_TCODE_USAGE_RANK
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zrr_tcode_usage_rank.

" ---------------------------------------------------------------
" Types
" ---------------------------------------------------------------
TYPES: BEGIN OF ty_output,
         tcode   TYPE tcode,      " Transaction code
         pgmna   TYPE program_id, " Associated program
         count   TYPE i,          " Number of executions
         has_alv TYPE abap_bool,  " Flag: uses ALV?
       END OF ty_output.

" ---------------------------------------------------------------
" Data
" ---------------------------------------------------------------
DATA lt_output    TYPE STANDARD TABLE OF ty_output.
DATA ls_output    TYPE ty_output.
DATA lt_usertcode TYPE STANDARD TABLE OF swncaggusertcode.  " Workload aggregates
DATA ls_usertcode LIKE LINE OF lt_usertcode.
DATA lt_tstc      TYPE STANDARD TABLE OF tstc.
DATA ls_tstc      TYPE tstc.
*      lv_sysid     TYPE swncsysid,
*      lv_periodstrt TYPE swncdatum,
DATA lv_startdate TYPE swncdatum.
DATA lv_enddate   TYPE d.

" ---------------------------------------------------------------
" Selection screen
" ---------------------------------------------------------------
PARAMETERS p_days TYPE i DEFAULT 30.  " Look back N days

" ---------------------------------------------------------------
" Main logic
" ---------------------------------------------------------------
START-OF-SELECTION.
  " 1. Calculate date range
  lv_enddate = sy-datum.
  CONCATENATE sy-datum(6) '01' INTO lv_startdate.  " First day of current month
*  lv_startdate = sy-datum - p_days.
*  lv_sysid      = sy-sysid.
*  lv_periodstrt = lv_startdate.

  " 2. Read workload statistics from the collector
  "    This FM reads aggregated statistical data per server
  CALL FUNCTION 'SWNC_COLLECTOR_GET_AGGREGATES'
    EXPORTING  component     = 'TOTAL'        " All app servers
*               assigndsys    = lv_sysid
               periodtype    = 'M'            " Daily
               periodstrt    = lv_startdate
    TABLES     usertcode     = lt_usertcode   " Transaction usage data
    EXCEPTIONS no_data_found = 1
               OTHERS        = 2.

  IF sy-subrc <> 0.
    WRITE / 'No workload data found for the selected period.'.
    RETURN.
  ENDIF.

  " 3. Get all Z-transactions and their programs from TSTC
  SELECT tcode pgmna FROM tstc
    INTO TABLE lt_tstc
    WHERE tcode LIKE 'Z%'.

  " 4. Aggregate usage counts per Z-transaction
  LOOP AT lt_usertcode INTO ls_usertcode
       WHERE     entry_id CP 'Z*'
             AND tasktype  = '01'.

    READ TABLE lt_output INTO ls_output
         WITH KEY tcode = ls_usertcode-entry_id.

    IF sy-subrc = 0.
      " Add to existing count
      ls_output-count += ls_usertcode-count.
      MODIFY lt_output FROM ls_output INDEX sy-tabix.
    ELSE.
      " New entry
      CLEAR ls_output.
      ls_output-tcode = ls_usertcode-entry_id.
      ls_output-count = ls_usertcode-count.

      " Look up the program from TSTC
      READ TABLE lt_tstc INTO ls_tstc
           WITH KEY tcode = ls_output-tcode.
      IF sy-subrc = 0.
        ls_output-pgmna = ls_tstc-pgmna.
      ENDIF.

      APPEND ls_output TO lt_output.
    ENDIF.
  ENDLOOP.

  " 5. Sort by usage count descending (= ranking)
  SORT lt_output BY count DESCENDING.

  " 6. Display in ALV using CL_SALV_TABLE
  DATA lo_alv     TYPE REF TO cl_salv_table.
  DATA lo_columns TYPE REF TO cl_salv_columns_table.
  DATA lo_column  TYPE REF TO cl_salv_column.
  DATA lo_sorts   TYPE REF TO cl_salv_sorts.
  DATA lo_funcs   TYPE REF TO cl_salv_functions_list.

  TRY.
      " Create ALV instance from internal table
      cl_salv_table=>factory( IMPORTING r_salv_table = lo_alv
                              CHANGING  t_table      = lt_output ).

      " Enable toolbar functions (export, sort, filter, etc.)
      lo_funcs = lo_alv->get_functions( ).
      lo_funcs->set_all( abap_true ).

      " Set column headers
      lo_columns = lo_alv->get_columns( ).
      lo_columns->set_optimize( abap_true ).  " Auto-width

      lo_column = lo_columns->get_column( 'TCODE' ).
      lo_column->set_short_text( 'TCode' ).

      lo_column = lo_columns->get_column( 'PGMNA' ).
      lo_column->set_short_text( 'Program' ).

      lo_column = lo_columns->get_column( 'COUNT' ).
      lo_column->set_short_text( 'Exec.Count' ).

      lo_column = lo_columns->get_column( 'HAS_ALV' ).
      lo_column->set_short_text( 'Uses ALV?' ).

      " Display the ALV
      lo_alv->display( ).

    CATCH cx_salv_msg
          cx_salv_not_found INTO DATA(lx_err).
      WRITE / lx_err->get_text( ).
  ENDTRY.
