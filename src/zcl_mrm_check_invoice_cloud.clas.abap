CLASS zcl_mrm_check_invoice_cloud DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_badi_interface .
    INTERFACES if_ex_mrm_check_invoice_cloud .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_MRM_CHECK_INVOICE_CLOUD IMPLEMENTATION.


  METHOD if_ex_mrm_check_invoice_cloud~check_invoice.


    CHECK headerdata-documentheadertext IS NOT INITIAL.

    DATA(lv_cldoc) = CONV zcl_doc( headerdata-accountingdocumenttype ).
    DATA(lv_modulo) = CONV zmodulo( 'FI' ).

    IF headerdata-documentheadertext IS NOT INITIAL.

      IF action = if_ex_mrm_check_invoice_cloud=>c_action_post              OR "Post - contabilizar
         action = if_ex_mrm_check_invoice_cloud=>c_action_save_as_completed OR "guardar como completa
         action = if_ex_mrm_check_invoice_cloud=>c_action_check             OR "Verificar
         action = if_ex_mrm_check_invoice_cloud=>c_action_simulate.            "Simular

        DATA lv_mnumber TYPE n LENGTH 3.

        DATA(lo_val) = zcl_validacion_ncf=>create(
                                                  p_lifnr    = headerdata-invoicingparty
                                                  p_fecha    = headerdata-documentdate
                                                  p_sociedad = headerdata-companycode
                                                  p_cldoc    = lv_cldoc
                                                  p_modulo   = lv_modulo
                                                  p_textoc   = headerdata-documentheadertext
                                                ).

        DATA(lv_ret) = lo_val->validacion_ncf(  ).

        CHECK lv_ret <> '0'.

        CASE lv_ret.
          WHEN '1'.
            lv_mnumber = '008'.
          WHEN '2'.
            lv_mnumber = '009'.
          WHEN '4'.
            lv_mnumber = '007'.
          WHEN '5'.
            lv_mnumber = '005'.
          WHEN '8'.
            lv_mnumber = '006'.
          WHEN OTHERS.
            lv_mnumber = '005'.
        ENDCASE.

        DATA(lv_msg1) = COND symsgv(  WHEN lv_mnumber = '006' THEN lo_val->gv_belnr
                                      WHEN lv_mnumber = '007' THEN lo_val->gv_rcn
                                      WHEN lv_mnumber = '008' THEN lo_val->gv_rcn
                                      ELSE '' ).

        APPEND VALUE #( messagetype = if_ex_mrm_check_invoice_cloud=>c_messagetype_error
                        messageid = 'ZCM_NCF_V2'
                        messagenumber = lv_mnumber
                        messagevariable1 = lv_msg1
                     ) TO messages.
      ENDIF.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
