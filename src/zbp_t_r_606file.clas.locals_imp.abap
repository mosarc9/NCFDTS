CLASS lhc_e606file DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR e606file RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR e606file RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR e606file RESULT result.

    METHODS downloadtxt FOR MODIFY
      IMPORTING keys FOR ACTION e606file~downloadtxt RESULT result.

    METHODS resume FOR MODIFY
      IMPORTING keys FOR ACTION e606file~resume.

    METHODS validatemonth FOR VALIDATE ON SAVE
      IMPORTING keys FOR e606file~validatemonth.

    METHODS validateperiod FOR VALIDATE ON SAVE
      IMPORTING keys FOR e606file~validateperiod.

    METHODS validateyear FOR VALIDATE ON SAVE
      IMPORTING keys FOR e606file~validateyear.

ENDCLASS.

CLASS lhc_e606file IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD downloadtxt.

    READ ENTITIES OF zt_r_606file IN LOCAL MODE
    ENTITY e606file
    ALL FIELDS WITH
    CORRESPONDING #( keys )
    RESULT DATA(entities).

    LOOP AT entities INTO DATA(entity).

      IF entity-gjahr IS INITIAL.
        APPEND VALUE #( %tky = entity-%tky ) TO failed-e606file.

        APPEND VALUE #( %tky       = entity-%tky
                       %state_area = 'VALIDATE_DOWNLOAD'
                       %msg        =  new_message( id       = 'Z_606_MC'
                                                   number   = '017'
                                                   severity = if_abap_behv_message=>severity-error )
                       %element-gjahr = if_abap_behv=>mk-on
                        ) TO reported-e606file.

      ELSEIF entity-monat IS INITIAL.
        APPEND VALUE #( %tky = entity-%tky ) TO failed-e606file.

        APPEND VALUE #( %tky       = entity-%tky
                       %state_area = 'VALIDATE_DOWNLOAD'
                       %msg        =  new_message( id       = 'Z_606_MC'
                                                   number   = '018'
                                                   severity = if_abap_behv_message=>severity-error )
                       %element-monat = if_abap_behv=>mk-on
                        ) TO reported-e606file.
      ELSE.

        DATA(lv_name) = |{ entity-gjahr }| & |{ entity-monat }| & |.txt|.

        SELECT SINGLE FROM zz1_isrtypes_vh
        FIELDS *
        WHERE staging = '01'
        INTO @DATA(line).

        DATA(lv_csv) = |STAGING,DESCRIPTION{ cl_abap_char_utilities=>newline }|.
        lv_csv &&= |{ line-staging },{ line-description }{ cl_abap_char_utilities=>newline }|.

        DATA(lv_xstr) = xco_cp=>string( lv_csv
              )->as_xstring( xco_cp_character=>code_page->utf_8
              )->value.

        MODIFY ENTITIES OF zt_r_606file IN LOCAL MODE
           ENTITY e606file
           UPDATE
           FIELDS ( attachment mimetype filename )
           WITH VALUE #( FOR key IN keys ( %tky       = key-%tky
                                           attachment = lv_xstr
                                           filename   = lv_name
                                           mimetype   = 'application/text' ) ).

        READ ENTITIES OF zt_r_606file IN LOCAL MODE
         ENTITY e606file
         ALL FIELDS
         WITH CORRESPONDING #( keys )
         RESULT DATA(response).

        result = VALUE #( FOR lines IN response ( %tky   = lines-%tky
                                                  %param = lines ) ).

      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD resume.
  ENDMETHOD.

  METHOD validatemonth.

    READ ENTITIES OF zt_r_606file IN LOCAL MODE
    ENTITY e606file
    FIELDS ( monat )
    WITH CORRESPONDING #( keys )
    RESULT DATA(entities).

    LOOP AT entities INTO DATA(entity).

      IF entity-monat IS INITIAL.

        APPEND VALUE #( %tky = entity-%tky ) TO failed-e606file.

        APPEND VALUE #( %tky       = entity-%tky
                       %state_area = 'VALIDATE_MONTH'
                       %msg        =  new_message( id       = 'Z_606_MC'
                                                   number   = '018'
                                                   severity = if_abap_behv_message=>severity-error )
                       %element-monat = if_abap_behv=>mk-on
                        ) TO reported-e606file.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateperiod.

    DATA periodos TYPE SORTED TABLE OF z606file WITH UNIQUE KEY client uuid gjahr monat.

    READ ENTITIES OF zt_r_606file IN LOCAL MODE
    ENTITY e606file
    FIELDS ( gjahr monat )
    WITH CORRESPONDING #( keys )
    RESULT DATA(entities).

    periodos = CORRESPONDING #( entities DISCARDING DUPLICATES MAPPING gjahr = gjahr monat = monat EXCEPT * ).
    DELETE periodos WHERE gjahr IS INITIAL AND monat IS INITIAL.

    IF periodos IS NOT INITIAL.
      SELECT FROM z606file AS ddbb
             INNER JOIN @periodos AS http_req ON ddbb~gjahr EQ http_req~gjahr
                                              AND ddbb~monat EQ http_req~monat
             FIELDS ddbb~uuid,
                    ddbb~gjahr,
                    ddbb~monat
             INTO TABLE @DATA(valid_data).
    ENDIF.

    LOOP AT entities INTO DATA(entity).

      IF line_exists( valid_data[ gjahr = entity-gjahr monat = entity-monat ] ).

        APPEND VALUE #( %tky = entity-%tky ) TO failed-e606file.

        APPEND VALUE #( %tky       = entity-%tky
                       %state_area = 'VALIDATE_PERIOD'
                       %msg        =  new_message( id       = 'Z_606_MC'
                                                   number   = '019'
                                                   severity = if_abap_behv_message=>severity-error )
*                       %element-monat = if_abap_behv=>mk-on
                        ) TO reported-e606file.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD validateyear.

    READ ENTITIES OF zt_r_606file IN LOCAL MODE
    ENTITY e606file
    FIELDS ( gjahr )
    WITH CORRESPONDING #( keys )
    RESULT DATA(entities).

    LOOP AT entities INTO DATA(entity).

      IF entity-gjahr IS INITIAL.

        APPEND VALUE #( %tky = entity-%tky ) TO failed-e606file.

        APPEND VALUE #( %tky       = entity-%tky
                       %state_area = 'VALIDATE_YEAR'
                       %msg        =  new_message( id       = 'Z_606_MC'
                                                   number   = '017'
                                                   severity = if_abap_behv_message=>severity-error )
                       %element-gjahr = if_abap_behv=>mk-on
                        ) TO reported-e606file.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
