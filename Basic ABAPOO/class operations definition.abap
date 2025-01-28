CLASS z_basic_operations DEFINITION PUBLIC.
    PUBLIC SECTION.
        TYPES: dec2 TYPE p LENGTH 8 DECIMALS 2.
        METHODS:
            "! Adds two decimal numbers and formats the result
            "! @parameter value1 | First number to be added
            "! @parameter value2 | Second number to be added
            "! @returning result | Formatted string with the sum of value1 and value2
            add
                IMPORTING
                    value1 TYPE dec2
                    value2 TYPE dec2
                RETURNING
                    VALUE(result) TYPE string,

            "! Subtracts one decimal number from another and formats the result
            "! @parameter value1 | Number to be subtracted from
            "! @parameter value2 | Number to subtract
            "! @returning result | Formatted string with the difference between value1 and value2
            subtract
                IMPORTING
                    value1 TYPE dec2
                    value2 TYPE dec2
                RETURNING
                    VALUE(result) TYPE string,

            "! Multiplies two decimal numbers and formats the result
            "! @parameter value1 | First number to be multiplied
            "! @parameter value2 | Second number to be multiplied
            "! @returning result | Formatted string with the product of value1 and value2
            multiply
                IMPORTING
                    value1 TYPE dec2
                    value2 TYPE dec2
                RETURNING
                    VALUE(result) TYPE string,

            "! Divides one decimal number by another and formats the result
            "! @parameter value1 | Number to be divided
            "! @parameter value2 | Number to divide by
            "! @returning result | Formatted string with the quotient of value1 divided by value2
            divide
                IMPORTING
                    value1 TYPE dec2
                    value2 TYPE dec2
                RETURNING
                    VALUE(result) TYPE string,

            "! Formats the result of an arithmetic operation
            "! @parameter operation | Name of the arithmetic operation performed
            "! @parameter value1 | First operand of the operation
            "! @parameter value2 | Second operand of the operation
            "! @parameter result | Result of the operation
            "! @returning formatted_result | Formatted string with the operation result
            format_result
                IMPORTING
                    operation TYPE string
                    value1    TYPE dec2
                    value2    TYPE dec2
                    result    TYPE dec2
                RETURNING
                    VALUE(formatted_result) TYPE string.

    PRIVATE SECTION.
        DATA: calc_result TYPE dec2.

ENDCLASS.

CLASS z_basic_operations IMPLEMENTATION.
    METHOD add.
        calc_result = value1 + value2.
        result = format_result( operation = 'sum'
                                value1    = value1
                                value2    = value2
                                result    = calc_result ).
    ENDMETHOD.

    METHOD subtract.
        calc_result = value1 - value2.
        result = format_result( operation = 'difference'
                                value1    = value1
                                value2    = value2
                                result    = calc_result ).
    ENDMETHOD.

    METHOD multiply.
        calc_result = value1 * value2.
        result = format_result( operation = 'product'
                                value1    = value1
                                value2    = value2
                                result    = calc_result ).
    ENDMETHOD.

    METHOD divide.
        IF value2 <> 0.
            calc_result = value1 / value2.
            result = format_result( operation = 'quotient'
                                    value1    = value1
                                    value2    = value2
                                    result    = calc_result ).
        ELSE.
            result = 'Error: Division by zero is not allowed.'.
        ENDIF.
    ENDMETHOD.

    METHOD format_result.
        formatted_result = |The { operation } of { value1 } and { value2 } is { result }.|.
    ENDMETHOD.
ENDCLASS.