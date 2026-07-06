REPORT ztemp_ib_header_alv.

DATA ld_lines TYPE i VALUE 200.

TYPES: BEGIN OF ty_result,
         ib_number         TYPE zdt_ib_header-ib_number,
         ekorg             TYPE zdt_ib_header-ekorg,
         vkorg             TYPE zdt_ib_header-vkorg,
         process_type      TYPE zdt_ib_header-process_type,
         date_doc          TYPE zdt_ib_header-date_doc,
         user_doc          TYPE zdt_ib_header-user_doc,
         ym_number         TYPE zdt_ib_header-ym_number,
         driver_name_first TYPE zdt_ib_header-driver_name_first,
         driver_name_last  TYPE zdt_ib_header-driver_name_last,
         driver_phone      TYPE zdt_ib_header-driver_phone,
         driver_name       TYPE zdt_ib_header-driver_name,
         people_number     TYPE zdt_ib_header-people_number,
         vendor            TYPE zdt_ib_header-vendor,
         kunnr             TYPE zdt_ib_header-kunnr,
         spedytor          TYPE zdt_ib_header-spedytor,
         ib_number_ref_hdr TYPE zdt_ib_header-ib_number_ref_hdr,
       END OF ty_result.

DATA: lt_result TYPE STANDARD TABLE OF ty_result,
      lo_alv    TYPE REF TO cl_salv_table,
      lo_funcs  TYPE REF TO cl_salv_functions_list,
      lo_cols   TYPE REF TO cl_salv_columns_table,
      lx_salv   TYPE REF TO cx_salv_msg.

START-OF-SELECTION.

    SELECT ib_number, ekorg, vkorg, process_type, date_doc, user_doc,
         ym_number, driver_name_first, driver_name_last, driver_phone,
         driver_name, people_number, vendor, kunnr, spedytor, ib_number_ref_hdr
    FROM zdt_ib_header
    WHERE date_reg >= '20210101'
      AND spedytor   = '0001021176'
 AND spedytor = zdt_ib_header~vendor
    ORDER BY date_doc DESCENDING
    INTO TABLE @lt_result
    UP TO @ld_lines ROWS.

  IF lt_result IS INITIAL.
    MESSAGE 'No results found' TYPE 'I'.
    RETURN.
  ENDIF.

  SORT lt_result BY date_doc DESCENDING ib_number DESCENDING.

  TRY.
      cl_salv_table=>factory(
        IMPORTING
          r_salv_table = lo_alv
        CHANGING
          t_table      = lt_result ).

      lo_funcs = lo_alv->get_functions( ).
      lo_funcs->set_all( abap_true ).

      lo_cols = lo_alv->get_columns( ).
      lo_cols->set_optimize( abap_true ).

      lo_alv->display( ).

    CATCH cx_salv_msg INTO lx_salv.
      MESSAGE lx_salv->get_text( ) TYPE 'I'.
  ENDTRY.