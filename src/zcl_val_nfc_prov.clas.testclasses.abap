***"* use this source file for your ABAP unit test classes

CLASS ltcl_val_nfc_prov DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PUBLIC SECTION.

    METHODS:
      test_is_valid_when_no_range     FOR TESTING.

  PRIVATE SECTION.



    " Constantes de prueba
    CONSTANTS:
      c_bukrs    TYPE bukrs       VALUE '5000',
*      c_werks    TYPE werks_d     VALUE '1000',
      c_cldoc    TYPE zcl_doc     VALUE 'KR',      " ejemplo
      c_modulo   TYPE zmodulo     VALUE 'SD',       " ejemplo
      c_supplier TYPE lifnr       VALUE '132637097', " AJUSTA A UN PROVEEDOR EXISTENTE
      c_header   TYPE bktxt       VALUE 'E3200000100'. " 3 prefijo + 13 dígitos

    DATA mo_cut TYPE REF TO zcl_val_nfc_prov. "Class under test.

    METHODS:
      setup,
      teardown.

ENDCLASS.



CLASS ltcl_val_nfc_prov IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW #( ).
  ENDMETHOD.


  METHOD teardown.
    CLEAR mo_cut.
  ENDMETHOD.


  METHOD test_is_valid_when_no_range.


    DATA lv_is_nfc TYPE abap_boolean.


    lv_is_nfc = zcl_val_nfc_prov=>is_valid_nfc(
                  p_company  = c_bukrs
*                  p_plant    = c_werks
                  p_cldoc    = c_cldoc
                  p_module   = c_modulo
                  p_supplier = c_supplier
                  p_theader  = c_header ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_is_nfc
      exp = abap_true
      msg = 'Se esperaba IS_NFC = ABAP_TRUE ' ).
  ENDMETHOD.



ENDCLASS.
