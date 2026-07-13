*&---------------------------------------------------------------------*
*& 
*&---------------------------------------------------------------------*
*& Report z_hello_world +  ZSCH_03_INZWEISTUNDENISTES
*&---------------------------------------------------------------------*

REPORT z_hello_world.

START-OF-SELECTION.
  WRITE 'Hello, World! (wihtout OO-ABAP)'.
* in a new line the current time will be displayed
  WRITE: / | Jetzt ist es: { sy-uzeit TIME = USER }|.
* the time in two hours will be calculated and displayed
  DATA(gd_inzweistunden) = CONV t( sy-uzeit + 7200 ).
* und in zwei Stunden
  WRITE: / | Und in zwei Stunden ist es: { gd_inzweistunden TIME = USER }|.