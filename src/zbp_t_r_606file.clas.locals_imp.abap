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
    METHODS validatebukrs FOR VALIDATE ON SAVE
      IMPORTING keys FOR e606file~validatebukrs.

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

      IF entity-bukrs IS INITIAL.
        APPEND VALUE #( %tky = entity-%tky ) TO failed-e606file.

        APPEND VALUE #( %tky       = entity-%tky
                       %state_area = 'VALIDATE_DOWNLOAD'
                       %msg        =  new_message( id       = 'Z_606_MC'
                                                   number   = '020'
                                                   severity = if_abap_behv_message=>severity-error )
                       %element-bukrs = if_abap_behv=>mk-on
                        ) TO reported-e606file.

      ELSEIF entity-gjahr IS INITIAL.
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

        DATA lv_tot TYPE n LENGTH 12.

        DATA(lv_name) = |{ entity-bukrs }_| & |{ entity-gjahr }| & |{ entity-monat }| & |.txt|.

        SELECT SINGLE FROM zt_r_h606 AS a INNER JOIN i_companycode AS b ON  a~companycode = b~companycode
                                                                        AND b~country = 'DO'
        FIELDS a~*
        WHERE a~companycode = @entity-bukrs
        AND   a~fiscalyear  = @entity-gjahr
        AND   a~fmonth      = @entity-monat
        INTO @DATA(header).

        IF sy-subrc EQ 0.

          SELECT SINGLE FROM i_companycode
          FIELDS vatregistration
          WHERE companycode = @entity-bukrs
          INTO @DATA(cedula).

          IF sy-subrc EQ 0.
            cedula = replace( val = cedula pcre = '\D' with = '' occ = 0 ).

          ENDIF.

          SELECT FROM zt_r_d606
          FIELDS *
          WHERE companycode = @entity-bukrs
          AND   fiscalyear  = @entity-gjahr
          AND   fmonth      = @entity-monat
          INTO TABLE @DATA(detail).

          DATA(lv_total_det) = lines( detail ).
          lv_tot = |{ lv_total_det } ALPHA = IN |.

          DATA(lv_csv) = |606\|{ cedula }\|{ entity-gjahr }{ entity-monat }\|{ lv_tot }| && cl_abap_char_utilities=>newline.

          LOOP AT detail INTO DATA(ldet).
            DATA(lv_tabix) = sy-tabix.

            " Formateo de todos los campos de tipo P
            DATA(lv_totalservicio)   = COND string( WHEN ldet-totalservicio > 0   THEN | { ldet-totalservicio DECIMALS = 2 }|   ELSE || ).
            DATA(lv_totalbien)       = COND string( WHEN ldet-totalbien > 0       THEN | { ldet-totalbien DECIMALS = 2 }|       ELSE || ).
            DATA(lv_totalfacturado)  = COND string( WHEN ldet-totalfacturado > 0  THEN | { ldet-totalfacturado DECIMALS = 2 }|  ELSE || ).
            DATA(lv_itbisfacturado)  = COND string( WHEN ldet-itbisfacturado > 0  THEN | { ldet-itbisfacturado DECIMALS = 2 }|  ELSE || ).
            DATA(lv_itbisretenido)   = COND string( WHEN ldet-itbisretenido > 0   THEN | { ldet-itbisretenido DECIMALS = 2 }|   ELSE || ).
            DATA(lv_itbispropor)     = COND string( WHEN ldet-itbispropor > 0     THEN | { ldet-itbispropor DECIMALS = 2 }|     ELSE || ).
            DATA(lv_itbiscosto)      = COND string( WHEN ldet-itbiscosto > 0      THEN | { ldet-itbiscosto DECIMALS = 2 }|      ELSE || ).
            DATA(lv_itbisporadelan)  = COND string( WHEN ldet-itbisporadelantar > 0 THEN | { ldet-itbisporadelantar DECIMALS = 2 }| ELSE || ).
            DATA(lv_itbisperccom)    = COND string( WHEN ldet-itbisperccompras > 0 THEN | { ldet-itbisperccompras DECIMALS = 2 }| ELSE || ).
            DATA(lv_montoretrenta)   = COND string( WHEN ldet-montoretrenta > 0   THEN | { ldet-montoretrenta DECIMALS = 2 }|   ELSE || ).
            DATA(lv_isrrenta)        = COND string( WHEN ldet-isrrenta > 0        THEN | { ldet-isrrenta DECIMALS = 2 }|        ELSE || ).
            DATA(lv_montoisc)        = COND string( WHEN ldet-montoisc > 0        THEN | { ldet-montoisc DECIMALS = 2 }|        ELSE || ).
            DATA(lv_otros)           = COND string( WHEN ldet-otros > 0           THEN | { ldet-otros DECIMALS = 2 }|           ELSE || ).
            DATA(lv_mpropinalegal)   = COND string( WHEN ldet-mpropinalegal > 0   THEN | { ldet-mpropinalegal DECIMALS = 2 }|   ELSE || ).
            DATA(lv_clearingdate)    = COND string( WHEN ldet-clearingdate IS NOT INITIAL  THEN |{ ldet-ClearingDate }|   ELSE || ).

            " Concatenamos la línea del detalle
            lv_csv &&= |{ ldet-taxnumber1 }\|{ ldet-tipo_identificacion }\|{ ldet-dgiitype }\|{ ldet-ncf }\|| &&
                       |{ ldet-ncfmod }\|{ ldet-documentdate }\|{ lv_clearingdate }\|{ lv_totalservicio }\|| &&
                       |{ lv_totalbien }\|{ lv_totalfacturado }\|{ lv_itbisfacturado }\|{ lv_itbisretenido }\|| &&
                       |{ lv_itbispropor }\|{ lv_itbiscosto }\|{ lv_itbisporadelan }\|{ lv_itbisperccom }\|| &&
                       |{ ldet-tipoisr }\|{ lv_montoretrenta }\|{ lv_isrrenta }\|{ lv_montoisc }\|| &&
                       |{ lv_otros }\|{ lv_mpropinalegal }\|{ ldet-paymt }|.

            " Se agrega el salto de línea en todos los registros EXCEPTUANDO el último del LOOP
            IF lv_tabix < lv_total_det.
              lv_csv &&= cl_abap_char_utilities=>newline.
            ENDIF.
          ENDLOOP.



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
        ELSE.

          APPEND VALUE #( %tky = entity-%tky ) TO failed-e606file.

          APPEND VALUE #( %tky       = entity-%tky
                         %state_area = 'VALIDATE_DOWNLOAD'
                         %msg        =  new_message( id       = 'M7'
                                                     number   = '789'
                                                     severity = if_abap_behv_message=>severity-error )

                          ) TO reported-e606file.
        ENDIF.
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

    DATA periodos TYPE SORTED TABLE OF z606file WITH UNIQUE KEY client uuid bukrs gjahr monat.

    READ ENTITIES OF zt_r_606file IN LOCAL MODE
    ENTITY e606file
    FIELDS ( bukrs gjahr monat )
    WITH CORRESPONDING #( keys )
    RESULT DATA(entities).

    periodos = CORRESPONDING #( entities DISCARDING DUPLICATES MAPPING bukrs = bukrs gjahr = gjahr monat = monat EXCEPT * ).
    DELETE periodos WHERE bukrs IS INITIAL AND gjahr IS INITIAL AND monat IS INITIAL.

    IF periodos IS NOT INITIAL.
      SELECT FROM z606file AS ddbb
             INNER JOIN @periodos AS http_req ON  ddbb~bukrs EQ http_req~bukrs
                                              AND ddbb~gjahr EQ http_req~gjahr
                                              AND ddbb~monat EQ http_req~monat
             FIELDS ddbb~bukrs,
                    ddbb~uuid,
                    ddbb~gjahr,
                    ddbb~monat
             INTO TABLE @DATA(valid_data).
    ENDIF.

    LOOP AT entities INTO DATA(entity).

      IF line_exists( valid_data[ bukrs = entity-bukrs gjahr = entity-gjahr monat = entity-monat ] ).

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

  METHOD validatebukrs.
    READ ENTITIES OF zt_r_606file IN LOCAL MODE
    ENTITY e606file
    FIELDS ( bukrs )
    WITH CORRESPONDING #( keys )
    RESULT DATA(entities).

    LOOP AT entities INTO DATA(entity).

      IF entity-bukrs IS INITIAL.

        APPEND VALUE #( %tky = entity-%tky ) TO failed-e606file.

        APPEND VALUE #( %tky       = entity-%tky
                       %state_area = 'VALIDATE_BUKRS'
                       %msg        =  new_message( id       = 'Z_606_MC'
                                                   number   = '020'
                                                   severity = if_abap_behv_message=>severity-error )
                       %element-bukrs = if_abap_behv=>mk-on
                        ) TO reported-e606file.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
