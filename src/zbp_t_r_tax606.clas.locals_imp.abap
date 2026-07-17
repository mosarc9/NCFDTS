CLASS lhc_tax606 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR tax606 RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR tax606 RESULT result.

    METHODS resume FOR MODIFY
      IMPORTING keys FOR ACTION tax606~resume.

    METHODS validindttpe FOR VALIDATE ON SAVE
      IMPORTING keys FOR tax606~validindttpe.

    METHODS validtaxcode FOR VALIDATE ON SAVE
      IMPORTING keys FOR tax606~validtaxcode.

ENDCLASS.

CLASS lhc_tax606 IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD resume.
  ENDMETHOD.

  METHOD validindttpe.

    READ ENTITIES OF zt_r_tax606 IN LOCAL MODE
    ENTITY tax606
    FIELDS ( indtype )
    WITH CORRESPONDING #( keys )
    RESULT DATA(taxes606).

    LOOP AT taxes606 INTO DATA(tax606).
      IF tax606-indtype IS INITIAL.

        APPEND VALUE #( %tky = tax606-%tky ) TO failed-tax606.

        APPEND VALUE #( %tky        = tax606-%tky
                        %state_area = 'VALIDATE_INDTYPE'
                        %msg        =  new_message( id      = 'Z_606_MC'
                                                   number   = '007'
                                                   severity = if_abap_behv_message=>severity-error )
                       %element-indtype = if_abap_behv=>mk-on ) TO reported-tax606.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validtaxcode.
    TYPES: BEGIN OF ty_taxcode,
             taxcode TYPE saknr,
           END OF ty_taxcode.


    DATA taxcodes TYPE SORTED TABLE OF ty_taxcode WITH UNIQUE KEY taxcode.

    READ ENTITIES OF zt_r_tax606 IN LOCAL MODE
    ENTITY tax606
    FIELDS ( taxcode )
    WITH CORRESPONDING #( keys )
    RESULT DATA(taxes606).

    taxcodes = CORRESPONDING #( taxes606 DISCARDING DUPLICATES MAPPING taxcode = taxcode EXCEPT * ).
    DELETE taxcodes WHERE taxcode IS INITIAL.

    IF taxcodes IS NOT INITIAL.
      SELECT FROM ztax_606 AS a
      INNER JOIN @taxcodes AS b ON a~taxcode = b~taxcode
      FIELDS a~taxcode
      INTO TABLE @DATA(valid_taxcode).

      SELECT FROM i_taxcode AS a
      INNER JOIN @taxcodes AS b ON a~TaxCode = b~taxcode
      FIELDS a~taxcode
*      SELECT FROM zz1_tipos_itbis AS a
*      INNER JOIN @taxcodes AS b ON a~WithholdingTaxCode = b~taxcode
*      FIELDS a~WithholdingTaxCode
      INTO TABLE @DATA(valid_taxcode2).

    ENDIF.


    LOOP AT taxes606 INTO DATA(tax606).
      IF tax606-taxcode IS INITIAL.

        APPEND VALUE #( %tky = tax606-%tky ) TO failed-tax606.

        APPEND VALUE #( %tky        = tax606-%tky
                        %state_area = 'VALIDATE_TAXCODE'
                        %msg        =  new_message( id      = 'Z_606_MC'
                                                   number   = '004'
                                                   severity = if_abap_behv_message=>severity-error )
                       %element-taxcode = if_abap_behv=>mk-on ) TO reported-tax606.

      ELSEIF NOT line_exists( valid_taxcode2[ TaxCode = tax606-taxcode ] ).
*      ELSEIF NOT line_exists( valid_taxcode2[ WithholdingTaxCode = tax606-taxcode ] ).
        APPEND VALUE #( %tky      = tax606-%tky
                      %state_area = 'VALIDATE_TAXCODE'
                      %msg        =  new_message( id       = 'Z_606_MC'
                                                  number   = '005'
                                                  v1       = tax606-taxcode
                                                  severity = if_abap_behv_message=>severity-error )
                      %element-taxcode = if_abap_behv=>mk-on ) TO reported-tax606.

      ELSEIF line_exists( valid_taxcode[ taxcode = tax606-taxcode ] ).

        APPEND VALUE #( %tky        = tax606-%tky
                        %state_area = 'VALIDATE_TAXCODE'
                        %msg        =  new_message( id       = 'Z_606_MC'
                                                    number   = '006'
                                                    v1       = tax606-taxcode
                                                    severity = if_abap_behv_message=>severity-error )
                        %element-taxcode = if_abap_behv=>mk-on ) TO reported-tax606.
      ENDIF.
    ENDLOOP.



  ENDMETHOD.

ENDCLASS.
