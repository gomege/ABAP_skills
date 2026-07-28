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
CLASS zcl_tcode_usage_loader DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_tcode_count,
        tcode TYPE tstc-tcode, " transaction code
        cnt   TYPE i,
      END OF ty_tcode_count,
      tt_tcode_count TYPE STANDARD TABLE OF ty_tcode_count WITH NON-UNIQUE KEY tcode.

    " ---------------------------------------------------------------
    " this method will load the transaction usage data from the workload collector and return a table of Z-transactions with their usage counts
    " ---------------------------------------------------------------
    METHODS load
      IMPORTING iv_date_from TYPE datum OPTIONAL
      EXPORTING et_result    TYPE tt_tcode_count
      RAISING   cx_root.
ENDCLASS.


" ---------------------------------------------------------------
" implementation of the class
" ---------------------------------------------------------------
CLASS zcl_tcode_usage_loader IMPLEMENTATION.
* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_TCODE_USAGE_LOADER->LOAD
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_DATE_FROM                   TYPE        DATUM(optional)
* | [--->] IV_DATE_TO                     TYPE        DATUM(optional)
* | [<---] ET_RESULT                      TYPE        TT_TCODE_COUNT
* | [!CX!] CX_ROOT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD load.
    DATA lt_usertcode TYPE STANDARD TABLE OF swncaggusertcode.
    FIELD-SYMBOLS <ls_usertcode> TYPE swncaggusertcode.
    DATA lt_counts TYPE HASHED TABLE OF ty_tcode_count WITH UNIQUE KEY tcode.
    FIELD-SYMBOLS <ls_count> TYPE ty_tcode_count.

    " 1. Get collector aggregates
    CALL FUNCTION 'SWNC_COLLECTOR_GET_AGGREGATES'
      EXPORTING  component     = 'TOTAL'
                 periodtype    = 'M'
                 periodstrt    = iv_date_from
      TABLES     usertcode     = lt_usertcode
      EXCEPTIONS no_data_found = 1
                 OTHERS        = 2.

    IF sy-subrc <> 0.
      et_result = VALUE tt_tcode_count( ).
      RETURN.
    ENDIF.

    " 2. Aggregate only Z-transactions
    LOOP AT lt_usertcode ASSIGNING <ls_usertcode>
         WHERE     entry_id CP 'Z*'
               AND tasktype  = '01'.

      ASSIGN lt_counts[ tcode = <ls_usertcode>-entry_id ] TO <ls_count>.

      IF sy-subrc = 0.
        <ls_count>-cnt += <ls_usertcode>-count.
      ELSE.
        INSERT VALUE ty_tcode_count( tcode = <ls_usertcode>-entry_id
                                     cnt   = <ls_usertcode>-count )
               INTO TABLE lt_counts.
      ENDIF.
    ENDLOOP.

    " 3. Return standard table
    et_result = lt_counts.
  ENDMETHOD.
ENDCLASS.
