CLASS zcl_stopwatch DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS:
      start,
      stop,
      get_elapsed_time RETURNING VALUE(rv_elapsed_time) TYPE i.

  PRIVATE SECTION.
    DATA:
      mv_start_time TYPE i,
      mv_stop_time  TYPE i,
      mv_is_running TYPE abap_bool.

ENDCLASS.

CLASS zcl_stopwatch IMPLEMENTATION.

  METHOD start.
    IF mv_is_running = abap_false.
      GET RUN TIME FIELD mv_start_time.
      mv_is_running = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD stop.
    IF mv_is_running = abap_true.
      GET RUN TIME FIELD mv_stop_time.
      mv_is_running = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD get_elapsed_time.
    IF mv_is_running = abap_true.
      GET RUN TIME FIELD DATA(lv_current_time).
      rv_elapsed_time = lv_current_time - mv_start_time.
    ELSE.
      rv_elapsed_time = mv_stop_time - mv_start_time.
    ENDIF.
  ENDMETHOD.

ENDCLASS.