CLASS zcl_validacion_ncf DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE .

  PUBLIC SECTION.
    DATA:
      gv_lifnr    TYPE lifnr        READ-ONLY,
      gv_rcn      TYPE c LENGTH 16  READ-ONLY,
      gv_stcdt    TYPE c LENGTH 2   READ-ONLY,
      gv_xcpdk    TYPE abap_boolean READ-ONLY,
      gv_sociedad TYPE bukrs        READ-ONLY,
      gv_fecha    TYPE d            READ-ONLY,
      gv_cldoc    TYPE zcl_doc      READ-ONLY,
      gv_modulo   TYPE zmodulo      READ-ONLY,
      gv_textoc   TYPE bktxt        READ-ONLY,
      gv_belnr    TYPE belnr_d      READ-ONLY,
      gv_serie    TYPE zserie       READ-ONLY.

    CLASS-METHODS create
      IMPORTING
                p_lifnr       TYPE lifnr
                p_fecha       TYPE d
                p_sociedad    TYPE bukrs
                p_cldoc       TYPE zcl_doc
                p_modulo      TYPE zmodulo
                p_textoc      TYPE bktxt
      RETURNING VALUE(ro_obj) TYPE REF TO zcl_validacion_ncf.


    METHODS:
      validacion_ncf           RETURNING VALUE(return) TYPE sysubrc,
      debe_generar_comprobante RETURNING VALUE(return) TYPE abap_boolean,
      generar_comprobante        RETURNING VALUE(return) TYPE zcomprobante.


  PROTECTED SECTION.

  PRIVATE SECTION.
    DATA gv_retorno  TYPE sysubrc.

    METHODS:
      constructor IMPORTING p_lifnr    TYPE lifnr
                            p_fecha    TYPE datum
                            p_sociedad TYPE bukrs
                            p_cldoc    TYPE zcl_doc
                            p_modulo   TYPE zmodulo
                            p_textoc   TYPE bktxt,

      validar_estructura_ncf CHANGING p_retorno TYPE sysubrc,
      validar_ncf_dgii       CHANGING p_retorno TYPE sysubrc,
      validar_duplicidad     CHANGING p_retorno TYPE sysubrc
                                      p_belnr   TYPE belnr_d.
ENDCLASS.



CLASS ZCL_VALIDACION_NCF IMPLEMENTATION.


  METHOD create.
    ro_obj = NEW zcl_validacion_ncf(
      p_lifnr    = p_lifnr
      p_fecha    = p_fecha
      p_sociedad = p_sociedad
      p_cldoc    = p_cldoc
      p_modulo   = p_modulo
      p_textoc   = p_textoc
    ).
  ENDMETHOD.


  METHOD constructor .

*   Obtener el info del proveedor.
    SELECT SINGLE FROM i_supplier WITH PRIVILEGED ACCESS
    FIELDS taxnumber1, taxnumbertype, isonetimeaccount
    WHERE supplier = @p_lifnr
    INTO @DATA(ls_supplier).

    IF sy-subrc EQ 0.
      me->gv_rcn = ls_supplier-taxnumber1.
      me->gv_stcdt = ls_supplier-taxnumbertype.
      me->gv_xcpdk = ls_supplier-isonetimeaccount.
    ENDIF.


    me->gv_lifnr    = p_lifnr.
    me->gv_fecha    = p_fecha.
    me->gv_sociedad = p_sociedad.
    me->gv_cldoc    = p_cldoc.
    me->gv_modulo   = p_modulo.
    me->gv_textoc   = p_textoc.
  ENDMETHOD.


  METHOD validacion_ncf.

*     Verficar si esta comfigurado el cliente para validar NFC
    SELECT SINGLE FROM zz1_config_ncf
    FIELDS
    znrnr
    WHERE bukrs = @me->gv_sociedad
*       AND  werks = @p_plant
     AND cldoc = @me->gv_cldoc
     AND stcdc = @me->gv_stcdt
    INTO @DATA(lv_znrnr).

*   SI NO HAY RANGO DEFINIDO.
    IF sy-subrc EQ 0 AND lv_znrnr IS INITIAL.
      me->validar_estructura_ncf(
        CHANGING
          p_retorno = me->gv_retorno
      ).

      IF me->gv_retorno = 0.
        me->validar_ncf_dgii(
          CHANGING
            p_retorno = me->gv_retorno
        ).
      ENDIF.

      IF me->gv_retorno = 0.
        me->validar_duplicidad(
          CHANGING
            p_retorno = me->gv_retorno
            p_belnr   = me->gv_belnr
        ).
      ENDIF.

      return = me->gv_retorno.
    ELSE.
      return = '0'.
    ENDIF.

  ENDMETHOD.


  METHOD validar_estructura_ncf.

    CONSTANTS:
      lc_std TYPE c VALUE 'B', "Comprobante estándar:
      lc_ele TYPE c VALUE 'E'. "Comprobante electrónico

    TYPES:BEGIN OF ty_tipo,
            num TYPE n LENGTH 2,
          END OF ty_tipo,

          ty_t_tipo TYPE SORTED TABLE OF ty_tipo WITH UNIQUE KEY num.

    DATA:
      lt_tipo_e TYPE ty_t_tipo,
      lt_tipo_b TYPE ty_t_tipo,
      ls_serie  TYPE ty_tipo,
      lv_prefix TYPE c LENGTH 3,
      lv_serie  TYPE c LENGTH 1,
      lv_tipo   TYPE n LENGTH 2,
      lv_len    TYPE i.

    lv_prefix = me->gv_textoc(3).
    lv_serie  = me->gv_textoc(1).
    lv_tipo   = me->gv_textoc+1(2).

    ls_serie-num = '01'. INSERT ls_serie INTO TABLE lt_tipo_b. "Comprobante estándar:
    ls_serie-num = '02'. INSERT ls_serie INTO TABLE lt_tipo_b.
    ls_serie-num = '03'. INSERT ls_serie INTO TABLE lt_tipo_b.
    ls_serie-num = '04'. INSERT ls_serie INTO TABLE lt_tipo_b.
    ls_serie-num = '11'. INSERT ls_serie INTO TABLE lt_tipo_b.
    ls_serie-num = '13'. INSERT ls_serie INTO TABLE lt_tipo_b.
    ls_serie-num = '14'. INSERT ls_serie INTO TABLE lt_tipo_b.
    ls_serie-num = '15'. INSERT ls_serie INTO TABLE lt_tipo_b.
    ls_serie-num = '16'. INSERT ls_serie INTO TABLE lt_tipo_b.
    ls_serie-num = '17'. INSERT ls_serie INTO TABLE lt_tipo_b.

    ls_serie-num = '31'. INSERT ls_serie INTO TABLE lt_tipo_e. "Comprobante electrónico
    ls_serie-num = '32'. INSERT ls_serie INTO TABLE lt_tipo_e.
    ls_serie-num = '33'. INSERT ls_serie INTO TABLE lt_tipo_e.
    ls_serie-num = '34'. INSERT ls_serie INTO TABLE lt_tipo_e.
    ls_serie-num = '41'. INSERT ls_serie INTO TABLE lt_tipo_e.
    ls_serie-num = '43'. INSERT ls_serie INTO TABLE lt_tipo_e.
    ls_serie-num = '44'. INSERT ls_serie INTO TABLE lt_tipo_e.
    ls_serie-num = '45'. INSERT ls_serie INTO TABLE lt_tipo_e.
    ls_serie-num = '46'. INSERT ls_serie INTO TABLE lt_tipo_e.
    ls_serie-num = '47'. INSERT ls_serie INTO TABLE lt_tipo_e.

    IF lv_serie <> lc_std AND
       lv_serie <> lc_ele.

      p_retorno = '5'.
      RETURN.
    ENDIF.

    lv_len = strlen( me->gv_textoc ).

    CASE lv_serie.
      WHEN lc_std. "B  - Estandar

        IF lv_len NE 11.
          p_retorno = '5'.
          RETURN.
        ENDIF.
        IF NOT line_exists( lt_tipo_b[ num = lv_tipo ] ).
          p_retorno = '5'.
          RETURN.
        ENDIF.
      WHEN lc_ele. "E - Electronico

        IF lv_len NE 13.
          p_retorno = '5'.
          RETURN.
        ENDIF.

        IF NOT line_exists( lt_tipo_e[ num = lv_tipo ] ).
          p_retorno = '5'.
          RETURN.
        ENDIF.
    ENDCASE.

    p_retorno = '0'.
  ENDMETHOD.


  METHOD validar_ncf_dgii.

    DATA:
      v_like TYPE c LENGTH 6,
      lv_num TYPE n LENGTH 13.

    lv_num = me->gv_textoc+3(13).

    CONCATENATE  me->gv_textoc(3) '%' INTO v_like.

    SELECT  FROM ztfirncncf_e
    FIELDS *
    WHERE  rcn     EQ   @me->gv_rcn
    AND  prefijo LIKE @v_like
    AND ncfini  LE @lv_num
    AND ncffin  GE @lv_num
    ORDER BY ncfini DESCENDING
    INTO TABLE @DATA(lt_data).

    IF sy-subrc EQ 0.
      p_retorno = 0."todo correcto


      LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs>).
        "Asegurar que el comprobante recibido está
        "dentro del rango asignado por DGII
        IF ( <fs>-ncffin < lv_num ) OR ( <fs>-ncfini > lv_num ).
          p_retorno = 1."rango agotado
          EXIT.
        ENDIF.

        "Verificar vencimiento
        IF ( <fs>-valido_hasta IS NOT INITIAL AND
             <fs>-valido_hasta NE space )  .
          IF <fs>-valido_hasta < me->gv_fecha.
            p_retorno = 2."Rango vencido
            EXIT.
          ENDIF.
        ENDIF.

        IF  p_retorno = 0."todo correcto.
          EXIT.
        ENDIF.

      ENDLOOP.

    ELSE.
*     MessageError Acreedor con rangos de NCF asignado
      p_retorno = 4."rango no encontrado
      RETURN.
    ENDIF.
  ENDMETHOD.


  METHOD validar_duplicidad.

    DATA: v_ejercicio TYPE gjahr.


**********************************************************************
    DATA lv_fiscyear TYPE gjahr.

*   1) Variante de ejercicio de la sociedad
    SELECT SINGLE fiscalyearvariant
      FROM i_companycode WITH PRIVILEGED ACCESS
      WHERE companycode = @me->gv_sociedad
      INTO @DATA(lv_fyv).

*   2) Ejercicio fiscal para la fecha
    SELECT SINGLE fiscalyear
      FROM i_fiscalcalendardate WITH PRIVILEGED ACCESS
      WHERE fiscalyearvariant = @lv_fyv
        AND calendardate      = @me->gv_fecha
      INTO @v_ejercicio.
**********************************************************************

*   Buscar documentos contables con ese comprobante - Cabecera
    SELECT  FROM i_journalentry WITH PRIVILEGED ACCESS
       FIELDS
         accountingdocument           AS belnr,
         companycode                  AS bukrs,
         fiscalyear                   AS gjahr,
         accountingdocumenttype       AS blart,
         referencedocumenttype        AS awtyp,
         originalreferencedocument    AS awkey,
         reversedocument              AS stblg,
         reversalreason               AS stgrd,
         accountingdocumentcategory   AS bstat,
         transactioncode              AS tcode,
         accountingdocumentheadertext AS bktxt
    WHERE fiscalyear = @v_ejercicio
    AND accountingdocumentheadertext = @me->gv_textoc
    INTO TABLE @DATA(t_bkpf_dup).

*   Borrar documentos anulados
    DELETE t_bkpf_dup WHERE stblg IS NOT INITIAL
                         OR stgrd IS NOT INITIAL.

    IF t_bkpf_dup[] IS NOT INITIAL."Lectura cabecera NCF duplicado

*     Buscar documentos con acreedor - con uno basta

      SELECT FROM i_journalentryitem WITH PRIVILEGED ACCESS AS a INNER JOIN @t_bkpf_dup AS b ON a~companycode = b~bukrs
                                                                     AND a~accountingdocument = b~belnr
                                                                     AND a~fiscalyear = b~gjahr
                                                                     AND a~supplier = @me->gv_lifnr
       FIELDS
         companycode        AS bukrs,
         accountingdocument AS belnr,
         fiscalyear         AS gjahr,
         supplier           AS lifnr
      INTO TABLE @DATA(t_bseg_dup). "TABLE


      IF sy-subrc = 0 ."Lectura acreedor BSEG

        DATA(ls_bseg_dup) = t_bseg_dup[ 1 ].

        IF me->gv_xcpdk = 'X'.

*         Busca el num de ducumento por rnc para verificar que sea del mismo acreedor.
          SELECT COUNT(*) FROM i_onetimeaccountcustomer WITH PRIVILEGED ACCESS
             WHERE companycode        = @ls_bseg_dup-bukrs AND
                   accountingdocument = @ls_bseg_dup-belnr AND
                   fiscalyear         = @ls_bseg_dup-gjahr AND
                   taxid1             = @me->gv_rcn.

          IF sy-subrc = 0.
            p_retorno = 8."Duplicado; se revierte en caso de no estar anulado en logística
            p_belnr = ls_bseg_dup-belnr.
          ENDIF.

        ELSE."Se encontró documento con acreedor
          p_retorno = 8."Duplicado; se revierte en caso de no estar anulado en logística
          p_belnr = ls_bseg_dup-belnr.
        ENDIF.

*       Confirmar que no esté anulado en Módulo Logístic
        IF line_exists( t_bkpf_dup[ bukrs = ls_bseg_dup-bukrs
                                    belnr = ls_bseg_dup-belnr
                                    gjahr = ls_bseg_dup-gjahr
                                    awkey = 'RMRP' ] ).  " 'RMRP'."Documento de logística

          DATA(ls_bkpf_dup) = t_bkpf_dup[ bukrs = ls_bseg_dup-bukrs
                                    belnr = ls_bseg_dup-belnr
                                    gjahr = ls_bseg_dup-gjahr
                                    awkey = 'RMRP' ].

          DATA(len) = strlen( ls_bkpf_dup-awkey ) - 4."EL EJERCICIO SIEMPRE QUEDA AL FINAL
          DATA(gjahr_rbkp) = ls_bkpf_dup-awkey+len(4).

          SELECT SINGLE
            FROM i_supplierinvoiceapi01
            FIELDS
            reversedocument AS stblg
               WHERE companycode EQ @ls_bkpf_dup-bukrs
                 AND supplierinvoice EQ @ls_bkpf_dup-awkey(10)
                 AND fiscalyear EQ @gjahr_rbkp
            INTO @DATA(lv_stblg).

          IF sy-subrc =   0.
            IF lv_stblg NE space."ANULADO
              p_retorno = 0."NO Duplicado
            ELSE."NO ANULADO
              p_retorno = 8."Duplicado
              p_belnr = ls_bseg_dup-belnr.
              RETURN.

            ENDIF.
          ENDIF.

        ENDIF.

      ELSE.
        p_retorno = 0."no duplicado
      ENDIF."Lectura acreedor BSEG

    ELSE.
      p_retorno = 0."no duplicado
    ENDIF."Lectura cabecera NCF duplicado

  ENDMETHOD.


  METHOD debe_generar_comprobante.
*   Verficar si esta comfigurado el cliente para generar comprobante
    SELECT SINGLE FROM zz1_config_ncf
    FIELDS
    znrnr,
    serie
    WHERE bukrs = @me->gv_sociedad
     AND cldoc = @me->gv_cldoc
     AND stcdc = @me->gv_stcdt
    INTO @DATA(lv_data).


*   SI HAY RANGO DEFINIDO.
    IF sy-subrc EQ 0 AND
       lv_data-znrnr IS NOT INITIAL AND
       lv_data-serie IS NOT INITIAL.
      me->gv_serie = lv_data-serie.
      return = abap_true.
    ELSE.
      return = abap_false.
    ENDIF.
  ENDMETHOD.


  METHOD generar_comprobante.

    DATA iv_object TYPE cl_numberrange_intervals=>nr_object.

    CASE me->gv_serie.
      WHEN 'B'.
        iv_object = 'ZCESTANDAR'. "Estandar
      WHEN 'E'.
        iv_object = 'ZCELECTRON'. "Electronico
    ENDCASE.

    TRY.

        cl_numberrange_runtime=>number_get(
          EXPORTING
*            ignore_buffer     =
            nr_range_nr       = '01'
            object            = iv_object
*            quantity          =
*            subobject         =
*            toyear            =
          IMPORTING
            number            = DATA(lv_number)
*            returncode        =
*            returned_quantity =
        ).


        DATA(lv_ret) = |{ me->gv_serie }| & |{ me->gv_stcdt }| & |{ lv_number }|.

        return = lv_ret.

      CATCH cx_nr_object_not_found INTO DATA(lx_obj1).
        return = 'ERROR'.
      CATCH cx_number_ranges INTO DATA(lx_obj3).
        return = 'ERROR'.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
