CLASS operations DEFINITION.
    PUBLIC SECTION.
        METHODS:
            "! Adds two decimal numbers and displays the result
            "! @parameter value1 | First number to be added
            "! @parameter value2 | Second number to be added
            "! @returning result | The sum of value1 and value2
            add
                IMPORTING
                    value1 TYPE p DECIMALS 2
                    value2 TYPE p DECIMALS 2
                RETURNING
                    VALUE(result) TYPE p DECIMALS 2,

            "! Subtracts one decimal number from another and displays the result
            "! @parameter value1 | Number to be subtracted from
            "! @parameter value2 | Number to subtract
            "! @returning result | The difference between value1 and value2
            subtract
                IMPORTING
                    value1 TYPE p DECIMALS 2
                    value2 TYPE p DECIMALS 2
                RETURNING
                    VALUE(result) TYPE p DECIMALS 2,

            "! Multiplies two decimal numbers and displays the result
            "! @parameter value1 | First number to be multiplied
            "! @parameter value2 | Second number to be multiplied
            "! @returning result | The product of value1 and value2
            multiply
                IMPORTING
                    value1 TYPE p DECIMALS 2
                    value2 TYPE p DECIMALS 2
                RETURNING
                    VALUE(result) TYPE p DECIMALS 2,

            "! Divides one decimal number by another and displays the result
            "! @parameter value1 | Number to be divided
            "! @parameter value2 | Number to divide by
            "! @returning result | The quotient of value1 divided by value2
            divide
                IMPORTING
                    value1 TYPE p DECIMALS 2
                    value2 TYPE p DECIMALS 2
                RETURNING
                    VALUE(result) TYPE p DECIMALS 2,

            "! Displays the result of an arithmetic operation
            "! @parameter operation | Name of the arithmetic operation performed
            "! @parameter value1 | First operand of the operation
            "! @parameter value2 | Second operand of the operation
            "! @parameter result | Result of the operation
            display_result
                IMPORTING
                    operation TYPE string
                    value1 TYPE p DECIMALS 2
                    value2 TYPE p DECIMALS 2
                    result TYPE p DECIMALS 2.

        PRIVATE SECTION.
            DATA:
                result TYPE p DECIMALS 2.

ENDCLASS.

CLASS operations IMPLEMENTATION.
    METHOD add.
        result = value1 + value2.
        display_result( 'sum' value1 value2 result ).
    ENDMETHOD.

    METHOD subtract.
        result = value1 - value2.
        display_result( 'difference' value1 value2 result ).
    ENDMETHOD.

    METHOD multiply.
        result = value1 * value2.
        display_result( 'product' value1 value2 result ).
    ENDMETHOD.

    METHOD divide.
        IF value2 <> 0.
            result = value1 / value2.
            display_result( 'quotient' value1 value2 result ).
        ELSE.
        result = 0.
    ENDMETHOD.

    METHOD display_result.
        WRITE: / 'The', operation, 'of', value1, 'and', value2, 'is', result.
    ENDMETHOD.
ENDCLASS.
