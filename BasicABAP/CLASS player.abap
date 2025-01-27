CLASS player DEFINITION DEFERRED.
    TYPES: ty_player TYPE REF TO player.
    
    CLASS player DEFINITION.
      PUBLIC SECTION.
        METHODS write_player_details.
        METHODS constructor
          IMPORTING
            name    TYPE string
            country TYPE string
            club    TYPE string.
        CLASS-METHODS display_list_of_players.
    
      PRIVATE SECTION.
        DATA: name    TYPE string,
              country TYPE string,
              club    TYPE string.
        CLASS-DATA: players_list TYPE STANDARD TABLE OF ty_player.
    ENDCLASS.
    
    CLASS player IMPLEMENTATION.
      METHOD write_player_details.
        SKIP.
        WRITE: / 'Name :', me->name.
        WRITE: / 'Country :', me->country.
        WRITE: / 'Club :', me->club.
      ENDMETHOD.
    
      METHOD constructor.
        me->name = name.
        me->country = country.
        me->club = club.
        APPEND me TO players_list.
      ENDMETHOD.
    
      METHOD display_list_of_players.
        DATA: temp_player TYPE REF TO player.
        WRITE: / '------------PLAYERS LIST------------'.
        LOOP AT players_list INTO temp_player.
          temp_player->write_player_details( ).
        ENDLOOP.
        WRITE: / '------------------------------------'.
      ENDMETHOD.
    ENDCLASS.
    
    START-OF-SELECTION.