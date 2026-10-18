REPORT zpg_msc_calculator.

START-OF-SELECTION.
  DATA(lo_calculator) = NEW zcl_calculator_demo( ).
  DATA lv_result TYPE int4.

  " Allow user input for numbers
  PARAMETERS: p_num1 TYPE int4 DEFAULT 5,
              p_num2 TYPE int4 DEFAULT 3.

  WRITE: / |Number 1: { p_num1 }, Number 2: { p_num2 }|.

  " Perform operations and display results
  DEFINE perform_and_display.
    TRY.
      lv_result = lo_calculator->calculate( 
        iv_operation = &1 
        iv_number1 = p_num1
        iv_number2 = p_num2 ).
      WRITE: / |&1: { lv_result }|.
    CATCH cx_sy_zerodivide.
      WRITE: / |Error: Division by zero!|.
    ENDTRY.
  END-OF-DEFINITION.

  perform_and_display '+'.
  perform_and_display '-'.
  perform_and_display '*'.
  perform_and_display '/'.

  " Demonstration of old syntax (if needed for compatibility)
  CALL METHOD lo_calculator->calculate
    EXPORTING
      iv_operation = '+'
      iv_number1   = p_num1
      iv_number2   = p_num2
    RECEIVING
      rv_result    = lv_result.
  WRITE: / |Old syntax result: { lv_result }|.

  " Demonstration of dynamic method call (if needed)
  DATA lv_method TYPE string VALUE 'CALCULATE'.
  CALL METHOD lo_calculator->(lv_method)
    EXPORTING
      iv_operation = '+'
      iv_number1   = p_num1
      iv_number2   = p_num2
    RECEIVING
      rv_result    = lv_result.
  WRITE: / |Dynamic call result: { lv_result }|.