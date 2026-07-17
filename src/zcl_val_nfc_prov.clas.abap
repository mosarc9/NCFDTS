CLASS zcl_val_nfc_prov DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CONSTANTS:
      gv_std TYPE c VALUE 'B', "Comprobante estándar:
      gv_ele TYPE c VALUE 'E'. "Comprobante electrónico

    TYPES:BEGIN OF ty_tipo,
            num TYPE n LENGTH 2,
          END OF ty_tipo,

          ty_t_tipo TYPE SORTED TABLE OF ty_tipo WITH UNIQUE KEY num.

    CLASS-DATA:
      gt_tipo_e TYPE ty_t_tipo,
      gt_tipo_b TYPE ty_t_tipo.

    CLASS-METHODS:
      is_valid_nfc IMPORTING p_company     TYPE bukrs
                             p_plant       TYPE werks_d OPTIONAL
                             p_cldoc       TYPE zcl_doc
                             p_module      TYPE zmodulo
                             p_supplier    TYPE lifnr
                             p_theader     TYPE bktxt

                   RETURNING VALUE(is_nfc) TYPE abap_boolean.
  PROTECTED SECTION.
  PRIVATE SECTION.



ENDCLASS.



CLASS ZCL_VAL_NFC_PROV IMPLEMENTATION.


  METHOD is_valid_nfc.

    DATA:
      lv_prefix TYPE c LENGTH 3,
      lv_serie  TYPE c LENGTH 1,
      lv_tipo   TYPE n LENGTH 2,
      lv_num    TYPE n LENGTH 13,
      ls_serie  TYPE ty_tipo.
*      ls_supplier TYPE ty_supp.

    DATA(l_date) = cl_abap_context_info=>get_system_date( ).


    lv_prefix = p_theader(3).
    lv_serie  = p_theader(1).
    lv_tipo   = p_theader+1(2).
    lv_num    = p_theader+3(13).

*   NOTA: Se solicitaron estos valores como HARDCODE
    ls_serie-num = '01'. INSERT ls_serie INTO TABLE gt_tipo_b. "Comprobante estándar:
    ls_serie-num = '02'. INSERT ls_serie INTO TABLE gt_tipo_b.
    ls_serie-num = '03'. INSERT ls_serie INTO TABLE gt_tipo_b.
    ls_serie-num = '04'. INSERT ls_serie INTO TABLE gt_tipo_b.
    ls_serie-num = '11'. INSERT ls_serie INTO TABLE gt_tipo_b.
    ls_serie-num = '13'. INSERT ls_serie INTO TABLE gt_tipo_b.
    ls_serie-num = '14'. INSERT ls_serie INTO TABLE gt_tipo_b.
    ls_serie-num = '15'. INSERT ls_serie INTO TABLE gt_tipo_b.
    ls_serie-num = '16'. INSERT ls_serie INTO TABLE gt_tipo_b.
    ls_serie-num = '17'. INSERT ls_serie INTO TABLE gt_tipo_b.

    ls_serie-num = '31'. INSERT ls_serie INTO TABLE gt_tipo_e. "Comprobante electrónico
    ls_serie-num = '32'. INSERT ls_serie INTO TABLE gt_tipo_e.
    ls_serie-num = '33'. INSERT ls_serie INTO TABLE gt_tipo_e.
    ls_serie-num = '34'. INSERT ls_serie INTO TABLE gt_tipo_e.
    ls_serie-num = '41'. INSERT ls_serie INTO TABLE gt_tipo_e.
    ls_serie-num = '43'. INSERT ls_serie INTO TABLE gt_tipo_e.
    ls_serie-num = '44'. INSERT ls_serie INTO TABLE gt_tipo_e.
    ls_serie-num = '45'. INSERT ls_serie INTO TABLE gt_tipo_e.
    ls_serie-num = '46'. INSERT ls_serie INTO TABLE gt_tipo_e.
    ls_serie-num = '47'. INSERT ls_serie INTO TABLE gt_tipo_e.



*   Obtener el grupo de cliente del proveedor.
    SELECT SINGLE FROM i_supplier WITH PRIVILEGED ACCESS
    FIELDS taxnumber1, taxnumbertype
    WHERE supplier = @p_supplier
    INTO @DATA(ls_supplier).

    IF sy-subrc EQ 0.

*     Verficar si esta comfigurado el cliente para validar NFC
      SELECT SINGLE FROM zz1_config_ncf
      FIELDS
      znrnr
      WHERE bukrs = @p_company
       AND  werks = @p_plant
       AND cldoc = @p_cldoc
       AND stcdc = @ls_supplier-taxnumbertype
      INTO @DATA(lv_znrnr).

*     SI NO HAY RANGO DEFINIDO.
      IF sy-subrc EQ 0 AND lv_znrnr IS INITIAL.

        SELECT SINGLE FROM zz1_firncncf
        FIELDS *
        WHERE rcn   = @ls_supplier-taxnumber1
        AND prefijo = @lv_prefix
        AND ncfini  LE @lv_num
        AND ncffin  GE @lv_num
        INTO @DATA(ls_data) .

        IF sy-subrc EQ 0.


          IF lv_serie <> gv_std AND
             lv_serie <> gv_ele.

            is_nfc = abap_false.
            RETURN.
          ENDIF.

          CASE lv_serie.
            WHEN gv_std. "B  - Estandar
              IF NOT line_exists( gt_tipo_b[ num = lv_tipo ] ).
                is_nfc = abap_false.
                RETURN.
              ENDIF.
            WHEN gv_ele. "E - Electronico
              IF NOT line_exists( gt_tipo_e[ num = lv_tipo ] ).
                is_nfc = abap_false.
                RETURN.
              ENDIF.
          ENDCASE.

          IF ls_data-validohasta EQ '' .
            is_nfc = abap_true.
          ELSEIF ls_data-validohasta GE l_date.
            is_nfc = abap_true.
          ELSE.
            is_nfc = abap_false.
          ENDIF.

        ELSE.
          is_nfc = abap_false.
        ENDIF.

      ELSE.
        is_nfc = abap_true.
      ENDIF.
    ELSE.
      is_nfc = abap_true.
    ENDIF.


  ENDMETHOD.
ENDCLASS.
