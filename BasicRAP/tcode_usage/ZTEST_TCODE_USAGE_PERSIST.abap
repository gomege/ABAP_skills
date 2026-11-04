REPORT ztest_tcode_usage_persist.

TYPES: BEGIN OF ty_tcode_program,
         tcode TYPE tstc-tcode,
         pgmna TYPE tstc-pgmna,
       END OF ty_tcode_program.
TYPES ty_program_table TYPE HASHED TABLE OF ty_tcode_program WITH UNIQUE KEY tcode.
TYPES tt_usage TYPE STANDARD TABLE OF zdt_tcode_usage WITH EMPTY KEY.

PARAMETERS: p_perbeg TYPE d OBLIGATORY,
            p_force  AS CHECKBOX.

INITIALIZATION.
  p_perbeg = |{ sy-datum(6) }01|.

START-OF-SELECTION.

  DATA(lv_period) = CONV d( |{ p_perbeg+0(6) }01| ).

  DATA(lv_year)  = CONV i( lv_period(4) ).
  DATA(lv_month) = CONV i( lv_period+4(2) ).
  lv_month = lv_month + 1.
  IF lv_month > 12.
    lv_month = 1.
    lv_year  = lv_year + 1.
  ENDIF.
  DATA(lv_first_next) = CONV d( |{ lv_year }{ lv_month WIDTH = 2 PAD = '0' }01| ).
  DATA(lv_month_end)  = lv_first_next - 1.

  DATA(lv_complete) = xsdbool( lv_month_end < sy-datum ).

  IF lv_complete = abap_false AND p_force = abap_false.
    MESSAGE text-001 TYPE 'I'.
    RETURN.
  ENDIF.

  DATA(lv_period_end) = COND d( WHEN lv_complete = abap_true THEN lv_month_end
                                ELSE sy-datum - 1 ).

  IF lv_period_end < lv_period.
    MESSAGE text-002 TYPE 'I'.
    RETURN.
  ENDIF.

  DATA lv_run_ts TYPE timestamp.
  GET TIME STAMP FIELD lv_run_ts.
  DATA(lv_load_id) = CONV zdt_tcode_usage-load_id( |{ lv_run_ts }| ).

  DATA lt_result TYPE zcl_tcode_usage_loader=>tt_tcode_count.
  TRY.
      DATA(lo_loader) = NEW zcl_tcode_usage_loader( ).
      lo_loader->load( EXPORTING iv_date_from = lv_period
                       IMPORTING et_result    = lt_result ).
    CATCH cx_root INTO DATA(lx_load).
      MESSAGE lx_load->get_text( ) TYPE 'E'.
      RETURN.
  ENDTRY.

  IF lt_result IS INITIAL.
    MESSAGE text-003 TYPE 'I'.
    RETURN.
  ENDIF.

  SELECT tcode, pgmna
    FROM tstc
    FOR ALL ENTRIES IN @lt_result
    WHERE tcode = @lt_result-tcode
    INTO TABLE @DATA(lt_tcode_programs).

  DATA(lt_programs) = VALUE ty_program_table(
    FOR ls_tp IN lt_tcode_programs ( ls_tp ) ).

  DATA lv_created_at TYPE timestampl.
  GET TIME STAMP FIELD lv_created_at.

  DATA(lt_db) = VALUE tt_usage(
    FOR ls_r IN lt_result
    ( period_start = lv_period
      period_end   = lv_period_end
      tcode        = ls_r-tcode
      abap_program = VALUE #( lt_programs[ tcode = ls_r-tcode ]-pgmna OPTIONAL )
      exec_count   = ls_r-cnt
      load_id      = lv_load_id
      created_at   = lv_created_at
      created_by   = sy-uname ) ).

  DELETE FROM zdt_tcode_usage WHERE period_start = @lv_period.
  IF sy-subrc <> 0 AND sy-subrc <> 4.
    ROLLBACK WORK.
    " DELETE does not fill sy-msgid/sy-msgno, so use an own text symbol
    MESSAGE text-007 TYPE 'E'.
    RETURN.
  ENDIF.

  INSERT zdt_tcode_usage FROM TABLE @lt_db.
  IF sy-subrc <> 0.
    ROLLBACK WORK.
    MESSAGE text-004 TYPE 'E'.
    RETURN.
  ENDIF.

  COMMIT WORK AND WAIT.

  WRITE: / text-005, lines( lt_db ), text-006, lv_period, '-', lv_period_end,
         'load', lv_load_id.
