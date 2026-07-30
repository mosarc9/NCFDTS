CLASS lhc_zt_r_paymt606 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR pay606 RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR pay606 RESULT result.

    METHODS resume FOR MODIFY
      IMPORTING keys FOR ACTION pay606~resume.

    METHODS validpaykey FOR VALIDATE ON SAVE
      IMPORTING keys FOR pay606~validpaykey.

    METHODS validpaymt FOR VALIDATE ON SAVE
      IMPORTING keys FOR pay606~validpaymt.

ENDCLASS.

CLASS lhc_zt_r_paymt606 IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD resume.
  ENDMETHOD.

  METHOD validpaykey.
    DATA paykeys TYPE SORTED TABLE OF zpaymt_606 WITH UNIQUE KEY client uuid paykey.

    READ ENTITIES OF zt_r_paymt606 IN LOCAL MODE
    ENTITY pay606
    FIELDS ( Paykey )
    WITH CORRESPONDING #( keys )
    RESULT DATA(paymts).

    paykeys = CORRESPONDING #( paymts DISCARDING DUPLICATES MAPPING paykey = Paykey EXCEPT * ).
    DELETE paykeys WHERE paykey IS INITIAL.

    IF paykeys IS NOT INITIAL.
      SELECT FROM zpaymt_606 AS a
      INNER JOIN @paykeys AS b ON a~paykey = b~paykey
      FIELDS  a~client, a~uuid, a~paykey
      INTO TABLE @DATA(valid_taxcode).

      SELECT FROM I_PaymentMethod AS a
      INNER JOIN @paykeys AS b ON a~PaymentMethod = b~paykey
      FIELDS a~PaymentMethod
      INTO TABLE @DATA(valid_taxcode2).

    ENDIF.


    LOOP AT paymts INTO DATA(pay606).
      IF pay606-Paykey IS INITIAL.

        APPEND VALUE #( %tky = pay606-%tky ) TO failed-pay606.

        APPEND VALUE #( %tky        = pay606-%tky
                        %state_area = 'VALIDATE_PAYKEY'
                        %msg        =  new_message( id      = 'Z_606_MC'
                                                   number   = '013'
                                                   severity = if_abap_behv_message=>severity-error )
                       %element-paykey = if_abap_behv=>mk-on ) TO reported-pay606.

      ELSEIF NOT line_exists( valid_taxcode2[ PaymentMethod = pay606-Paykey ] ).
        APPEND VALUE #( %tky      = pay606-%tky ) TO failed-pay606.
        APPEND VALUE #( %tky      = pay606-%tky
                      %state_area = 'VALIDATE_PAYKEY'
                      %msg        =  new_message( id       = 'Z_606_MC'
                                                  number   = '015'
                                                  v1       = pay606-Paykey
                                                  severity = if_abap_behv_message=>severity-error )
                      %element-paykey = if_abap_behv=>mk-on ) TO reported-pay606.

      ELSEIF line_exists( valid_taxcode[ paykey = pay606-Paykey ] ).
        APPEND VALUE #( %tky        = pay606-%tky ) TO failed-pay606.
        APPEND VALUE #( %tky        = pay606-%tky
                        %state_area = 'VALIDATE_PAYKEY'
                        %msg        =  new_message( id       = 'Z_606_MC'
                                                    number   = '014'
                                                    v1       = pay606-Paykey
                                                    severity = if_abap_behv_message=>severity-error )
                        %element-paykey = if_abap_behv=>mk-on ) TO reported-pay606.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD validpaymt.

    READ ENTITIES OF zt_r_paymt606 IN LOCAL MODE
    ENTITY pay606
    FIELDS ( Paymt )
    WITH CORRESPONDING #( keys )
    RESULT DATA(pays606).

    LOOP AT pays606 INTO DATA(pay606).
      IF pay606-Paymt IS INITIAL.

        APPEND VALUE #( %tky = pay606-%tky ) TO failed-pay606.

        APPEND VALUE #( %tky        = pay606-%tky
                        %state_area = 'VALIDATE_PAYMT'
                        %msg        =  new_message( id      = 'Z_606_MC'
                                                   number   = '016'
                                                   severity = if_abap_behv_message=>severity-error )
                       %element-paymt = if_abap_behv=>mk-on ) TO reported-pay606.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
