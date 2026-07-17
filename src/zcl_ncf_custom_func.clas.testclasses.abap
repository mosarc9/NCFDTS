*"* use this source file for your ABAP unit test classes

CLASS ltcl_ncf_custom_func DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.


    CONSTANTS:
      c_lifnr TYPE lifnr VALUE '0000100077',        " Proveedor existente
      c_bukrs TYPE bukrs VALUE '5000',              " Sociedad válida
      c_datum TYPE datum VALUE '20260226',          " fecha documento
      c_bktxt TYPE bktxt VALUE '',                  " Prefijo + número NFC
      c_blart TYPE blart VALUE 'RE'.                " Tipo de documento válido

    DATA mo_cut TYPE REF TO zcl_ncf_custom_func.

    METHODS:
      setup,

      " Helpers
      build_full_runtime
        RETURNING
          VALUE(rs_runtime) TYPE if_fin_re_custom_function=>t_runtime_controlblock,

      get_bool_from_ref
        IMPORTING
          ir_data        TYPE REF TO data
        RETURNING
          VALUE(rv_bool) TYPE bktxt, "abap_boolean,

      assert_parameter_exists
        IMPORTING
          it_params TYPE if_fin_re_custom_function=>t_parameters
          iv_name   TYPE fin_re_rule_parameter_name,

      " Tests
      test_with_all_parameters         FOR TESTING,
      test_get_name                    FOR TESTING,
      test_get_parameters              FOR TESTING,
      test_get_returntype              FOR TESTING,
      test_is_disabled                 FOR TESTING.

ENDCLASS.



CLASS ltcl_ncf_custom_func IMPLEMENTATION.

  METHOD setup.

    DATA(lv_cldoc) = CONV zcl_doc( c_blart ).
    CREATE OBJECT mo_cut.
*    mo_cut = NEW zcl_validacion_ncf(
*      p_lifnr    = c_lifnr
*      p_fecha    = c_datum
*      p_sociedad = c_bukrs
*      p_cldoc    = lv_cldoc
*      p_modulo   = 'FI'
*      p_textoc   = c_bktxt
*    ).
  ENDMETHOD.

  "----------------------------------------------------------
  " Helper: construir t_runtime_controlblock con los 5 parámetros
  "----------------------------------------------------------
  METHOD build_full_runtime.

    CLEAR rs_runtime.

    rs_runtime-parameters = VALUE if_fin_re_custom_function=>t_runtime_parameters(
      ( name  = 'LIFNR'
        value = REF #( c_lifnr ) )
      ( name  = 'BUKRS'
        value = REF #( c_bukrs ) )
      ( name  = 'DATUM'
        value = REF #( c_datum ) )
      ( name  = 'BKTXT'
        value = REF #( c_bktxt ) )
      ( name  = 'BLART'
        value = REF #( c_blart ) )
    ).

  ENDMETHOD.

  "----------------------------------------------------------
  " Helper: convertir REF TO data a ABAP_BOOLEAN
  "----------------------------------------------------------
  METHOD get_bool_from_ref.

    FIELD-SYMBOLS <lv_any> TYPE any.

    rv_bool = abap_false.

    IF ir_data IS INITIAL.
      RETURN.
    ENDIF.

    ASSIGN ir_data->* TO <lv_any>.
    IF sy-subrc = 0.
      rv_bool = <lv_any>.
    ENDIF.

  ENDMETHOD.

  "----------------------------------------------------------
  " Helper: comprobar que un parámetro existe en GET_PARAMETERS
  "----------------------------------------------------------
  METHOD assert_parameter_exists.

    DATA ls_param TYPE if_fin_re_custom_function=>t_parameter.

    READ TABLE it_params INTO ls_param
      WITH KEY name = iv_name.

    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0
      msg = |El parámetro { iv_name } no está definido en GET_PARAMETERS| ).

  ENDMETHOD.

  "----------------------------------------------------------
  " TEST 1: EXECUTE con todos los parámetros
  "----------------------------------------------------------
  METHOD test_with_all_parameters.

    DATA ls_runtime TYPE if_fin_re_custom_function=>t_runtime_controlblock.
    DATA lr_result  TYPE REF TO data.
    DATA lv_result  TYPE sysubrc.

    ls_runtime = build_full_runtime( ).

    TRY.
        mo_cut->if_fin_re_custom_function~execute(
          EXPORTING
            is_runtime = ls_runtime
          IMPORTING
            ev_result  = lr_result ).
      CATCH cx_fin_re_exception INTO DATA(lx_ex).
        cl_abap_unit_assert=>fail(
          msg = |Se lanzó cx_fin_re_exception en EXECUTE: { lx_ex->get_text( ) }| ).
    ENDTRY.

    " 1) Debe devolver una referencia no inicial
    cl_abap_unit_assert=>assert_not_initial(
      act = lr_result
      msg = 'ev_result debe devolver una referencia no inicial' ).
*
*    " 2) Debe contener un
*    lv_result = get_bool_from_ref( lr_result ).
*
    cl_abap_unit_assert=>assert_equals(
      act = lv_result
      exp = '0'
      msg  = 'El resultado de EXECUTE debe ser 0' ).

  ENDMETHOD.

  "----------------------------------------------------------
  " TEST 2: GET_NAME debe devolver gc_function_name
  "----------------------------------------------------------
  METHOD test_get_name.

*    DATA(lv_name) = mo_cut->if_fin_re_custom_function~get_name( ).
*
*    cl_abap_unit_assert=>assert_equals(
*      act = lv_name
*      exp = zcl_ncf_custom_func=>gc_function_name
*      msg = 'GET_NAME no devuelve el nombre de función esperado' ).

  ENDMETHOD.

  "----------------------------------------------------------
  " TEST 3: GET_PARAMETERS debe exponer todos los parámetros
  "----------------------------------------------------------
  METHOD test_get_parameters.

    DATA lt_params TYPE if_fin_re_custom_function=>t_parameters.

    lt_params = mo_cut->if_fin_re_custom_function~get_parameters( ).

    assert_parameter_exists(
      it_params = lt_params
      iv_name   = 'LIFNR' ). " LIFNR

    assert_parameter_exists(
      it_params = lt_params
      iv_name   = 'BUKRS' ). " BUKRS

    assert_parameter_exists(
      it_params = lt_params
      iv_name   = 'DATUM' ). " DATUM

    assert_parameter_exists(
      it_params = lt_params
      iv_name   = 'BKTXT' ). " BKTXT

    assert_parameter_exists(
      it_params = lt_params
      iv_name   = 'BLART'). " BLART

  ENDMETHOD.

  "----------------------------------------------------------
  " TEST 4: GET_RETURNTYPE debe devolver descriptor no inicial
  "----------------------------------------------------------
  METHOD test_get_returntype.

    DATA lo_type TYPE if_fin_re_custom_function=>t_abaptype.

    lo_type = mo_cut->if_fin_re_custom_function~get_returntype( ).

    cl_abap_unit_assert=>assert_not_initial(
      act = lo_type
      msg = 'GET_RETURNTYPE no devolvió descriptor de tipo' ).

  ENDMETHOD.

  "----------------------------------------------------------
  " TEST 5: IS_DISABLED debe devolver ABAP_FALSE
  "----------------------------------------------------------
  METHOD test_is_disabled.

    DATA(lv_disable) = mo_cut->if_fin_re_custom_function~is_disabled( iv_event_id = '' ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_disable
      exp = abap_false
      msg = 'IS_DISABLED debería devolver ABAP_FALSE para esta función' ).

  ENDMETHOD.

ENDCLASS.
