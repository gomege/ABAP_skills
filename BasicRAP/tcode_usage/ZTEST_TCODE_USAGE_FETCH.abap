*&---------------------------------------------------------------------*
*& Report ZTEST_TCODE_USAGE_FETCH
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ztest_tcode_usage_fetch.

DATA lo_loader    TYPE REF TO zcl_tcode_usage_loader.
DATA lt_result    TYPE zcl_tcode_usage_loader=>tt_tcode_count.
DATA lv_startdate TYPE swncdatum.

CONCATENATE sy-datum(6) '01' INTO lv_startdate.

START-OF-SELECTION.
  lo_loader = NEW #( ).
  lo_loader = NEW #( ).

  lo_loader->load( EXPORTING iv_date_from = lv_startdate
                   IMPORTING et_result    = lt_result ).

  IF lt_result IS INITIAL.
    WRITE / 'No Z transaction usage data found'.
    WRITE / 'No Z transaction usage data found'.
    RETURN.
  ENDIF.

  WRITE / 'Fetched Z transaction usage data:'.
  WRITE / 'Fetched Z transaction usage data:'.
  ULINE.

  LOOP AT lt_result INTO DATA(ls_result).
    WRITE: / ls_result-tcode, ls_result-cnt.
  ENDLOOP.

  
