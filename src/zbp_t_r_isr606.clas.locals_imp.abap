CLASS lhc_isr606 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR isr606 RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR isr606 RESULT result.

    METHODS resume FOR MODIFY
      IMPORTING keys FOR ACTION isr606~resume.

    METHODS validisrttpe FOR VALIDATE ON SAVE
      IMPORTING keys FOR isr606~validisrttpe.

    METHODS validtaxcode FOR VALIDATE ON SAVE
      IMPORTING keys FOR isr606~validtaxcode.

ENDCLASS.

CLASS lhc_isr606 IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD resume.
  ENDMETHOD.

  METHOD validisrttpe.

    TYPES: BEGIN OF ty_taxcode,
             taxcode TYPE saknr,
           END OF ty_taxcode.


    DATA taxcodes TYPE SORTED TABLE OF ty_taxcode WITH UNIQUE KEY taxcode.

    READ ENTITIES OF zt_r_isr606 IN LOCAL MODE
    ENTITY isr606
    FIELDS ( Taxcode Isrtype )
    WITH CORRESPONDING #( keys )
    RESULT DATA(isrs606).

    taxcodes = CORRESPONDING #( isrs606 DISCARDING DUPLICATES MAPPING taxcode = taxcode EXCEPT * ).
    DELETE taxcodes WHERE taxcode IS INITIAL.


    IF taxcodes IS NOT INITIAL.
      SELECT FROM zz1_tipos_itbis AS a
      INNER JOIN @taxcodes AS b ON a~withholdingtaxcode = b~taxcode
      FIELDS a~withholdingtaxcode, a~withholdingtaxtype
      INTO TABLE @DATA(valid_taxcode2).
    ENDIF.

    LOOP AT isrs606 INTO DATA(isr606).

      IF line_exists( valid_taxcode2[ withholdingtaxcode = isr606-taxcode ] ).

        CHECK valid_taxcode2[ withholdingtaxcode = isr606-taxcode ]-withholdingtaxtype = 'IS'.

        IF isr606-isrtype IS INITIAL.

          APPEND VALUE #( %tky = isr606-%tky ) TO failed-isr606.

          APPEND VALUE #( %tky        = isr606-%tky
                          %state_area = 'VALIDATE_ISRTYPE'
                          %msg        =  new_message( id      = 'Z_606_MC'
                                                     number   = '012'
                                                     severity = if_abap_behv_message=>severity-error )
                         %element-isrtype = if_abap_behv=>mk-on ) TO reported-isr606.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validtaxcode.

    DATA taxcodes TYPE SORTED TABLE OF zisr_606 WITH UNIQUE KEY client uuid isrcode.

    READ ENTITIES OF zt_r_isr606 IN LOCAL MODE
    ENTITY isr606
    FIELDS ( taxcode )
    WITH CORRESPONDING #( keys )
    RESULT DATA(taxes606).

    taxcodes = CORRESPONDING #( taxes606 DISCARDING DUPLICATES MAPPING isrcode = taxcode EXCEPT * ).
    DELETE taxcodes WHERE isrcode IS INITIAL.

    IF taxcodes IS NOT INITIAL.
      SELECT FROM zisr_606 AS a
      INNER JOIN @taxcodes AS b ON a~isrcode = b~isrcode
      FIELDS  a~client, a~uuid, a~isrcode
      INTO TABLE @DATA(valid_taxcode).

*      SELECT FROM i_taxcode AS a
*      INNER JOIN @taxcodes AS b ON a~ = b~isrcode
*      FIELDS a~taxcode
      SELECT FROM zz1_tipos_retencion AS a
      INNER JOIN @taxcodes AS b ON a~withholdingtaxcode = b~isrcode
      FIELDS a~withholdingtaxcode
      INTO TABLE @DATA(valid_taxcode2).

    ENDIF.


    LOOP AT taxes606 INTO DATA(tax606).
      IF tax606-taxcode IS INITIAL.

        APPEND VALUE #( %tky = tax606-%tky ) TO failed-isr606.

        APPEND VALUE #( %tky        = tax606-%tky
                        %state_area = 'VALIDATE_TAXCODE'
                        %msg        =  new_message( id      = 'Z_606_MC'
                                                   number   = '004'
                                                   severity = if_abap_behv_message=>severity-error )
                       %element-taxcode = if_abap_behv=>mk-on ) TO reported-isr606.

*      ELSEIF NOT line_exists( valid_taxcode2[ taxcode = tax606-taxcode ] ).
      ELSEIF NOT line_exists( valid_taxcode2[ withholdingtaxcode = tax606-taxcode ] ).
        APPEND VALUE #( %tky      = tax606-%tky
                      %state_area = 'VALIDATE_TAXCODE'
                      %msg        =  new_message( id       = 'Z_606_MC'
                                                  number   = '005'
                                                  v1       = tax606-taxcode
                                                  severity = if_abap_behv_message=>severity-error )
                      %element-taxcode = if_abap_behv=>mk-on ) TO reported-isr606.

      ELSEIF line_exists( valid_taxcode[ isrcode = tax606-taxcode ] ).

        APPEND VALUE #( %tky        = tax606-%tky
                        %state_area = 'VALIDATE_TAXCODE'
                        %msg        =  new_message( id       = 'Z_606_MC'
                                                    number   = '006'
                                                    v1       = tax606-taxcode
                                                    severity = if_abap_behv_message=>severity-error )
                        %element-taxcode = if_abap_behv=>mk-on ) TO reported-isr606.
      ENDIF.
    ENDLOOP.


  ENDMETHOD.

ENDCLASS.
