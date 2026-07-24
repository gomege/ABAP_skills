*&---------------------------------------------------------------------*
*& Report ZTEST_TCODE_USAGE_PERSIST
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ztest_tcode_usage_persist.

TYPES: BEGIN OF ty_tcode_program,
         tcode TYPE tstc-tcode,
         pgmna TYPE tstc-pgmna,
       END OF ty_tcode_program.
TYPES ty_program_table TYPE HASHED TABLE OF ty_tcode_program WITH UNIQUE KEY tcode.

" Explicit declarations use plain DATA (NOT DATA(...))
DATA lo_loader     TYPE REF TO zcl_tcode_usage_loader.
DATA lt_result     TYPE zcl_tcode_usage_loader=>tt_tcode_count.
DATA lv_period     TYPE d.
DATA lv_period_end TYPE d.
DATA lv_load_id    TYPE zdt_tcode_usage-load_id.
DATA lv_created_at TYPE timestampl.
DATA lt_db         TYPE STANDARD TABLE OF zdt_tcode_usage.
DATA ls_db         TYPE zdt_tcode_usage.

" period = first day of current month
lv_period = |{ sy-datum(6) }01|.

" period_end = last day of month = first day of next month - 1 (pure arithmetic)
DATA(lv_year)  = CONV i( lv_period(4) ).
DATA(lv_month) = CONV i( lv_period+4(2) ).
lv_month += 1.
IF lv_month > 12.
  lv_month = 1.
  lv_year  += 1.
ENDIF.
DATA(lv_first_next) = CONV d( |{ lv_year }{ lv_month WIDTH = 2 PAD = '0' }01| ).
lv_period_end = lv_first_next - 1.          " type-d arithmetic = previous day

" run id (fits LOAD_ID)
lv_load_id = |JOB{ sy-datum }|.

START-OF-SELECTION.
  lo_loader = NEW #( ).

  lo_loader->load( EXPORTING iv_date_from = lv_period
                   IMPORTING et_result    = lt_result ).

  IF lt_result IS INITIAL.
    WRITE / 'No Z transaction usage data found'.
    RETURN.
  ENDIF.

  " prefetch program names in one set-based read, driven directly off lt_result
  SELECT tcode, pgmna FROM tstc
    FOR ALL ENTRIES IN @lt_result
    WHERE tcode = @lt_result-tcode
    INTO TABLE @DATA(lt_tcode_programs).       " here DATA(...) is legal: it's assigned

  DATA(lt_programs) = VALUE ty_program_table( FOR ls_tp IN lt_tcode_programs
                                              ( ls_tp ) ).

  GET TIME STAMP FIELD lv_created_at.

  CLEAR lt_db.
  LOOP AT lt_result INTO DATA(ls_result).
    CLEAR ls_db.
    ls_db-period_start = lv_period.
    ls_db-period_end   = lv_period_end.
    ls_db-tcode        = ls_result-tcode.
    ls_db-abap_program = VALUE #( lt_programs[ tcode = ls_result-tcode ]-pgmna OPTIONAL ).
    ls_db-exec_count   = ls_result-cnt.
    ls_db-load_id      = lv_load_id.
    ls_db-created_at   = lv_created_at.
    ls_db-created_by   = sy-uname.
    APPEND ls_db TO lt_db.
  ENDLOOP.

  " idempotent replace for this period (client handled automatically)
  DELETE FROM zdt_tcode_usage WHERE period_start = @lv_period.
  IF sy-subrc <> 0 AND sy-subrc <> 4.
    ROLLBACK WORK.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    RETURN.
  ENDIF.

  IF lt_db IS NOT INITIAL.
    INSERT zdt_tcode_usage FROM TABLE @lt_db.
    IF sy-subrc <> 0.
      ROLLBACK WORK.
      MESSAGE 'Failed to insert usage data' TYPE 'E'.
      RETURN.
    ENDIF.
  ENDIF.

  COMMIT WORK AND WAIT.

  WRITE / |Wrote { lines( lt_db ) } rows for period { lv_period } (load { lv_load_id }).|.
