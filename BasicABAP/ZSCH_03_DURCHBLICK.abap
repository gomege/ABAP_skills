*&---------------------------------------------------------------------*
*& Report ZSCH_03_DURCHBLICK
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZSCH_03_DURCHBLICK.

DATA: lv_werks TYPE werks_d,
      lv_matnr TYPE matnr,
      lv_maktx TYPE maktg.

START-OF-SELECTION.

  " Set the plant and material number
  lv_werks = 'C1M0'. " Example plant
  lv_matnr = '10123867'. " Example material number

  " Fetch the material description from MARA and MAKT tables
  SELECT SINGLE maktg INTO lv_maktx
    FROM makt
    WHERE matnr = lv_matnr
      AND spras = sy-langu.

  IF sy-subrc = 0.
    WRITE: / 'Plant:', lv_werks,
           / 'Material Number:', lv_matnr,
           / 'Material Description:', lv_maktx.
  ELSE.
    WRITE: / 'Material not found for Material Number:', lv_matnr.
  ENDIF.
