*"* use this source file for your ABAP unit test classes

CLASS ltcl_validacion_ncf DEFINITION

  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PUBLIC SECTION.
    DATA gv_ret TYPE sysubrc.
    METHODS:
      test_is_valid FOR TESTING.

  PRIVATE SECTION.

    DATA mo_cut TYPE REF TO zcl_validacion_ncf. "Class under test.
    METHODS:
      setup,
      teardown.
ENDCLASS.

CLASS ltcl_validacion_ncf IMPLEMENTATION.
  METHOD setup.

    mo_cut = zcl_validacion_ncf=>create(
      p_lifnr    = '0000100016'
      p_fecha    = '20260225'
      p_sociedad = '5000'
      p_cldoc    = 'RE'
      p_modulo   = 'FI'
      p_textoc   = 'E01000020001'  " prefijo(3)=B01, serie=B, tipo=01, num(13)
    ).
  ENDMETHOD.


  METHOD teardown.
    CLEAR mo_cut.
  ENDMETHOD.


  METHOD test_is_valid.
    DATA retorno TYPE sysubrc.

    DATA(lv_ret) = mo_cut->debe_generar_comprobante( ).

    IF lv_ret EQ abap_TRUE.
      mo_cut->generar_comprobante(
        RECEIVING
          return = DATA(lv_next)
      ).
    ENDIF.



    gv_ret = '0'.

    cl_abap_unit_assert=>assert_equals(
        act = gv_ret
        exp = '0'
        msg = 'Se esperaba 0' ).
  ENDMETHOD.
ENDCLASS.
