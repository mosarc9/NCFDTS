CLASS lhc_configncf DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR configncf RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR configncf RESULT result.

    METHODS precheck_update FOR PRECHECK
      IMPORTING entities FOR UPDATE configncf.

    METHODS resume FOR MODIFY
      IMPORTING keys FOR ACTION configncf~resume.

    METHODS validatebukrs FOR VALIDATE ON SAVE
      IMPORTING keys FOR configncf~validatebukrs.

    METHODS validatecldoc FOR VALIDATE ON SAVE
      IMPORTING keys FOR configncf~validatecldoc.

    METHODS validateplant FOR VALIDATE ON SAVE
      IMPORTING keys FOR configncf~validateplant.
    METHODS validatemodule FOR VALIDATE ON SAVE
      IMPORTING keys FOR configncf~validatemodule.

ENDCLASS.

CLASS lhc_configncf IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD precheck_update.
  ENDMETHOD.

  METHOD resume.
  ENDMETHOD.

  METHOD validatebukrs.

    DATA companies TYPE SORTED TABLE OF i_companycode WITH UNIQUE KEY companycode.

    READ ENTITIES OF zt_r_conf_ncf IN LOCAL MODE
         ENTITY configncf
         FIELDS ( bukrs )
         WITH CORRESPONDING #( keys )
         RESULT DATA(configs).

    companies = CORRESPONDING #( configs DISCARDING DUPLICATES MAPPING companycode = bukrs EXCEPT * ).
    DELETE companies WHERE companycode IS INITIAL.


    IF companies IS NOT INITIAL.
      SELECT FROM i_companycode AS ddbb
             INNER JOIN @companies AS http_req ON ddbb~companycode EQ http_req~companycode
             FIELDS ddbb~companycode
             INTO TABLE @DATA(valid_companies).
    ENDIF.


    LOOP AT configs INTO DATA(config).

      IF config-bukrs IS INITIAL.
        APPEND VALUE #( %tky = config-%tky ) TO failed-configncf.


        APPEND VALUE #( %tky                = config-%tky
                        %state_area         = 'VALIDATE_COMPANY'
                        %msg                =  new_message( id   = 'Z_NCF_MC'
                                                            number   = '001'
                                                            severity = if_abap_behv_message=>severity-error )
                        %element-bukrs = if_abap_behv=>mk-on ) TO reported-configncf.

      ELSEIF NOT line_exists( valid_companies[ companycode = config-bukrs ] ).

        APPEND VALUE #( %tky = config-%tky ) TO failed-configncf.

        APPEND VALUE #( %tky                = config-%tky
                        %state_area         = 'VALIDATE_COMPANY'
                        %msg                = new_message( id   = 'Z_NCF_MC'
                                                            number   = '002'
                                                            severity = if_abap_behv_message=>severity-error )
                        %element-bukrs = if_abap_behv=>mk-on ) TO reported-configncf.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD validatecldoc.

    READ ENTITIES OF zt_r_conf_ncf IN LOCAL MODE
         ENTITY configncf
         FIELDS ( cldoc )
         WITH CORRESPONDING #( keys )
         RESULT DATA(configs).

    LOOP AT configs INTO DATA(config).
      IF config-cldoc IS INITIAL.
        APPEND VALUE #( %tky = config-%tky ) TO failed-configncf.


        APPEND VALUE #( %tky                = config-%tky
                        %state_area         = 'VALIDATE_CLDOC'
                        %msg                =  new_message( id   = 'Z_NCF_MC'
                                                            number   = '007'
                                                            severity = if_abap_behv_message=>severity-error )
                        %element-cldoc = if_abap_behv=>mk-on ) TO reported-configncf.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateplant.
    DATA plants TYPE SORTED TABLE OF i_plant WITH UNIQUE KEY plant.

    READ ENTITIES OF zt_r_conf_ncf IN LOCAL MODE
         ENTITY configncf
         FIELDS ( plant )
         WITH CORRESPONDING #( keys )
         RESULT DATA(configs).

    plants = CORRESPONDING #( configs DISCARDING DUPLICATES MAPPING plant = plant EXCEPT * ).
    DELETE plants WHERE plant IS INITIAL.


    IF plants IS NOT INITIAL.
      SELECT FROM i_plant AS ddbb
             INNER JOIN @plants AS http_req ON ddbb~plant EQ http_req~plant
             FIELDS ddbb~plant
             INTO TABLE @DATA(valid_plants).
    ENDIF.



    LOOP AT configs INTO DATA(config).

      CHECK config-plant IS NOT INITIAL.
*      IF config-plant IS INITIAL.
*        APPEND VALUE #( %tky = config-%tky ) TO failed-configncf.
*
*
*        APPEND VALUE #( %tky                = config-%tky
*                        %state_area         = 'VALIDATE_PLANT'
*                        %msg                =  new_message( id   = 'Z_NCF_MC'
*                                                            number   = '003'
*                                                            severity = if_abap_behv_message=>severity-error )
*                        %element-plant = if_abap_behv=>mk-on ) TO reported-configncf.
*
*      ELSEIF NOT line_exists( valid_plants[ plant = config-plant ] ).
      IF NOT line_exists( valid_plants[ plant = config-plant ] ).

        APPEND VALUE #( %tky = config-%tky ) TO failed-configncf.

        APPEND VALUE #( %tky                = config-%tky
                        %state_area         = 'VALIDATE_PLANT'
                        %msg                = new_message( id   = 'Z_NCF_MC'
                                                            number   = '004'
                                                            severity = if_abap_behv_message=>severity-error )
                        %element-plant = if_abap_behv=>mk-on ) TO reported-configncf.

      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD validatemodule.

    READ ENTITIES OF zt_r_conf_ncf IN LOCAL MODE
      ENTITY configncf
      FIELDS ( Modulo )
      WITH CORRESPONDING #( keys )
      RESULT DATA(configs).

    LOOP AT configs INTO DATA(config).
      IF config-Modulo IS INITIAL.
        APPEND VALUE #( %tky = config-%tky ) TO failed-configncf.


        APPEND VALUE #( %tky                = config-%tky
                        %state_area         = 'VALIDATE_MODULE'
                        %msg                =  new_message( id   = 'Z_NCF_MC'
                                                            number   = '008'
                                                            severity = if_abap_behv_message=>severity-error )
                        %element-modulo = if_abap_behv=>mk-on ) TO reported-configncf.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
