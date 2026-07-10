*&---------------------------------------------------------------------*
*& Report ZSCH_03_DURCHBLICK
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zsch_03_durchblick.

PARAMETERS: p_werks TYPE werks_d OBLIGATORY,
            p_matnr TYPE matnr OBLIGATORY.

START-OF-SELECTION.

DATA: lv_maktx TYPE maktg.

  SELECT SINGLE maktg FROM makt INTO lv_maktx
    WHERE matnr = p_matnr
      AND spras = sy-langu.

  IF sy-subrc = 0.
    WRITE: / 'Plant:', p_werks,
           / 'Material Number:', p_matnr,
           / 'Material Description:', lv_maktx.
  ELSE.
    WRITE: / 'Material not found for Material Number:', p_matnr.
  ENDIF.