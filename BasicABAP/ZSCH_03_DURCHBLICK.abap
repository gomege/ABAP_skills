*&---------------------------------------------------------------------*
*& Report ZSCH_03_DURCHBLICK
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zsch_03_durchblick.

DATA: lv_werks TYPE werks_d,
      lv_matnr TYPE matnr,
      lv_maktx TYPE maktg.

START-OF-SELECTION.

  lv_werks = 'C1M0'.
  lv_matnr = '10216750'.

  " Convert to internal format (adds leading zeros)
  CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
    EXPORTING input  = lv_matnr
    IMPORTING output = lv_matnr.

  SELECT SINGLE maktg FROM makt INTO lv_maktx
    WHERE matnr = lv_matnr
      AND spras = sy-langu.

  IF sy-subrc = 0.
    WRITE: / 'Plant:', lv_werks,
           / 'Material Number:', lv_matnr,
           / 'Material Description:', lv_maktx.
  ELSE.
    WRITE: / 'Material not found for Material Number:', lv_matnr.
  ENDIF.
