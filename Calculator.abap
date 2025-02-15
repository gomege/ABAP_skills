*&---------------------------------------------------------------------*
*& Report ZPG_MSG_CALCULATOR
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zpg_msc_calculator.

START-OF-SELECTION.

  " Create an object of the zcl_calculator_demo class.
  DATA(lo_calculator) = NEW zcl_calculator_demo( ).

  " Declare a variable to store the result of the calculation, with type int4 (integer).
  DATA lv_result TYPE int4.

  " Define two numbers for the calculations.
  DATA(number_1) = 5.   " Assign 5 to number_1
  DATA(number_2) = 3.   " Assign 3 to number_2

  " Output the values of number_1 and number_2 to the screen.
  WRITE: / |Number 1: { number_1 }, Number 2: { number_2 }|.

  " Perform operations and store the result in lv_result.
  " New syntax
  lv_result = lo_calculator->calculate( iv_operation = '+' iv_number1 = number_1 iv_number2 = number_2 ).

  " New syntax method execution and instance creation combined
  lv_result = NEW zcl_calculator_demo( )->calculate( iv_operation = '+' iv_number1 = number_1 iv_number2 = number_2 ).

  " Same call with old syntax
  CALL METHOD lo_calculator->calculate
    EXPORTING
      iv_operation = '+'
      iv_number1   = number_1
      iv_number2   = number_2
    RECEIVING
      rv_result    = lv_result.

  " Same call but with 'dynamic' method name - dynamic call only possible with old syntax
  DATA lv_method    TYPE string.
  lv_method = 'CALCULATE'.
  CALL METHOD lo_calculator->(lv_method)
    EXPORTING
      iv_operation = '+'
      iv_number1   = number_1
      iv_number2   = number_2
    RECEIVING
      rv_result    = lv_result.


  " Other operations

  lv_result = lo_calculator->calculate( iv_operation = '-' iv_number1 = number_1 iv_number2 = number_2 ).

  lv_result = lo_calculator->calculate( iv_operation = '*' iv_number1 = number_1 iv_number2 = number_2 ).

  lv_result = lo_calculator->calculate( iv_operation = '/' iv_number1 = number_1 iv_number2 = number_2 ).