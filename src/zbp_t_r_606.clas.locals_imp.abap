CLASS lhc_zt_r_606 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR map606 RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR map606 RESULT result.

    METHODS resume FOR MODIFY
      IMPORTING keys FOR ACTION map606~resume.

    METHODS validatesaknr FOR VALIDATE ON SAVE
      IMPORTING keys FOR map606~validatesaknr.

ENDCLASS.

CLASS lhc_zt_r_606 IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD resume.
  ENDMETHOD.

  METHOD validatesaknr.

    TYPES: BEGIN OF ty_saknr,
             saknr TYPE saknr,
           END OF ty_saknr.


    DATA saknrs TYPE SORTED TABLE OF ty_saknr WITH UNIQUE KEY saknr.

    READ ENTITIES OF zt_r_606 IN LOCAL MODE
    ENTITY map606
    FIELDS ( saknr )
    WITH CORRESPONDING #( keys )
    RESULT DATA(maps606).

    saknrs = CORRESPONDING #( maps606 DISCARDING DUPLICATES MAPPING saknr = saknr EXCEPT * ).
    DELETE saknrs WHERE saknr IS INITIAL.

    IF saknrs IS NOT INITIAL.
      SELECT FROM zmap_606 AS a
      INNER JOIN @saknrs AS b ON a~saknr = b~saknr
      FIELDS a~saknr
      INTO TABLE @DATA(valid_saknr).

      SELECT FROM i_glaccountinchartofaccounts AS a
      INNER JOIN @saknrs AS b ON a~glaccount = b~saknr
      FIELDS a~glaccount
      INTO TABLE @DATA(valid_saknr2).

    ENDIF.

    LOOP AT maps606 INTO DATA(map606).
      IF map606-saknr IS INITIAL.

        APPEND VALUE #( %tky = map606-%tky ) TO failed-map606.

        APPEND VALUE #( %tky       = map606-%tky
                       %state_area = 'VALIDATE_SAKNR'
                       %msg        =  new_message( id       = 'Z_606_MC'
                                                   number   = '001'
                                                   severity = if_abap_behv_message=>severity-error )
                       %element-saknr = if_abap_behv=>mk-on ) TO reported-map606.

      ELSEIF NOT line_exists( valid_saknr2[ glaccount = map606-saknr ] ).
        APPEND VALUE #( %tky      = map606-%tky ) TO failed-map606.
        APPEND VALUE #( %tky      = map606-%tky
                      %state_area = 'VALIDATE_SAKNR'
                      %msg        =  new_message( id       = 'Z_606_MC'
                                                  number   = '002'
                                                  v1       = map606-saknr
                                                  severity = if_abap_behv_message=>severity-error )
                      %element-saknr = if_abap_behv=>mk-on ) TO reported-map606.

      ELSEIF line_exists( valid_saknr[ saknr = map606-saknr ] ).

        APPEND VALUE #( %tky        = map606-%tky ) TO failed-map606.
        APPEND VALUE #( %tky        = map606-%tky
                        %state_area = 'VALIDATE_SAKNR'
                        %msg        =  new_message( id       = 'Z_606_MC'
                                                    number   = '003'
                                                    v1       = map606-saknr
                                                    severity = if_abap_behv_message=>severity-error )
                        %element-saknr = if_abap_behv=>mk-on ) TO reported-map606.
      ENDIF.
    ENDLOOP.



  ENDMETHOD.

ENDCLASS.
