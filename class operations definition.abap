CLASS operations DEFINITION.
  PUBLIC SECTION.
    METHODS:
      add
        IMPORTING
          value1 TYPE i VALUE 3
          value2 TYPE i VALUE 9
        RETURNING
          VALUE(result) TYPE p decimals 2,

      subtract
        IMPORTING
          value1 TYPE i VALUE 87
          value2 TYPE i VALUE 24
        RETURNING
          VALUE(result) TYPE p decimals 2,

      multiply
        IMPORTING
          value1 TYPE i VALUE 92
          value2 TYPE i VALUE 100
        RETURNING
          VALUE(result) TYPE p decimals 2,

      divide
        IMPORTING
          value1 TYPE i VALUE 90
          value2 TYPE i VALUE 9
        RETURNING
          VALUE(result) TYPE p decimals 2,

    private section.
      DATA:
        result TYPE p DECIMALS 2.

ENDCLASS.

CLASS operations IMPLEMENTATION.
  METHOD add.
    result = value1 + value2.
    skip.
    write: / 'The sum of', value1, 'and', value2, 'is', result.
  ENDMETHOD.

  METHOD subtract.
    result = value1 - value2.
    skip.
    write: / 'The difference between', value1, 'and', value2, 'is', result.
  ENDMETHOD.

  METHOD multiply.
    result = value1 * value2.
    skip.
    write: / 'The product of', value1, 'and', value2, 'is', result.
  ENDMETHOD.

  METHOD divide.
    result = value1 / value2.
    skip.
    write: / 'The quotient of', value1, 'and', value2, 'is', result.
  ENDMETHOD.
ENDCLASS.
