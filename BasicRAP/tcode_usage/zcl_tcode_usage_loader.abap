*&---------------------------------------------------------------------*
*& Class zcl_tcode_usage_loader
*&---------------------------------------------------------------------*
*& this class is responsible for:
*& calling SWNC_COLLECTOR_GET_AGGREGATES
*& reading TSTC
*& filtering Z-transactions
*& aggregating the counts
*& returning a result table
*&---------------------------------------------------------------------*
class zcl_tcode_usage_loader DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_tcode_count,
        tcode TYPE tstc-tcode,    " transaction code
        cnt   TYPE i,
      END OF ty_tcode_count,
      tt_tcode_count TYPE STANDARD TABLE OF ty_tcode_count WITH NON-UNIQUE KEY tcode.
        
* ---------------------------------------------------------------
* this method will load the transaction usage data from the workload collector and return a table of Z-transactions with their usage counts
* ---------------------------------------------------------------
    METHODS load
      IMPORTING
        iv_date_from TYPE datum OPTIONAL
        iv_date_to   TYPE datum OPTIONAL
      EXPORTING
        et_result    TYPE tt_tcode_count
      RAISING
        cx_root. " pick a suitable exception class

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

* ---------------------------------------------------------------
* implementation of the class
* ---------------------------------------------------------------
CLASS zcl_tcode_usage_loader IMPLEMENTATION.

METHOD load.
    DATA: lt_usertcode TYPE STANDARD TABLE OF swncaggusertcode,
          ls_usertcode LIKE LINE OF lt_usertcode,
          lt_counts    TYPE HASHED TABLE OF ty_tcode_count WITH UNIQUE KEY tcode,
          ls_count     TYPE ty_tcode_count.

    " 1. Get collector aggregates
    CALL FUNCTION 'SWNC_COLLECTOR_GET_AGGREGATES'
      EXPORTING
        component  = 'TOTAL'
        periodtype = 'M'
        periodstrt = iv_date_from
      TABLES
        usertcode  = lt_usertcode
      EXCEPTIONS
        no_data_found = 1
        OTHERS        = 2.

    IF sy-subrc <> 0.
      CLEAR et_result.
      RETURN.
    ENDIF.

    " 2. Aggregate only Z-transactions
    LOOP AT lt_usertcode INTO ls_usertcode
      WHERE entry_id CP 'Z*'
        AND tasktype = '01'.

      READ TABLE lt_counts INTO ls_count
        WITH TABLE KEY tcode = ls_usertcode-entry_id.

      IF sy-subrc = 0.
        ls_count-cnt = ls_count-cnt + ls_usertcode-count.
        MODIFY TABLE lt_counts FROM ls_count.
      ELSE.
        ls_count-tcode = ls_usertcode-entry_id.
        ls_count-cnt   = ls_usertcode-count.
        INSERT ls_count INTO TABLE lt_counts.
      ENDIF.
    ENDLOOP.

    " 3. Return standard table
    et_result = VALUE tt_tcode_count(
      FOR ls_count_row IN lt_counts
      ( tcode = ls_count_row-tcode
        cnt   = ls_count_row-cnt ) ).
  ENDMETHOD.

ENDCLASS.