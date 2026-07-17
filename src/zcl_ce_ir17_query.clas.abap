CLASS zcl_ce_ir17_query DEFINITION
  PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
ENDCLASS.



CLASS ZCL_CE_IR17_QUERY IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    TYPES: BEGIN OF ty_ir17,
             linea                 TYPE n LENGTH 2,
             concepto_izq          TYPE c LENGTH 30,
             valor_izq             TYPE c LENGTH 50,
             no_ret                TYPE c LENGTH 3,
             concepto_ret          TYPE c LENGTH 60,
             monto                 TYPE p LENGTH 8 DECIMALS 2,
             tasa                  TYPE p LENGTH 3 DECIMALS 2,
             importe               TYPE p LENGTH 8 DECIMALS 2,
             p_periodo             TYPE c LENGTH 7,
             p_tipo_declaracion    TYPE c LENGTH 20,
             p_premios             TYPE p LENGTH 8 DECIMALS 2,
             p_tasa_premios        TYPE p LENGTH 3 DECIMALS 2,
             p_ret_complementarias TYPE p LENGTH 8 DECIMALS 2,
             pdf_link              TYPE c LENGTH 20,
             pdf_url               TYPE c LENGTH 500,
           END OF ty_ir17.

    DATA lt_result TYPE STANDARD TABLE OF ty_ir17.
    DATA ls        TYPE ty_ir17.

    " =============================================================
    " 1. LEER FILTROS DEL REQUEST
    " =============================================================
    DATA lv_bukrs        TYPE c LENGTH 4.
    DATA lv_periodo      TYPE c LENGTH 7.
    DATA lv_fecha_lim    TYPE d.
    DATA lv_tipo_decl    TYPE c LENGTH 20 VALUE 'NORMAL'.
    DATA lv_f_premios    TYPE p LENGTH 8 DECIMALS 2.
    DATA lv_f_tasa_pre   TYPE p LENGTH 3 DECIMALS 2.
    DATA lv_f_ret_compl TYPE p LENGTH 8 DECIMALS 2.
    DATA lv_premios_set TYPE abap_bool.

    " DGII: retenciones complementarias siempre al 27% (no configurable por filtro).
    CONSTANTS gc_tasa_ret_compl TYPE p LENGTH 3 DECIMALS 2 VALUE '27.00'.
    DATA lv_tasa_pre_set TYPE abap_bool.

    " get_as_ranges() lanza CX_RAP_QUERY_FILTER_NO_RANGE si el filtro
    " llega como expresion libre (free-style) en lugar de rangos simples.
    " En ese caso simplemente ignoramos los filtros que no podemos leer.
    TRY.
        DATA(lt_filter) = io_request->get_filter( )->get_as_ranges( ).

        LOOP AT lt_filter INTO DATA(ls_f).
          CASE ls_f-name.
            WHEN 'P_BUKRS'.
              IF ls_f-range IS NOT INITIAL.
                lv_bukrs = ls_f-range[ 1 ]-low.
              ENDIF.
            WHEN 'P_PERIODO'.
              IF ls_f-range IS NOT INITIAL.
                lv_periodo = ls_f-range[ 1 ]-low.
              ENDIF.
            WHEN 'P_FECHA_LIMITE'.
              IF ls_f-range IS NOT INITIAL.
                lv_fecha_lim = ls_f-range[ 1 ]-low.
              ENDIF.
            WHEN 'P_TIPO_DECLARACION'.
              IF ls_f-range IS NOT INITIAL.
                lv_tipo_decl = ls_f-range[ 1 ]-low.
              ENDIF.
            WHEN 'P_PREMIOS'.
              IF ls_f-range IS NOT INITIAL.
                lv_f_premios   = ls_f-range[ 1 ]-low.
                lv_premios_set = abap_true.
              ENDIF.
            WHEN 'P_TASA_PREMIOS'.
              IF ls_f-range IS NOT INITIAL.
                lv_f_tasa_pre   = ls_f-range[ 1 ]-low.
                lv_tasa_pre_set = abap_true.
              ENDIF.
            WHEN 'P_RET_COMPLEMENTARIAS'.
              IF ls_f-range IS NOT INITIAL.
                lv_f_ret_compl = ls_f-range[ 1 ]-low.
              ENDIF.
          ENDCASE.
        ENDLOOP.

      CATCH cx_rap_query_filter_no_range.
        " El filtro llegó como expresión libre; no se pueden leer rangos.
        " Se continua con los valores iniciales (periodo vacio = return abajo).
    ENDTRY.

    IF lv_bukrs IS INITIAL OR lv_periodo IS INITIAL.
      io_response->set_total_number_of_records( 0 ).
      io_response->set_data( lt_result ).
      RETURN.
    ENDIF.

    IF lv_tipo_decl IS INITIAL.
      lv_tipo_decl = 'NORMAL'.
    ENDIF.

    " =============================================================
    " 2. DERIVAR RANGO DE FECHAS Y GJAHR DESDE P_PERIODO (MM-YYYY)
    " =============================================================
    DATA lv_mes_c      TYPE c LENGTH 2.
    DATA lv_year_c     TYPE c LENGTH 4.
    DATA lv_budat_low  TYPE d.
    DATA lv_budat_high TYPE d.

    lv_mes_c  = lv_periodo(2).
    lv_year_c = lv_periodo+3(4).
    lv_budat_low = |{ lv_year_c }{ lv_mes_c }01|.

    " Calcular ultimo dia del mes (dia 1 del mes siguiente - 1)
    DATA lv_mes_i TYPE i.
    DATA lv_yr_i  TYPE i.
    DATA lv_ms2   TYPE c LENGTH 2.
    DATA lv_yr2   TYPE c LENGTH 4.
    lv_mes_i = lv_mes_c.
    lv_yr_i  = lv_year_c.
    IF lv_mes_i = 12.
      lv_ms2  = '01'.
      lv_yr_i = lv_yr_i + 1.
      lv_yr2  = lv_yr_i.
    ELSE.
      lv_mes_i = lv_mes_i + 1.
      lv_ms2   = lv_mes_i.
      lv_yr2   = lv_year_c.
    ENDIF.
    lv_budat_high = |{ lv_yr2 }{ lv_ms2 }01|.
    lv_budat_high = lv_budat_high - 1.

    " =============================================================
    " 3. DATOS DE EMPRESA
    " GUI clasico usaba: T001 (nombre), T001Z-PAVAL (RNC), ADRC (tel/fax)
    " Public Cloud: I_CompanyCode, I_BusinessPartnerTaxNumber, I_BusinessPartnerAddress
    " =============================================================
    DATA: lv_rnc      TYPE c LENGTH 11,
          lv_nombre   TYPE c LENGTH 50,
          lv_telefono TYPE c LENGTH 20,
          lv_fax      TYPE c LENGTH 20.

    " Nombre, RNC y AddressID directamente desde I_CompanyCode.
    " VATRegistration = t001-stceg = RNC de la empresa en Republica Dominicana.
    DATA lv_adrnr TYPE c LENGTH 10.
    SELECT SINGLE CompanyCodeName, VATRegistration, AddressID
      FROM I_CompanyCode
      WHERE CompanyCode = @lv_bukrs
      INTO ( @lv_nombre, @lv_rnc, @lv_adrnr ).

    " Telefono y Fax: las vistas de direccion disponibles en Public Cloud
    " (I_AddressPhoneNumber, I_AddressFaxNumber, I_OrgAddressDefaultRprstn)
    " no exponen PhoneNumber/FaxNumber como columnas accesibles en este tenant.
    " Por ahora quedan vacios (filas 6 y 7 son informativas, no afectan calculos).
    " PENDIENTE: VERIFICAR DE DONDE SACARLAS.

    " =============================================================
    " 4. RETENCIONES REALES DESDE I_WithholdingTaxItem + I_JournalEntry
    " Equivalencias GUI clasico -> Public Cloud:
    "   WITH_ITEM wt_qsshh    -> WtaxBaseAmtInCoCodeCrcy
    "   WITH_ITEM wt_qbshh    -> WithholdingTaxAmtInCoCodeCrcy
    "   BKPF xreversing = ' ' -> I_JournalEntry IsReversalDocument = abap_false
    "   BKPF xreversed  = ' ' -> I_JournalEntry IsReverseDocument  = abap_false
    "   wt_qssh3 < 0          -> WithholdingTaxAmount < 0
    "   G_SET_FETCH('0000CLASIG_IR-17') -> CASE hardcodeado abajo (no existe en Cloud)
    " =============================================================
    DATA: lv_alq TYPE p LENGTH 8 DECIMALS 2,
          lv_hon TYPE p LENGTH 8 DECIMALS 2,
          lv_pre TYPE p LENGTH 8 DECIMALS 2,
          lv_tra TYPE p LENGTH 8 DECIMALS 2,
          lv_div TYPE p LENGTH 8 DECIMALS 2,
          lv_ine TYPE p LENGTH 8 DECIMALS 2,
          lv_rem TYPE p LENGTH 8 DECIMALS 2,
          lv_rpv TYPE p LENGTH 8 DECIMALS 2,
          lv_ot2 TYPE p LENGTH 8 DECIMALS 2,
          lv_o10 TYPE p LENGTH 8 DECIMALS 2.

    DATA: lv_t_alq TYPE p LENGTH 3 DECIMALS 2,
          lv_t_hon TYPE p LENGTH 3 DECIMALS 2,
          lv_t_pre TYPE p LENGTH 3 DECIMALS 2,
          lv_t_tra TYPE p LENGTH 3 DECIMALS 2,
          lv_t_div TYPE p LENGTH 3 DECIMALS 2,
          lv_t_ine TYPE p LENGTH 3 DECIMALS 2,
          lv_t_rem TYPE p LENGTH 3 DECIMALS 2,
          lv_t_rpv TYPE p LENGTH 3 DECIMALS 2,
          lv_t_ot2 TYPE p LENGTH 3 DECIMALS 2,
          lv_t_o10 TYPE p LENGTH 3 DECIMALS 2.

" Retenciones agrupadas por isrtype (tipo DGII desde tabla custom zisr_606).
    " Nombres de campo confirmados desde la definicion de I_WithholdingTaxItem:
    "   wt_qsshh -> WhldgTaxBaseAmtInCoCodeCrcy  (base en moneda sociedad)
    "   wt_qbshh -> WhldgTaxAmtInCoCodeCrcy       (importe retencion en moneda sociedad)
    "   qsatz    -> WithholdingTaxPercent          (tasa, ya en el item - no hace falta join)
    " JOIN con I_JournalEntry (sucesor de I_AccountingDocument, permitido en Cloud).
    " JOIN con zisr_606: traduce WithholdingTaxCode (S1/S2/S3/S4...) -> isrtype DGII
    "   (01 Alquileres, 02 Honorarios, 03 Otras rentas, 04 Otras rentas presuntas,
    "    07 Proveedores del Estado, etc.). Se agrupa por isrtype: si dos WT codes
    "   distintos apuntan al mismo tipo (ej. S1 y S3 -> 03), sus montos se suman.
    " PENDIENTE: confirmar nombres exactos de IsReversal / IsReversed en I_JournalEntry.
    SELECT
        zisr~isrtype,
        SUM( ABS( wt~WhldgTaxBaseAmtInCoCodeCrcy ) ) AS base_sum,
        SUM( ABS( wt~WhldgTaxAmtInCoCodeCrcy     ) ) AS amount_sum,
        MAX( wt~WithholdingTaxPercent             ) AS wt_rate
      FROM I_WithholdingTaxItem AS wt
      INNER JOIN I_JournalEntry AS je
        ON  je~CompanyCode        = wt~CompanyCode
        AND je~AccountingDocument = wt~AccountingDocument
        AND je~FiscalYear         = wt~FiscalYear
      INNER JOIN zisr_606 AS zisr
        ON  zisr~isrcode = wt~WithholdingTaxCode
      WHERE wt~CompanyCode             = @lv_bukrs
        AND wt~FiscalYear              = @lv_year_c
        AND wt~WithholdingTaxType      = 'IS'
        AND je~PostingDate             BETWEEN @lv_budat_low AND @lv_budat_high
        AND je~IsReversal              = @abap_false   " verificar nombre en I_JournalEntry
        AND je~IsReversed              = @abap_false   " verificar nombre en I_JournalEntry
        AND wt~WhldgTaxAmtInCoCodeCrcy < 0
      GROUP BY zisr~isrtype
      INTO TABLE @DATA(lt_wt_items).

    " Mapeo isrtype (zisr_606) -> linea DGII IR-17.
    " Tipos definidos en zisr_606.isrtype (dominio ZISRTYPE):
    "   01 (Alquileres)                              -> Linea  1: Alquileres
    "   02 (Honorarios por servicios)                -> Linea  2: Honorarios Serv. Independientes
    "   03 (Otras rentas)                            -> Linea 17: Otras Rentas (10%)
    "   04 (Otras rentas presuntas)                  -> Linea 16: Otras Rentas presuntas 2%
    "   07 (Retencion por proveedores del Estado)    -> Linea 12: Ret. Proveedores del Estado
    " Tipos sin mapeo directo a IR-17 hoy: 05/06 (intereses residentes), 08 (juegos
    " telefonicos), 09 (ganaderia). Si en el futuro hace falta cubrirlos, agregar
    " el WHEN correspondiente.
    " Linea 10 (Remesas al Exterior) NO se cubre con WithholdingTaxType = 'IS';
    " si se requiere, modelar con otro tipo de retencion (p.ej. 'IR' u otro) y
    " mapear via zisr_606 o un SELECT adicional.
    LOOP AT lt_wt_items INTO DATA(ls_wt).
      CASE ls_wt-isrtype.
        WHEN '01'.  " Linea 1: Alquileres
          lv_alq = ls_wt-base_sum.  lv_t_alq = ls_wt-wt_rate.
        WHEN '02'.  " Linea 2: Honorarios por Servicios Independientes
          lv_hon = ls_wt-base_sum.  lv_t_hon = ls_wt-wt_rate.
        WHEN '03'.  " Linea 17: Otras Rentas (10%)
          lv_o10 = ls_wt-base_sum.  lv_t_o10 = ls_wt-wt_rate.
        WHEN '04'.  " Linea 16: Otras Rentas presuntas 2%
          lv_ot2 = ls_wt-base_sum.  lv_t_ot2 = ls_wt-wt_rate.
        WHEN '07'.  " Linea 12: Ret. Pagos a Proveedores del Estado
          lv_rpv = ls_wt-base_sum.  lv_t_rpv = ls_wt-wt_rate.
      ENDCASE.
    ENDLOOP.


    " =============================================================
    " 5. SOBRESCRIBIR PREMIOS / TASA SI EL USUARIO LOS INGRESO
    " =============================================================
    IF lv_premios_set = abap_true.
      lv_pre = lv_f_premios.
    ENDIF.
    IF lv_tasa_pre_set = abap_true.
      lv_t_pre = lv_f_tasa_pre.
    ENDIF.

    " =============================================================
    " 6. CALCULAR IMPORTES POR LINEA (importe = monto * tasa / 100)
    " =============================================================
    DATA: lv_i_alq TYPE p LENGTH 8 DECIMALS 2,
          lv_i_hon TYPE p LENGTH 8 DECIMALS 2,
          lv_i_pre TYPE p LENGTH 8 DECIMALS 2,
          lv_i_tra TYPE p LENGTH 8 DECIMALS 2,
          lv_i_div TYPE p LENGTH 8 DECIMALS 2,
          lv_i_ine TYPE p LENGTH 8 DECIMALS 2,
          lv_i_rem TYPE p LENGTH 8 DECIMALS 2,
          lv_i_rpv TYPE p LENGTH 8 DECIMALS 2,
          lv_i_ot2 TYPE p LENGTH 8 DECIMALS 2,
          lv_i_o10 TYPE p LENGTH 8 DECIMALS 2.

    lv_i_alq = lv_alq * lv_t_alq / 100.
    lv_i_hon = lv_hon * lv_t_hon / 100.
    lv_i_pre = lv_pre * lv_t_pre / 100.
    lv_i_tra = lv_tra * lv_t_tra / 100.
    lv_i_div = lv_div * lv_t_div / 100.
    lv_i_ine = lv_ine * lv_t_ine / 100.
    lv_i_rem = lv_rem * lv_t_rem / 100.
    lv_i_rpv = lv_rpv * lv_t_rpv / 100.
    lv_i_ot2 = lv_ot2 * lv_t_ot2 / 100.
    lv_i_o10 = lv_o10 * lv_t_o10 / 100.

    " Linea 21: Total retenciones (1+2+3+4+5+6+10+12+16; NO incluye 17)
    DATA lv_monto_21 TYPE p LENGTH 8 DECIMALS 2.
    DATA lv_imp_21   TYPE p LENGTH 8 DECIMALS 2.
    lv_monto_21 = lv_alq + lv_hon + lv_pre + lv_tra
                + lv_div + lv_ine + lv_rem + lv_rpv + lv_ot2.
    lv_imp_21   = lv_i_alq + lv_i_hon + lv_i_pre + lv_i_tra
                + lv_i_div + lv_i_ine + lv_i_rem + lv_i_rpv + lv_i_ot2.

    " Linea 22: Retenciones Complementarias (monto del filtro; tasa fija 27%)
    DATA lv_imp_22 TYPE p LENGTH 8 DECIMALS 2.
    lv_imp_22 = lv_f_ret_compl * gc_tasa_ret_compl / 100.

    " Linea 31: Total a Pagar = importe linea 21 + importe linea 22
    DATA lv_imp_31 TYPE p LENGTH 8 DECIMALS 2.
    lv_imp_31 = lv_imp_21 + lv_imp_22.

    " =============================================================
    " 5. ARMAR LAS 13 FILAS DEL FORMULARIO
    " =============================================================

    " -- Fila 01 --
    CLEAR ls.
    ls-linea        = '01'.
    ls-concepto_izq = 'Periodo'.
    ls-valor_izq    = lv_periodo.
    ls-no_ret       = '1'.
    ls-concepto_ret = 'Alquileres'.
    ls-monto        = lv_alq.
    ls-tasa         = lv_t_alq.
    ls-importe      = lv_i_alq.
    APPEND ls TO lt_result.

    " -- Fila 02 --
    CLEAR ls.
    ls-linea        = '02'.
    ls-concepto_izq = 'Tipo Declaracion'.
    ls-valor_izq    = lv_tipo_decl.
    ls-no_ret       = '2'.
    ls-concepto_ret = 'Honorarios por Serv. Independientes'.
    ls-monto        = lv_hon.
    ls-tasa         = lv_t_hon.
    ls-importe      = lv_i_hon.
    APPEND ls TO lt_result.

    " -- Fila 03 --
    CLEAR ls.
    ls-linea        = '03'.
    ls-concepto_izq = 'Fecha Limite'.
    IF lv_fecha_lim IS NOT INITIAL.
      ls-valor_izq = |{ lv_fecha_lim+6(2) }/{ lv_fecha_lim+4(2) }/{ lv_fecha_lim(4) }|.
    ENDIF.
    ls-no_ret       = '3'.
    ls-concepto_ret = 'Premios'.
    ls-monto        = lv_pre.
    ls-tasa         = lv_t_pre.
    ls-importe      = lv_i_pre.
    APPEND ls TO lt_result.

    " -- Fila 04 --
    CLEAR ls.
    ls-linea        = '04'.
    ls-concepto_izq = 'Numero RNC'.
    ls-valor_izq    = lv_rnc.
    ls-no_ret       = '4'.
    ls-concepto_ret = 'Transferencias de Titulos y Propiedades'.
    ls-monto        = lv_tra.
    ls-tasa         = lv_t_tra.
    ls-importe      = lv_i_tra.
    APPEND ls TO lt_result.

    " -- Fila 05 --
    CLEAR ls.
    ls-linea        = '05'.
    ls-concepto_izq = 'Nombre Comercial'.
    ls-valor_izq    = lv_nombre.
    ls-no_ret       = '5'.
    ls-concepto_ret = 'Dividendos'.
    ls-monto        = lv_div.
    ls-tasa         = lv_t_div.
    ls-importe      = lv_i_div.
    APPEND ls TO lt_result.

    " -- Fila 06 --
    CLEAR ls.
    ls-linea        = '06'.
    ls-concepto_izq = 'Telefono'.
    ls-valor_izq    = lv_telefono.
    ls-no_ret       = '6'.
    ls-concepto_ret = 'Intr. a Int. Cred. del Ext.'.
    ls-monto        = lv_ine.
    ls-tasa         = lv_t_ine.
    ls-importe      = lv_i_ine.
    APPEND ls TO lt_result.

    " -- Fila 07 --
    CLEAR ls.
    ls-linea        = '07'.
    ls-concepto_izq = 'Fax'.
    ls-valor_izq    = lv_fax.
    ls-no_ret       = '10'.
    ls-concepto_ret = 'Remesas al Exterior'.
    ls-monto        = lv_rem.
    ls-tasa         = lv_t_rem.
    ls-importe      = lv_i_rem.
    APPEND ls TO lt_result.

    " -- Fila 08 (izquierda vacia desde aqui) --
    CLEAR ls.
    ls-linea        = '08'.
    ls-no_ret       = '12'.
    ls-concepto_ret = 'Ret. por pagos a Proveedores del Estado'.
    ls-monto        = lv_rpv.
    ls-tasa         = lv_t_rpv.
    ls-importe      = lv_i_rpv.
    APPEND ls TO lt_result.

    " -- Fila 09 --
    CLEAR ls.
    ls-linea        = '09'.
    ls-no_ret       = '16'.
    ls-concepto_ret = 'Otras Rentas (rentas presuntas 2%)'.
    ls-monto        = lv_ot2.
    ls-tasa         = lv_t_ot2.
    ls-importe      = lv_i_ot2.
    APPEND ls TO lt_result.

    " -- Fila 10 --
    CLEAR ls.
    ls-linea        = '10'.
    ls-no_ret       = '17'.
    ls-concepto_ret = 'Otras Rentas (10%)'.
    ls-monto        = lv_o10.
    ls-tasa         = lv_t_o10.
    ls-importe      = lv_i_o10.
    APPEND ls TO lt_result.

    " -- Fila 11: Total retenciones --
    CLEAR ls.
    ls-linea        = '11'.
    ls-no_ret       = '21'.
    ls-concepto_ret = 'Total retenciones (Suma 1+2+3+4+5+6+10+12+16)'.
    ls-monto        = lv_monto_21.
    ls-importe      = lv_imp_21.
    APPEND ls TO lt_result.

    " -- Fila 12: Retenciones Complementarias --
    CLEAR ls.
    ls-linea        = '12'.
    ls-no_ret       = '22'.
    ls-concepto_ret = 'Retenciones Complementarias'.
    ls-monto        = lv_f_ret_compl.
    ls-tasa         = gc_tasa_ret_compl.
    ls-importe      = lv_imp_22.
    APPEND ls TO lt_result.

    " -- Fila 13: Total a Pagar + link al PDF --
    CLEAR ls.
    ls-linea        = '13'.
    ls-no_ret       = '31'.
    ls-concepto_ret = 'Total a Pagar (21+22)'.
    ls-importe      = lv_imp_31.

    " Construir URL al HTTP Service con los parametros actuales del filtro.
    " IMPORTANTE: ajustar '/sap/bc/http/sap/zhttp_ir17' si tu HTTP Service
    " tiene otra ruta. Verificar en ADT al crear el servicio.
    DATA lv_s_nombre TYPE string.
    lv_s_nombre = lv_nombre. CONDENSE lv_s_nombre.
    DATA lv_s_rnc TYPE string.
    lv_s_rnc = lv_rnc. CONDENSE lv_s_rnc.
    DATA lv_s_tel TYPE string.
    lv_s_tel = lv_telefono. CONDENSE lv_s_tel.
    DATA lv_s_fax TYPE string.
    lv_s_fax = lv_fax. CONDENSE lv_s_fax.

    DATA(lv_pdf_url) = |https://my406252.s4hana.cloud.sap| && |/sap/bc/http/sap/ZCL_HTTP_IR17| && |?sap-client=080| &&
      |&periodo={ lv_periodo }| &&
      |&tipo_decl={ lv_tipo_decl }| &&
      |&fecha_lim={ lv_fecha_lim }| &&
      |&nombre={ lv_s_nombre }| &&
      |&rnc={ lv_s_rnc }| &&
      |&tel={ lv_s_tel }| &&
      |&fax={ lv_s_fax }| &&
      |&alq={ lv_alq DECIMALS = 2 }&talq={ lv_t_alq DECIMALS = 2 }| &&
      |&hon={ lv_hon DECIMALS = 2 }&thon={ lv_t_hon DECIMALS = 2 }| &&
      |&pre={ lv_pre DECIMALS = 2 }&tpre={ lv_t_pre DECIMALS = 2 }| &&
      |&tra={ lv_tra DECIMALS = 2 }&ttra={ lv_t_tra DECIMALS = 2 }| &&
      |&div={ lv_div DECIMALS = 2 }&tdiv={ lv_t_div DECIMALS = 2 }| &&
      |&ine={ lv_ine DECIMALS = 2 }&tine={ lv_t_ine DECIMALS = 2 }| &&
      |&rem={ lv_rem DECIMALS = 2 }&trem={ lv_t_rem DECIMALS = 2 }| &&
      |&rpv={ lv_rpv DECIMALS = 2 }&trpv={ lv_t_rpv DECIMALS = 2 }| &&
      |&ot2={ lv_ot2 DECIMALS = 2 }&tot2={ lv_t_ot2 DECIMALS = 2 }| &&
      |&o10={ lv_o10 DECIMALS = 2 }&to10={ lv_t_o10 DECIMALS = 2 }| &&
      |&ret_compl={ lv_f_ret_compl DECIMALS = 2 }|.

    ls-pdf_link = 'Generar IR-17'.
    ls-pdf_url  = lv_pdf_url.
    APPEND ls TO lt_result.

    " =============================================================
    " 6. PAGINACION
    " =============================================================
    DATA(lv_offset) = io_request->get_paging( )->get_offset( ).
    DATA(lv_top)    = io_request->get_paging( )->get_page_size( ).

    IF lv_top > 0 AND lv_top < lines( lt_result ).
      DATA lt_page TYPE STANDARD TABLE OF ty_ir17.
      LOOP AT lt_result INTO DATA(ls_pg) FROM ( lv_offset + 1 ).
        APPEND ls_pg TO lt_page.
        IF lines( lt_page ) >= lv_top.
          EXIT.
        ENDIF.
      ENDLOOP.
      lt_result = lt_page.
    ELSEIF lv_offset > 0.
      DELETE lt_result TO lv_offset.
    ENDIF.

    " =============================================================
    " 7. RESPUESTA
    " =============================================================
    io_response->set_total_number_of_records( 13 ).
    io_response->set_data( lt_result ).

  ENDMETHOD.
ENDCLASS.
