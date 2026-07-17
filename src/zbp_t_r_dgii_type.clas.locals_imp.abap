CLASS lhc_zt_r_dgii_type DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR dgiitype RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR dgiitype RESULT result.

    METHODS resume FOR MODIFY
      IMPORTING keys FOR ACTION dgiitype~resume.

    METHODS setdgiitype FOR DETERMINE ON SAVE
      IMPORTING keys FOR dgiitype~setdgiitype.
    METHODS dgiitype FOR VALIDATE ON SAVE
      IMPORTING keys FOR dgiitype~dgiitype.
    METHODS validdescr FOR VALIDATE ON SAVE
      IMPORTING keys FOR dgiitype~validdescr.

ENDCLASS.

CLASS lhc_zt_r_dgii_type IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD resume.
  ENDMETHOD.

  METHOD setdgiitype.

*    READ ENTITIES OF zt_r_dgii_type IN LOCAL MODE
*    ENTITY dgiitype
*    FIELDS ( dgiitype )
*    WITH CORRESPONDING #( keys )
*    RESULT DATA(dgiitypes).
*
*    DELETE dgiitypes WHERE dgiitype IS NOT INITIAL.
*
*    CHECK dgiitypes IS NOT INITIAL.
*
*    SELECT SINGLE FROM zdgii_type
*           FIELDS MAX( dgiitype )
*           INTO @DATA(max_dgiitype).
*
*    MODIFY ENTITIES OF zt_r_dgii_type IN LOCAL MODE
*        ENTITY dgiitype
*        UPDATE
*        FIELDS ( dgiitype )
*        WITH VALUE #( FOR dgiitype IN dgiitypes INDEX INTO i ( %tky    = dgiitype-%tky
*                                                              dgiitype = max_dgiitype + i ) ).
  ENDMETHOD.

  METHOD dgiitype.

    DATA dgiitypes TYPE SORTED TABLE OF zdgii_type WITH UNIQUE KEY client dgiitype.


    READ ENTITIES OF zt_r_dgii_type IN LOCAL MODE
    ENTITY dgiitype
    FIELDS ( dgiitype )
    WITH CORRESPONDING #( keys )
    RESULT DATA(dgiity).


    dgiitypes = CORRESPONDING #( dgiity DISCARDING DUPLICATES MAPPING dgiitype = dgiitype EXCEPT * ).
    DELETE dgiitypes WHERE dgiitype IS INITIAL.

    IF dgiitypes IS NOT INITIAL.

      SELECT FROM zdgii_type AS ddbb
      INNER JOIN @dgiity AS http_req ON ddbb~dgiitype EQ http_req~dgiitype
      FIELDS ddbb~dgiitype
      INTO TABLE @DATA(valid_dgiitypes).

    ENDIF.

    LOOP AT dgiity INTO DATA(line).
      IF line-dgiitype IS INITIAL.

        APPEND VALUE #( %tky = line-%tky ) TO failed-dgiitype.

        APPEND VALUE #( %tky        = line-%tky
                        %state_area = 'VALIDATE_DGIITYPE'
                        %msg        =  new_message( id      = 'Z_606_MC'
                                                   number   = '010'
                                                   severity = if_abap_behv_message=>severity-error )
                       %element-dgiitype = if_abap_behv=>mk-on ) TO reported-dgiitype.

      ELSEIF line_exists( valid_dgiitypes[ dgiitype = line-dgiitype ] ).
        APPEND VALUE #( %tky = line-%tky ) TO failed-dgiitype.

        APPEND VALUE #( %tky        = line-%tky
                        %state_area = 'VALIDATE_DGIITYPE'
                        %msg        =  new_message( id      = 'Z_606_MC'
                                                   number   = '011'
                                                   v1       = line-dgiitype
                                                   severity = if_abap_behv_message=>severity-error )
                       %element-dgiitype = if_abap_behv=>mk-on ) TO reported-dgiitype.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validdescr.

    READ ENTITIES OF zt_r_dgii_type IN LOCAL MODE
    ENTITY dgiitype
    FIELDS ( descr )
    WITH CORRESPONDING #( keys )
    RESULT DATA(descriptions).

    LOOP AT descriptions INTO DATA(desc).
      IF desc-descr IS INITIAL.

        APPEND VALUE #( %tky = desc-%tky ) TO failed-dgiitype.

        APPEND VALUE #( %tky        = desc-%tky
                        %state_area = 'VALIDATE_DESCR'
                        %msg        =  new_message( id      = 'Z_606_MC'
                                                   number   = '008'
                                                   severity = if_abap_behv_message=>severity-error )
                       %element-descr = if_abap_behv=>mk-on ) TO reported-dgiitype.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
