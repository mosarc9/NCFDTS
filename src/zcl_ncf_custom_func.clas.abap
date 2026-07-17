CLASS zcl_ncf_custom_func DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_fin_re_custom_function .
    TYPES:    gty_prd TYPE bktxt. "sysubrc.
  PROTECTED SECTION.
    CLASS-DATA: gv_ret TYPE bktxt. "sysubrc.

  PRIVATE SECTION.
    CONSTANTS: gc_function_name TYPE fin_re_custom_function_name VALUE 'ZCO_DERIVE_PRD',
               gc_parameter_1   TYPE c LENGTH 5 VALUE 'LIFNR',
               gc_parameter_2   TYPE c LENGTH 5 VALUE 'BUKRS',
               gc_parameter_3   TYPE c LENGTH 5 VALUE 'DATUM',
               gc_parameter_4   TYPE c LENGTH 5 VALUE 'BKTXT',
               gc_parameter_5   TYPE c LENGTH 5 VALUE 'BLART'.
ENDCLASS.



CLASS ZCL_NCF_CUSTOM_FUNC IMPLEMENTATION.


  METHOD if_fin_re_custom_function~check_at_rule_activation.
    ev_rc = if_fin_re_custom_function=>rc-ok.
  ENDMETHOD.


  METHOD if_fin_re_custom_function~execute.

    READ TABLE is_runtime-parameters WITH KEY p COMPONENTS name = gc_parameter_1 INTO DATA(ls_lifnr).
    READ TABLE is_runtime-parameters WITH KEY p COMPONENTS name = gc_parameter_2 INTO DATA(ls_bukrs).
    READ TABLE is_runtime-parameters WITH KEY p COMPONENTS name = gc_parameter_3 INTO DATA(ls_datum).
    READ TABLE is_runtime-parameters WITH KEY p COMPONENTS name = gc_parameter_4 INTO DATA(ls_bktxt).
    READ TABLE is_runtime-parameters WITH KEY p COMPONENTS name = gc_parameter_5 INTO DATA(ls_blart).

    IF ls_lifnr-value IS BOUND AND
       ls_bukrs-value IS BOUND AND
       ls_datum-value IS BOUND AND
       ls_bktxt-value IS BOUND AND
       ls_blart-value IS BOUND.

      DATA(lv_lifnr) = CONV lifnr( ls_lifnr-value->* ).
      DATA(lv_bukrs) = CONV bukrs( ls_bukrs-value->* ).
      DATA(lv_datum) = CONV datum( ls_datum-value->* ).
      DATA(lv_bktxt) = CONV bktxt( ls_bktxt-value->* ).
      DATA(lv_blart) = CONV blart( ls_blart-value->* ).


      DATA(lv_cldoc) = CONV zcl_doc( lv_blart ).
      DATA(lv_modulo) = CONV zmodulo( 'FI' ).

*      DATA(lv_flag) = zcl_val_nfc_prov=>is_valid_nfc(
*                        p_company  = lv_bukrs
**                        p_plant    =
*                        p_cldoc    = lv_cldoc
*                        p_module   = lv_modulo
*                        p_supplier = lv_lifnr
*                        p_theader  = lv_bktxt
*                      ).
*
*      gv_flag = lv_flag.

      DATA(lo_val) = zcl_validacion_ncf=>create(
                                               p_lifnr    = lv_lifnr
                                               p_fecha    = lv_datum
                                               p_sociedad = lv_bukrs
                                               p_cldoc    = lv_cldoc
                                               p_modulo   = lv_modulo
                                               p_textoc   = lv_bktxt ).

      IF lo_val->debe_generar_comprobante( ) EQ abap_true.

        DATA(lv_ret) = lo_val->generar_comprobante( ).
      ENDIF.


      gv_ret = lv_ret.

    ENDIF.

    ev_result = REF #( gv_ret ) .
  ENDMETHOD.


  METHOD if_fin_re_custom_function~get_description.
  ENDMETHOD.


  METHOD if_fin_re_custom_function~get_name.
    rv_name = gc_function_name.
  ENDMETHOD.


  METHOD if_fin_re_custom_function~get_parameters.
    rt_parameters = VALUE #(
    ( name = gc_parameter_1 abap_type = CAST cl_abap_elemdescr( cl_abap_typedescr=>describe_by_name( 'LIFNR' ) ) )
    ( name = gc_parameter_2 abap_type = CAST cl_abap_elemdescr( cl_abap_typedescr=>describe_by_name( 'BUKRS' ) ) )
    ( name = gc_parameter_3 abap_type = CAST cl_abap_elemdescr( cl_abap_typedescr=>describe_by_name( 'DATUM' ) ) )
    ( name = gc_parameter_4 abap_type = CAST cl_abap_elemdescr( cl_abap_typedescr=>describe_by_name( 'BKTXT' ) ) )
    ( name = gc_parameter_5 abap_type = CAST cl_abap_elemdescr( cl_abap_typedescr=>describe_by_name( 'BLART' ) ) )
      ).
  ENDMETHOD.


  METHOD if_fin_re_custom_function~get_returntype.
    ro_type =  CAST cl_abap_elemdescr( cl_abap_typedescr=>describe_by_name( 'ZCL_NCF_CUSTOM_FUNC=>GTY_PRD' ) ).
  ENDMETHOD.


  METHOD if_fin_re_custom_function~get_return_valuehelp.
  ENDMETHOD.


  METHOD if_fin_re_custom_function~is_disabled.

    " Evaluamos el evento para Journal Entry Item (Posición)
    CASE iv_event_id.
*      WHEN 'FINS_ACC_ITM_1'.
*        rv_disable = abap_false. " Habilitado para posiciones de diario

        " Se necesita en cabecera
      WHEN 'FINS_ACC_HDR_1'.
        rv_disable = abap_false.

      WHEN OTHERS.
        rv_disable = abap_true.  " Deshabilitado para todo lo demás
    ENDCASE.

    rv_disable = abap_false.
  ENDMETHOD.
ENDCLASS.
