CLASS zcl_ce_it1_query DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.

  PRIVATE SECTION.

    " ── Cargadas en inicializar_constantes desde tablas de configuración ──────
    " Tablas: ZTAB_IT1_TC_MAP, ZTAB_IT1_DT_MAP, ZTAB_IT1_WT_MAP
    DATA mt_tc_18   TYPE RANGE OF mwskz.              " tax codes ITBIS 18%
    DATA mt_tc_16   TYPE RANGE OF mwskz.              " tax codes ITBIS 16%
    DATA mt_tc_0    TYPE RANGE OF mwskz.              " tax codes exento/0%
    DATA mt_doc_606 TYPE RANGE OF blart.              " tipos doc 606 (compras)
    DATA mt_doc_607 TYPE RANGE OF blart.              " tipos doc 607 (ventas)
    DATA mt_cta_30    TYPE RANGE OF saknr.            " cuentas GL retención 30%
    DATA mt_cta_100   TYPE RANGE OF saknr.            " cuentas GL retención 100%
    DATA mt_cta_itbis TYPE RANGE OF saknr.            " cuentas GL línea ITBIS
    DATA mt_cta_map   TYPE TABLE OF ztab_cta_map.    " tabla completa cuentas (para tipo_b_s)

    " ── Mapeo TaxCode → indtype DGII (ztax_606) ─────────────────────────────
    "   indtype: 01=ITBIS cobrado por proveedor, 02=ITBIS retenido al proveedor,
    "            03=Proporcionalidad, 04=Capitalizado, 05=Pendiente compensar,
    "            06=Percibido, 07=ISC, 08=Otros
    TYPES: BEGIN OF ty_tax_606,
             taxcode TYPE mwskz,
             indtype TYPE zindtype,
           END OF ty_tax_606.
    DATA mt_tax_606 TYPE HASHED TABLE OF ty_tax_606 WITH UNIQUE KEY taxcode.

    " ── Tipos internos ──────────────────────────────────────────────────────
    TYPES ty_char2 TYPE c LENGTH 2.
    TYPES ty_periodo TYPE c LENGTH 7.
    TYPES ty_casilla TYPE n LENGTH 3.
    TYPES ty_seccion TYPE c LENGTH 60.
    TYPES ty_desc    TYPE c LENGTH 150.
    TYPES ty_op      TYPE c LENGTH 5.
    TYPES ty_monto   TYPE p LENGTH 8 DECIMALS 2.
    TYPES ty_cod_inf TYPE c LENGTH 3.

    TYPES: BEGIN OF ty_it1_row,
             casilla     TYPE ty_casilla,
             periodo     TYPE ty_periodo,
             bukrs       TYPE bukrs,
             seccion     TYPE ty_seccion,
             descripcion TYPE ty_desc,
             operacion   TYPE ty_op,
             monto       TYPE ty_monto,
           END OF ty_it1_row,
           tt_it1_rows TYPE STANDARD TABLE OF ty_it1_row WITH EMPTY KEY.

    TYPES tt_data TYPE STANDARD TABLE OF ztab_it1_data WITH EMPTY KEY.


    TYPES: BEGIN OF ty_anex_a,
             c11_total_607       TYPE p LENGTH 8 DECIMALS 2,
             c38_construccion    TYPE p LENGTH 8 DECIMALS 2,
             c42_comisiones      TYPE p LENGTH 8 DECIMALS 2,
             c33_ret_pago        TYPE p LENGTH 8 DECIMALS 2,
             itbis_compras_loc   TYPE p LENGTH 8 DECIMALS 2,
             itbis_servicios     TYPE p LENGTH 8 DECIMALS 2,
             itbis_importaciones TYPE p LENGTH 8 DECIMALS 2,
           END OF ty_anex_a.

    METHODS:
      inicializar_constantes,
      periodo_a_fechas
        IMPORTING iv_periodo    TYPE ty_periodo
        EXPORTING ev_date_from  TYPE d
                  ev_date_to    TYPE d,
      extraer_datos
        IMPORTING iv_bukrs      TYPE bukrs
                  iv_date_from  TYPE d
                  iv_date_to    TYPE d
        RETURNING VALUE(rt_data) TYPE tt_data,
      derive_tipo_bs
        IMPORTING iv_account    TYPE saknr
        RETURNING VALUE(rv_tipo) TYPE ty_char2,
      calcular_anex_a
        IMPORTING it_data        TYPE tt_data
        RETURNING VALUE(rs_anex) TYPE ty_anex_a,
      add_row
        IMPORTING iv_casilla     TYPE ty_casilla
                  iv_seccion     TYPE ty_seccion
                  iv_desc        TYPE ty_desc
                  iv_op          TYPE ty_op
                  iv_monto       TYPE ty_monto
        CHANGING  ct_res         TYPE tt_it1_rows,
      armar_casillas
        IMPORTING it_data        TYPE tt_data
                  is_anex_a      TYPE ty_anex_a
        RETURNING VALUE(rt_result) TYPE tt_it1_rows.


ENDCLASS.



CLASS ZCL_CE_IT1_QUERY IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    me->inicializar_constantes( ).

    " ── Paging (Fiori siempre manda $top/$skip) ──────────────────────────────
    DATA(lo_paging) = io_request->get_paging( ).
    DATA(lv_skip)   = lo_paging->get_offset( ).
    DATA(lv_top)    = lo_paging->get_page_size( ).

    " ── 1. Leer filtros del Fiori filter bar ────────────────────────────────
    DATA lv_periodo TYPE c LENGTH 7.
    DATA lv_bukrs   TYPE bukrs.

    DATA lt_filters TYPE if_rap_query_filter=>tt_name_range_pairs.
    TRY.
        lt_filters = io_request->get_filter( )->get_as_ranges( ).
      CATCH cx_rap_query_filter_no_range.
        " filtro en formato no soportado — ignorar
    ENDTRY.
    LOOP AT lt_filters ASSIGNING FIELD-SYMBOL(<f>).
      CASE <f>-name.
        WHEN 'PERIODO'.
          IF <f>-range IS NOT INITIAL.
            lv_periodo = <f>-range[ 1 ]-low.
          ENDIF.
        WHEN 'BUKRS'.
          IF <f>-range IS NOT INITIAL.
            lv_bukrs = <f>-range[ 1 ]-low.
          ENDIF.
      ENDCASE.
    ENDLOOP.

    " Sin filtros no hay nada que calcular
    IF lv_periodo IS INITIAL OR lv_bukrs IS INITIAL.
      io_response->set_total_number_of_records( 0 ).
      RETURN.
    ENDIF.

    " ── 2. Convertir período a fechas ───────────────────────────────────────
    DATA lv_date_from TYPE d.
    DATA lv_date_to   TYPE d.
    me->periodo_a_fechas(
      EXPORTING iv_periodo   = lv_periodo
      IMPORTING ev_date_from = lv_date_from
                ev_date_to   = lv_date_to ).

    " ── 3. Extraer datos de CDS Views ───────────────────────────────────────
    DATA(lt_data) = me->extraer_datos(
      iv_bukrs     = lv_bukrs
      iv_date_from = lv_date_from
      iv_date_to   = lv_date_to ).

    " ── 4. Calcular Anexo A internamente ────────────────────────────────────
    DATA(ls_anex_a) = me->calcular_anex_a( lt_data ).

    " ── 5. Armar las 68 casillas ────────────────────────────────────────────
    DATA(lt_result) = me->armar_casillas(
      it_data   = lt_data
      is_anex_a = ls_anex_a ).

    " ── 6. Poblar periodo y bukrs en cada fila (campos del entity) ──────────
    LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<row>).
      <row>-periodo = lv_periodo.
      <row>-bukrs   = lv_bukrs.
    ENDLOOP.

    " ── 7. Respuesta ────────────────────────────────────────────────────────
    io_response->set_total_number_of_records( lines( lt_result ) ).

      " Aplicar paging (skip/top). Si top = 0, devolver todo.
      DATA lt_page TYPE tt_it1_rows.
      IF lv_top > 0.
        lt_page = VALUE #(
          FOR i = lv_skip + 1 THEN i + 1
          UNTIL i > lv_skip + lv_top OR i > lines( lt_result )
          ( lt_result[ i ] ) ).
      ELSE.
        lt_page = lt_result.
      ENDIF.

      io_response->set_data( lt_page ).

  ENDMETHOD.


  METHOD inicializar_constantes.
    " ── Tax codes desde ZTAB_TC ─────────────────────────────────────────────
    SELECT tax_code, itbis_rate FROM ztab_tc
      INTO TABLE @DATA(lt_tc).

    LOOP AT lt_tc ASSIGNING FIELD-SYMBOL(<tc>).
      CASE <tc>-itbis_rate.
        WHEN '18.00'. APPEND VALUE #( sign = 'I' option = 'EQ' low = <tc>-tax_code ) TO mt_tc_18.
        WHEN '16.00'. APPEND VALUE #( sign = 'I' option = 'EQ' low = <tc>-tax_code ) TO mt_tc_16.
        WHEN '0.00'.  APPEND VALUE #( sign = 'I' option = 'EQ' low = <tc>-tax_code ) TO mt_tc_0.
      ENDCASE.
    ENDLOOP.

    " ── Tipos de documento desde ZTAB_DT_MAP ────────────────────────────────
    SELECT doc_type, cod_inf FROM ztab_dt_map
      INTO TABLE @DATA(lt_dt).

    LOOP AT lt_dt ASSIGNING FIELD-SYMBOL(<dt>).
      CASE <dt>-cod_inf.
        WHEN '606'. APPEND VALUE #( sign = 'I' option = 'EQ' low = <dt>-doc_type ) TO mt_doc_606.
        WHEN '607'. APPEND VALUE #( sign = 'I' option = 'EQ' low = <dt>-doc_type ) TO mt_doc_607.
      ENDCASE.
    ENDLOOP.

    " ── Cuentas GL desde ZTAB_CTA_MAP (soporta wildcards: 602*, 219*, etc.) ─
    SELECT * FROM ztab_cta_map INTO TABLE @mt_cta_map.

    LOOP AT mt_cta_map ASSIGNING FIELD-SYMBOL(<cta>).
      CASE <cta>-tipo_ret.
        WHEN '030'.   APPEND VALUE #( sign = 'I' option = 'CP' low = <cta>-account_from ) TO mt_cta_30.
        WHEN '100'.   APPEND VALUE #( sign = 'I' option = 'CP' low = <cta>-account_from ) TO mt_cta_100.
        WHEN 'ITBIS'. APPEND VALUE #( sign = 'I' option = 'CP' low = <cta>-account_from ) TO mt_cta_itbis.
      ENDCASE.
    ENDLOOP.

    " ── Mapeo TaxCode → indtype DGII desde ZTAX_606 ─────────────────────────
    SELECT taxcode, indtype FROM ztax_606
      INTO TABLE @mt_tax_606.

  ENDMETHOD.


  METHOD periodo_a_fechas.
    " iv_periodo formato: 'MM-YYYY'  p.ej. '03-2026'
    DATA(lv_mm)   = iv_periodo(2).
    DATA(lv_yyyy) = iv_periodo+3(4).

    ev_date_from = |{ lv_yyyy }{ lv_mm }01|.

    " Último día: primer día del mes siguiente - 1
    DATA lv_next TYPE d.
    DATA(lv_month) = CONV i( lv_mm ).
    IF lv_month = 12.
      DATA(lv_next_yyyy) = CONV i( lv_yyyy ) + 1.
      lv_next = |{ lv_next_yyyy }0101|.
    ELSE.
      DATA(lv_next_mm) = lv_month + 1.
      lv_next = |{ lv_yyyy }{ lv_next_mm WIDTH = 2 ALIGN = RIGHT PAD = '0' }01|.
    ENDIF.
    ev_date_to = lv_next - 1.
  ENDMETHOD.


  METHOD extraer_datos.

    " ── SELECT desde CDS Views validadas ────────────────────────────────────
    SELECT
        je~AccountingDocument,
        je~FiscalYear,
        je~AccountingDocumentType,
        je~PostingDate,
        je~AccountingDocumentHeaderText  AS ncf_raw,
        jei~GLAccount,
        jei~AmountInCompanyCodeCurrency  AS monto,
        jei~DebitCreditCode,
        jei~TaxCode,
        wt~WhldgTaxAmtInCoCodeCrcy       AS wt_amount,
        wt~WhldgTaxBaseAmtInCoCodeCrcy   AS wt_base
      FROM I_JournalEntry AS je
      INNER JOIN I_JournalEntryItem AS jei
        ON  jei~CompanyCode        = je~CompanyCode
        AND jei~AccountingDocument = je~AccountingDocument
        AND jei~FiscalYear         = je~FiscalYear
        AND jei~Ledger             = '0L'
      LEFT OUTER JOIN I_WithholdingTaxItem AS wt
        ON  wt~CompanyCode         = je~CompanyCode
        AND wt~AccountingDocument  = je~AccountingDocument
        AND wt~FiscalYear          = je~FiscalYear
      WHERE je~CompanyCode  = @iv_bukrs
        AND je~PostingDate BETWEEN @iv_date_from AND @iv_date_to
        AND ( je~AccountingDocumentType IN @mt_doc_606
           OR je~AccountingDocumentType IN @mt_doc_607 )
      INTO TABLE @DATA(lt_raw).

    " ── Acumular por documento (una fila en rt_data por AccountingDocument) ──
    DATA lt_docs TYPE SORTED TABLE OF ztab_it1_data
      WITH UNIQUE KEY documento gjahr.

    LOOP AT lt_raw ASSIGNING FIELD-SYMBOL(<raw>).

      " Ignorar tipos de documento no mapeados
      DATA(lv_cod_inf) = COND ty_cod_inf(
        WHEN <raw>-AccountingDocumentType IN mt_doc_606 THEN '606'
        WHEN <raw>-AccountingDocumentType IN mt_doc_607 THEN '607' ).
      IF lv_cod_inf IS INITIAL. CONTINUE. ENDIF.

      " Buscar o crear fila del documento
      READ TABLE lt_docs ASSIGNING FIELD-SYMBOL(<doc>)
        WITH TABLE KEY documento = <raw>-AccountingDocument
                       gjahr     = <raw>-FiscalYear.
      IF sy-subrc <> 0.
        DATA ls_new TYPE ztab_it1_data.
        ls_new-client    = sy-mandt.
        TRY.
            ls_new-doc_id = cl_system_uuid=>create_uuid_x16_static( ).
        CATCH cx_uuid_error.
            ls_new-doc_id = '0000000000000000'.
        ENDTRY.
        ls_new-bukrs     = iv_bukrs.
        ls_new-documento = <raw>-AccountingDocument.
        ls_new-gjahr     = <raw>-FiscalYear.
        ls_new-cod_inf   = lv_cod_inf.
        ls_new-periodo   = |{ <raw>-PostingDate+4(2) }-{ <raw>-PostingDate(4) }|.
        ls_new-ncf       = <raw>-ncf_raw.
        ls_new-tipo_ncf  = <raw>-ncf_raw+1(2).
        ls_new-tipo_iden = '01'.
        GET TIME STAMP FIELD ls_new-created_at.
        ls_new-created_by = sy-uname.
        INSERT ls_new INTO TABLE lt_docs ASSIGNING <doc>.
      ENDIF.

      " ── Clasificar la línea ─────────────────────────────────────────────
      " 1° por TaxCode → indtype (ZTAX_606)  ← fuente principal
      " 2° fallback por cuenta GL (ZTAB_CTA_MAP.tipo_ret) si no hay TaxCode
      DATA lv_indtype TYPE zindtype.
      CLEAR lv_indtype.
      IF <raw>-TaxCode IS NOT INITIAL.
        READ TABLE mt_tax_606 INTO DATA(ls_tax)
          WITH TABLE KEY taxcode = <raw>-TaxCode.
        IF sy-subrc = 0.
          lv_indtype = ls_tax-indtype.
        ENDIF.
      ENDIF.

      IF lv_indtype = '01'.
        " ITBIS cobrado por el proveedor → crédito fiscal
        <doc>-itbis_fact = <doc>-itbis_fact + ABS( <raw>-monto ).
      ELSEIF lv_indtype = '02'.
        " ITBIS retenido al proveedor
        <doc>-itbis_ret = <doc>-itbis_ret + ABS( <raw>-monto ).
      ELSEIF mt_cta_itbis IS NOT INITIAL AND <raw>-GLAccount IN mt_cta_itbis.
        <doc>-itbis_fact = <doc>-itbis_fact + ABS( <raw>-monto ).
      ELSEIF mt_cta_30 IS NOT INITIAL AND <raw>-GLAccount IN mt_cta_30.
        <doc>-importe_cta_30 = <doc>-importe_cta_30 + ABS( <raw>-monto ).
      ELSEIF mt_cta_100 IS NOT INITIAL AND <raw>-GLAccount IN mt_cta_100.
        <doc>-importe_cta_100 = <doc>-importe_cta_100 + ABS( <raw>-monto ).
      ELSE.
        " Línea de gasto/ingreso — acumula monto y toma tipo_b_s
        <doc>-monto_fact      = <doc>-monto_fact + ABS( <raw>-monto ).
        <doc>-total_facturado = <doc>-total_facturado + ABS( <raw>-monto ).
        IF <doc>-tipo_b_s IS INITIAL.
          <doc>-tipo_b_s = me->derive_tipo_bs( <raw>-GLAccount ).
        ENDIF.
      ENDIF.

      " Retención ISR desde I_WithholdingTaxItem
      IF <raw>-wt_amount IS NOT INITIAL AND <doc>-wt_amount IS INITIAL.
        <doc>-wt_amount = <raw>-wt_amount.
        <doc>-wt_base   = <raw>-wt_base.
      ENDIF.

    ENDLOOP.

    rt_data = lt_docs.

  ENDMETHOD.


  METHOD derive_tipo_bs.
    " Lee tipo_b_s desde ZTAB_CTA_MAP — soporta wildcards (602*, 219*, etc.)
    LOOP AT mt_cta_map ASSIGNING FIELD-SYMBOL(<cta>).
      IF iv_account CP <cta>-account_from
         AND <cta>-tipo_b_s IS NOT INITIAL.
        rv_tipo = <cta>-tipo_b_s.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD calcular_anex_a.

    LOOP AT it_data ASSIGNING FIELD-SYMBOL(<fs>).

      IF <fs>-cod_inf = '607'.
        rs_anex-c11_total_607 = rs_anex-c11_total_607 + <fs>-total_facturado.
      ENDIF.

      IF <fs>-cod_inf = '607' AND ( <fs>-tipo_ncf = '11' OR <fs>-tipo_ncf = '41' ).
        rs_anex-c38_construccion = rs_anex-c38_construccion + <fs>-total_facturado.
      ENDIF.

      IF <fs>-cod_inf = '606' AND <fs>-tipo_b_s = 'CO'.
        rs_anex-c42_comisiones = rs_anex-c42_comisiones + <fs>-total_facturado.
      ENDIF.

      IF <fs>-cod_inf = '606'.
        rs_anex-c33_ret_pago = rs_anex-c33_ret_pago + <fs>-wt_amount.
      ENDIF.

      IF <fs>-cod_inf = '606' AND <fs>-tipo_b_s <> 'S' AND <fs>-tipo_b_s <> 'IM'.
        rs_anex-itbis_compras_loc = rs_anex-itbis_compras_loc + <fs>-itbis_fact.
      ENDIF.

      IF <fs>-cod_inf = '606' AND <fs>-tipo_b_s = 'S'.
        rs_anex-itbis_servicios = rs_anex-itbis_servicios + <fs>-itbis_fact.
      ENDIF.

      IF <fs>-cod_inf = '606' AND <fs>-tipo_b_s = 'IM'.
        rs_anex-itbis_importaciones = rs_anex-itbis_importaciones + <fs>-itbis_fact.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD add_row.
    APPEND VALUE #(
      casilla     = iv_casilla
      seccion     = iv_seccion
      descripcion = iv_desc
      operacion   = iv_op
      monto       = iv_monto
    ) TO ct_res.
  ENDMETHOD.


  METHOD armar_casillas.

    DATA lt_res TYPE tt_it1_rows.

    " ════════════════════════════════════════════════════════
    " SECCIÓN II — INGRESOS POR OPERACIONES
    " ════════════════════════════════════════════════════════

    DATA(c01) = is_anex_a-c11_total_607.
    me->add_row(
      EXPORTING
        iv_casilla = '001'
        iv_seccion = 'II - INGRESOS'
        iv_desc    = 'TOTAL DE OPERACIONES DEL PERIODO (Proviene de la casilla 11 del Anexo A)'
        iv_op      = '+'
        iv_monto   = c01
      CHANGING
        ct_res     = lt_res ).

    DATA(c02) = CONV ty_monto( 0 ).
    me->add_row(
      EXPORTING
        iv_casilla = '002'
        iv_seccion = 'II - INGRESOS'
        iv_desc    = 'INGRESOS POR EXPORTACIONES DE BIENES SEGÚN Art. 342 CT'
        iv_op      = '+'
        iv_monto   = c02
      CHANGING
        ct_res     = lt_res ).

    DATA(c03) = CONV ty_monto( 0 ).
    LOOP AT it_data ASSIGNING FIELD-SYMBOL(<d03>)
      WHERE cod_inf = '607' AND ( tipo_ncf = '16' OR tipo_ncf = '46' ).
      c03 = c03 + <d03>-total_facturado.
    ENDLOOP.
    me->add_row(
      EXPORTING
        iv_casilla = '003'
        iv_seccion = 'II - INGRESOS'
        iv_desc    = 'INGRESOS POR EXPORTACIONES DE SERVICIOS SEGÚN Art. 344 CT y Art. 14 Literal j) Reglamento 293 11'
        iv_op      = '+'
        iv_monto   = c03
      CHANGING
        ct_res     = lt_res ).

    DATA(c04) = CONV ty_monto( 0 ).
    LOOP AT it_data ASSIGNING FIELD-SYMBOL(<d04>) WHERE cod_inf = '607'.
      c04 = c04 + <d04>-base_exenta.
    ENDLOOP.
    me->add_row(
      EXPORTING
        iv_casilla = '004'
        iv_seccion = 'II - INGRESOS'
        iv_desc    = 'INGRESOS POR VENTAS LOCALES DE BIENES O SERVICIOS EXENTOS Art. 343 y Art. 344 CT'
        iv_op      = '+'
        iv_monto   = c04
      CHANGING
        ct_res     = lt_res ).

    DATA(c05) = CONV ty_monto( 0 ).
    me->add_row(
      EXPORTING
        iv_casilla = '005'
        iv_seccion = 'II - INGRESOS'
        iv_desc    = 'INGRESOS POR VENTAS DE BIENES O SERVICIOS EXENTOS POR DESTINO'
        iv_op      = '+'
        iv_monto   = c05
      CHANGING
        ct_res     = lt_res ).

    DATA(c06) = is_anex_a-c38_construccion.
    me->add_row(
      EXPORTING
        iv_casilla = '006'
        iv_seccion = 'II - INGRESOS'
        iv_desc    = 'NO SUJETAS A ITBIS POR SERVICIOS DE CONSTRUCCIÓN (Proviene de la casilla 38 del Anexo A)'
        iv_op      = '+'
        iv_monto   = c06
      CHANGING
        ct_res     = lt_res ).

    DATA(c07) = is_anex_a-c42_comisiones.
    me->add_row(
      EXPORTING
        iv_casilla = '007'
        iv_seccion = 'II - INGRESOS'
        iv_desc    = 'NO SUJETAS A ITBIS POR COMISIONES (Proviene de la casilla 42 del Anexo A)'
        iv_op      = '+'
        iv_monto   = c07
      CHANGING
        ct_res     = lt_res ).

    DATA(c08) = CONV ty_monto( 0 ).
    me->add_row(
      EXPORTING
        iv_casilla = '008'
        iv_seccion = 'II - INGRESOS'
        iv_desc    = 'INGRESOS POR VENTAS LOCALES DE BIENES EXENTOS SEGÚN Párrafos III y IV Art. 343 CT'
        iv_op      = '+'
        iv_monto   = c08
      CHANGING
        ct_res     = lt_res ).

    DATA c09 TYPE ty_monto.
    c09 = c02 + c03 + c04 + c05 + c06 + c07 + c08.
    me->add_row(
      EXPORTING
        iv_casilla = '009'
        iv_seccion = 'II - INGRESOS'
        iv_desc    = 'TOTAL INGRESOS POR OPERACIONES NO GRAVADAS (Sumar casillas 2 3 4 5 6 7 8)'
        iv_op      = '='
        iv_monto   = c09
      CHANGING
        ct_res     = lt_res ).

    DATA c10 TYPE ty_monto.
    c10 = c01 - c09.
    me->add_row(
      EXPORTING
        iv_casilla = '010'
        iv_seccion = 'II - INGRESOS'
        iv_desc    = 'TOTAL INGRESOS POR OPERACIONES GRAVADAS (Restar casillas 1 9)'
        iv_op      = '='
        iv_monto   = c10
      CHANGING
        ct_res     = lt_res ).

    " ════════════════════════════════════════════════════════
    " SECCIÓN II.B — DETALLE DE OPERACIONES GRAVADAS
    " ════════════════════════════════════════════════════════

    DATA(c11) = CONV ty_monto( 0 ).
    LOOP AT it_data ASSIGNING FIELD-SYMBOL(<d11>) WHERE cod_inf = '607'.
      c11 = c11 + <d11>-base_gravada_18.
    ENDLOOP.
    me->add_row(
      EXPORTING
        iv_casilla = '011'
        iv_seccion = 'II.B - GRAVADAS'
        iv_desc    = 'OPERACIONES GRAVADAS AL 18%'
        iv_op      = '='
        iv_monto   = c11
      CHANGING
        ct_res     = lt_res ).

    DATA(c12) = CONV ty_monto( 0 ).
    LOOP AT it_data ASSIGNING FIELD-SYMBOL(<d12>) WHERE cod_inf = '607'.
      c12 = c12 + <d12>-base_gravada_16.
    ENDLOOP.
    me->add_row(
      EXPORTING
        iv_casilla = '012'
        iv_seccion = 'II.B - GRAVADAS'
        iv_desc    = 'OPERACIONES GRAVADAS AL 16%'
        iv_op      = '='
        iv_monto   = c12
      CHANGING
        ct_res     = lt_res ).

    DATA(c13) = CONV ty_monto( 0 ).
    me->add_row(
      EXPORTING
        iv_casilla = '013'
        iv_seccion = 'II.B - GRAVADAS'
        iv_desc    = 'OPERACIONES GRAVADAS AL 9% (Ley No. 690-16)'
        iv_op      = '='
        iv_monto   = c13
      CHANGING
        ct_res     = lt_res ).

    DATA(c14) = CONV ty_monto( 0 ).
    me->add_row(
      EXPORTING
        iv_casilla = '014'
        iv_seccion = 'II.B - GRAVADAS'
        iv_desc    = 'OPERACIONES GRAVADAS AL 8% (Ley No. 690-16)'
        iv_op      = '='
        iv_monto   = c14
      CHANGING
        ct_res     = lt_res ).

    DATA(c15) = CONV ty_monto( 0 ).
    me->add_row(
      EXPORTING
        iv_casilla = '015'
        iv_seccion = 'II.B - GRAVADAS'
        iv_desc    = 'OPERACIONES GRAVADAS POR VENTAS DE ACTIVOS DEPRECIABLES (Categoría 2 y 3)'
        iv_op      = '='
        iv_monto   = c15
      CHANGING
        ct_res     = lt_res ).

    " ════════════════════════════════════════════════════════
    " SECCIÓN III — LIQUIDACIÓN ITBIS
    " ════════════════════════════════════════════════════════

    DATA c16 TYPE ty_monto.
    c16 = c11 * '0.18'.
    me->add_row(
      EXPORTING
        iv_casilla = '016'
        iv_seccion = 'III - LIQUIDACIÓN'
        iv_desc    = 'ITBIS COBRADO (18% de la casilla 11)'
        iv_op      = '+'
        iv_monto   = c16
      CHANGING
        ct_res     = lt_res ).

    DATA c17 TYPE ty_monto.
    c17 = c12 * '0.16'.
    me->add_row(
      EXPORTING
        iv_casilla = '017'
        iv_seccion = 'III - LIQUIDACIÓN'
        iv_desc    = 'ITBIS COBRADO (16% de la casilla 12)'
        iv_op      = '+'
        iv_monto   = c17
      CHANGING
        ct_res     = lt_res ).

    DATA c18 TYPE ty_monto.
    c18 = c13 * '0.09'.
    me->add_row(
      EXPORTING
        iv_casilla = '018'
        iv_seccion = 'III - LIQUIDACIÓN'
        iv_desc    = 'ITBIS COBRADO (9% de la casilla 13) (Ley No. 690-16)'
        iv_op      = '+'
        iv_monto   = c18
      CHANGING
        ct_res     = lt_res ).

    DATA c19 TYPE ty_monto.
    c19 = c14 * '0.08'.
    me->add_row(
      EXPORTING
        iv_casilla = '019'
        iv_seccion = 'III - LIQUIDACIÓN'
        iv_desc    = 'ITBIS COBRADO (8% de la casilla 14) (Ley No. 690-16)'
        iv_op      = '+'
        iv_monto   = c19
      CHANGING
        ct_res     = lt_res ).

    DATA c20 TYPE ty_monto.
    c20 = c15 * '0.18'.
    me->add_row(
      EXPORTING
        iv_casilla = '020'
        iv_seccion = 'III - LIQUIDACIÓN'
        iv_desc    = 'ITBIS COBRADO POR VENTAS DE ACTIVOS DEPRECIABLES (Categoría 2 y 3) (18% de la casilla 15)'
        iv_op      = '+'
        iv_monto   = c20
      CHANGING
        ct_res     = lt_res ).

    DATA c21 TYPE ty_monto.
    c21 = c16 + c17 + c18 + c19 + c20.
    me->add_row(
      EXPORTING
        iv_casilla = '021'
        iv_seccion = 'III - LIQUIDACIÓN'
        iv_desc    = 'TOTAL ITBIS COBRADO (Sumar casillas 16 17 18 19 20)'
        iv_op      = '='
        iv_monto   = c21
      CHANGING
        ct_res     = lt_res ).

    DATA(c22) = is_anex_a-itbis_compras_loc.
    me->add_row(
      EXPORTING
        iv_casilla = '022'
        iv_seccion = 'III - LIQUIDACIÓN'
        iv_desc    = 'ITBIS PAGADO EN COMPRAS LOCALES (Proviene de la casilla 56 del Anexo A)'
        iv_op      = '+'
        iv_monto   = c22
      CHANGING
        ct_res     = lt_res ).

    DATA(c23) = is_anex_a-itbis_servicios.
    me->add_row(
      EXPORTING
        iv_casilla = '023'
        iv_seccion = 'III - LIQUIDACIÓN'
        iv_desc    = 'ITBIS PAGADO POR SERVICIOS DEDUCIBLES (Proviene de la casilla 56 del Anexo A)'
        iv_op      = '+'
        iv_monto   = c23
      CHANGING
        ct_res     = lt_res ).

    DATA(c24) = is_anex_a-itbis_importaciones.
    me->add_row(
      EXPORTING
        iv_casilla = '024'
        iv_seccion = 'III - LIQUIDACIÓN'
        iv_desc    = 'ITBIS PAGADO EN IMPORTACIONES (Proviene de la casilla 56 del Anexo A)'
        iv_op      = '+'
        iv_monto   = c24
      CHANGING
        ct_res     = lt_res ).

    DATA c25 TYPE ty_monto.
    c25 = c22 + c23 + c24.
    me->add_row(
      EXPORTING
        iv_casilla = '025'
        iv_seccion = 'III - LIQUIDACIÓN'
        iv_desc    = 'TOTAL ITBIS DEDUCIBLE (Sumar casillas 22 23 24)'
        iv_op      = '='
        iv_monto   = c25
      CHANGING
        ct_res     = lt_res ).

    DATA c26_raw TYPE ty_monto.
    c26_raw = c21 - c25.

    DATA c26 TYPE ty_monto.
    c26 = COND ty_monto( WHEN c26_raw > 0 THEN c26_raw ELSE 0 ).
    me->add_row(
      EXPORTING
        iv_casilla = '026'
        iv_seccion = 'III - LIQUIDACIÓN'
        iv_desc    = 'IMPUESTO A PAGAR (Si el valor de las casillas 21 25 es Positivo)'
        iv_op      = '='
        iv_monto   = c26
      CHANGING
        ct_res     = lt_res ).

    DATA c27 TYPE ty_monto.
    c27 = COND ty_monto( WHEN c26_raw < 0 THEN ABS( c26_raw ) ELSE 0 ).
    me->add_row(
      EXPORTING
        iv_casilla = '027'
        iv_seccion = 'III - LIQUIDACIÓN'
        iv_desc    = 'SALDO A FAVOR (Si el valor de las casillas 21 25 es Negativo)'
        iv_op      = '='
        iv_monto   = c27
      CHANGING
        ct_res     = lt_res ).

    DATA(c28) = CONV ty_monto( 0 ).
    me->add_row(
      EXPORTING
        iv_casilla = '028'
        iv_seccion = 'III - LIQUIDACIÓN'
        iv_desc    = 'SALDOS COMPENSABLES AUTORIZADOS (Otros Impuestos) Y/O REEMBOLSOS ±'
        iv_op      = '+/-'
        iv_monto   = c28
      CHANGING
        ct_res     = lt_res ).

    DATA(c29) = CONV ty_monto( 0 ).
    me->add_row(
      EXPORTING
        iv_casilla = '029'
        iv_seccion = 'III - LIQUIDACIÓN'
        iv_desc    = 'SALDO A FAVOR ANTERIOR'
        iv_op      = '-'
        iv_monto   = c29
      CHANGING
        ct_res     = lt_res ).

    DATA(c30) = is_anex_a-c33_ret_pago.
    me->add_row(
      EXPORTING
        iv_casilla = '030'
        iv_seccion = 'III - LIQUIDACIÓN'
        iv_desc    = 'TOTAL PAGOS COMPUTABLES POR RETENCIONES (Proviene de la casilla 33 del Anexo A)'
        iv_op      = '-'
        iv_monto   = c30
      CHANGING
        ct_res     = lt_res ).

    DATA(c31) = CONV ty_monto( 0 ).
    me->add_row(
      EXPORTING
        iv_casilla = '031'
        iv_seccion = 'III - LIQUIDACIÓN'
        iv_desc    = 'OTROS PAGOS COMPUTABLES A CUENTA'
        iv_op      = '-'
        iv_monto   = c31
      CHANGING
        ct_res     = lt_res ).

    DATA(c32) = CONV ty_monto( 0 ).
    me->add_row(
      EXPORTING
        iv_casilla = '032'
        iv_seccion = 'III - LIQUIDACIÓN'
        iv_desc    = 'COMPENSACIONES Y/O REEMBOLSOS AUTORIZADOS'
        iv_op      = '+'
        iv_monto   = c32
      CHANGING
        ct_res     = lt_res ).

    DATA c33_raw TYPE ty_monto.
    c33_raw = c26 + c28 - c29 - c30 - c31 + c32.
    DATA c33 TYPE ty_monto.
    c33 = COND ty_monto( WHEN c33_raw > 0 THEN c33_raw ELSE 0 ).
    me->add_row(
      EXPORTING
        iv_casilla = '033'
        iv_seccion = 'III - LIQUIDACIÓN'
        iv_desc    = 'DIFERENCIA A PAGAR (Si el valor de las casillas 26 28 29 30 31 32 es Positivo)'
        iv_op      = '='
        iv_monto   = c33
      CHANGING
        ct_res     = lt_res ).

    DATA c34 TYPE ty_monto.
    c34 = COND ty_monto(
      WHEN c33_raw < 0 THEN ABS( c33_raw )
      WHEN c27 > 0     THEN c27 + c28 - c29 - c30 - c31 + c32
      ELSE 0 ).
    IF c34 < 0. c34 = 0. ENDIF.
    me->add_row(
      EXPORTING
        iv_casilla = '034'
        iv_seccion = 'III - LIQUIDACIÓN'
        iv_desc    = 'NUEVO SALDO A FAVOR (Si el valor de las casillas (26 28 29 30 31 32 es Negativo) ó (27 28 29 30 31 32))'
        iv_op      = '='
        iv_monto   = c34
      CHANGING
        ct_res     = lt_res ).

    DATA(c35) = CONV ty_monto( 0 ).
    me->add_row(
      EXPORTING
        iv_casilla = '035'
        iv_seccion = 'III - LIQUIDACIÓN'
        iv_desc    = 'RECARGOS'
        iv_op      = '+'
        iv_monto   = c35
      CHANGING
        ct_res     = lt_res ).

    DATA(c36) = CONV ty_monto( 0 ).
    me->add_row(
      EXPORTING
        iv_casilla = '036'
        iv_seccion = 'III - LIQUIDACIÓN'
        iv_desc    = 'INTERÉS INDEMNIZATORIO'
        iv_op      = '+'
        iv_monto   = c36
      CHANGING
        ct_res     = lt_res ).

    DATA(c37) = CONV ty_monto( 0 ).
    me->add_row(
      EXPORTING
        iv_casilla = '037'
        iv_seccion = 'III - LIQUIDACIÓN'
        iv_desc    = 'SANCIONES'
        iv_op      = '+'
        iv_monto   = c37
      CHANGING
        ct_res     = lt_res ).

    DATA c38 TYPE ty_monto.
    c38 = c33 + c35 + c36 + c37.
    me->add_row(
      EXPORTING
        iv_casilla = '038'
        iv_seccion = 'III - LIQUIDACIÓN'
        iv_desc    = 'TOTAL A PAGAR (Sumar casillas 33 35 36 37)'
        iv_op      = '='
        iv_monto   = c38
      CHANGING
        ct_res     = lt_res ).

    " ════════════════════════════════════════════════════════
    " SECCIÓN IV — RETENCIONES ITBIS
    " ════════════════════════════════════════════════════════

    DATA(c39) = CONV ty_monto( 0 ).
    LOOP AT it_data ASSIGNING FIELD-SYMBOL(<d39>)
      WHERE cod_inf = '606' AND tipo_iden = '02'.
      c39 = c39 + <d39>-total_facturado.
    ENDLOOP.
    me->add_row(
      EXPORTING
        iv_casilla = '039'
        iv_seccion = 'IV - RETENCIONES'
        iv_desc    = 'SERVICIOS SUJETOS A RETENCIÓN PERSONAS FÍSICAS'
        iv_op      = '+'
        iv_monto   = c39
      CHANGING
        ct_res     = lt_res ).

    DATA(c40) = CONV ty_monto( 0 ).
    LOOP AT it_data ASSIGNING FIELD-SYMBOL(<d40>)
      WHERE cod_inf = '607' AND tipo_ret = '02'.
      c40 = c40 + <d40>-total_facturado.
    ENDLOOP.
    me->add_row(
      EXPORTING
        iv_casilla = '040'
        iv_seccion = 'IV - RETENCIONES'
        iv_desc    = 'SERVICIOS SUJETOS A RETENCIÓN ENTIDADES NO LUCRATIVAS (Norma No. 01-11)'
        iv_op      = '+'
        iv_monto   = c40
      CHANGING
        ct_res     = lt_res ).

    DATA c41 TYPE ty_monto.
    c41 = c39 + c40.
    me->add_row(
      EXPORTING
        iv_casilla = '041'
        iv_seccion = 'IV - RETENCIONES'
        iv_desc    = 'TOTAL SERVICIOS SUJETOS A RETENCIÓN A PERSONAS FÍSICAS Y ENTIDADES NO LUCRATIVAS'
        iv_op      = '='
        iv_monto   = c41
      CHANGING
        ct_res     = lt_res ).

    DATA(c42) = CONV ty_monto( 0 ).
    LOOP AT it_data ASSIGNING FIELD-SYMBOL(<d42>)
      WHERE cod_inf = '606' AND tipo_iden = '01'.
      c42 = c42 + <d42>-importe_cta_100.
    ENDLOOP.
    me->add_row(
      EXPORTING
        iv_casilla = '042'
        iv_seccion = 'IV - RETENCIONES'
        iv_desc    = 'SERVICIOS SUJETOS A RETENCIÓN SOCIEDADES (Norma No. 07-09)'
        iv_op      = '='
        iv_monto   = c42
      CHANGING
        ct_res     = lt_res ).

    DATA(c43) = CONV ty_monto( 0 ).
    LOOP AT it_data ASSIGNING FIELD-SYMBOL(<d43>)
      WHERE cod_inf = '606' AND tipo_iden = '01'.
      c43 = c43 + <d43>-importe_cta_30.
    ENDLOOP.
    me->add_row(
      EXPORTING
        iv_casilla = '043'
        iv_seccion = 'IV - RETENCIONES'
        iv_desc    = 'SERVICIOS SUJETOS A RETENCIÓN SOCIEDADES (Norma No. 02 05 y 07-07)'
        iv_op      = '='
        iv_monto   = c43
      CHANGING
        ct_res     = lt_res ).

    DATA(c44) = CONV ty_monto( 0 ).
    LOOP AT it_data ASSIGNING FIELD-SYMBOL(<d44>)
      WHERE cod_inf = '606' AND ( tipo_ncf = '14' OR tipo_ncf = '44' ).
      c44 = c44 + <d44>-base_gravada_18.
    ENDLOOP.
    me->add_row(
      EXPORTING
        iv_casilla = '044'
        iv_seccion = 'IV - RETENCIONES'
        iv_desc    = 'BIENES O SERVICIOS SUJETOS A RETENCIÓN A CONTRIBUYENTES ACOGIDOS AL RST (Operaciones Gravadas al 18%)'
        iv_op      = '+'
        iv_monto   = c44
      CHANGING
        ct_res     = lt_res ).

    DATA(c45) = CONV ty_monto( 0 ).
    LOOP AT it_data ASSIGNING FIELD-SYMBOL(<d45>)
      WHERE cod_inf = '606' AND ( tipo_ncf = '14' OR tipo_ncf = '44' ).
      c45 = c45 + <d45>-base_gravada_16.
    ENDLOOP.
    me->add_row(
      EXPORTING
        iv_casilla = '045'
        iv_seccion = 'IV - RETENCIONES'
        iv_desc    = 'BIENES O SERVICIOS SUJETOS A RETENCIÓN A CONTRIBUYENTES ACOGIDOS AL RST (Operaciones Gravadas al 16%)'
        iv_op      = '+'
        iv_monto   = c45
      CHANGING
        ct_res     = lt_res ).

    DATA c46 TYPE ty_monto.
    c46 = c44 + c45.
    me->add_row(
      EXPORTING
        iv_casilla = '046'
        iv_seccion = 'IV - RETENCIONES'
        iv_desc    = 'TOTAL BIENES O SERVICIOS SUJETOS A RETENCIÓN A CONTRIBUYENTES ACOGIDOS AL RST (Sumar casillas 44 45)'
        iv_op      = '='
        iv_monto   = c46
      CHANGING
        ct_res     = lt_res ).

    DATA(c47) = CONV ty_monto( 0 ).
    LOOP AT it_data ASSIGNING FIELD-SYMBOL(<d47>)
      WHERE cod_inf = '606' AND ( tipo_ncf = '11' OR tipo_ncf = '41' ).
      c47 = c47 + <d47>-base_gravada_18.
    ENDLOOP.
    me->add_row(
      EXPORTING
        iv_casilla = '047'
        iv_seccion = 'IV - RETENCIONES'
        iv_desc    = 'BIENES SUJETOS A RETENCIÓN PROVEEDORES INFORMALES (Operaciones Gravadas al 18%) (Norma No. 08-10)'
        iv_op      = '+'
        iv_monto   = c47
      CHANGING
        ct_res     = lt_res ).

    DATA(c48) = CONV ty_monto( 0 ).
    LOOP AT it_data ASSIGNING FIELD-SYMBOL(<d48>)
      WHERE cod_inf = '606' AND ( tipo_ncf = '11' OR tipo_ncf = '41' ).
      c48 = c48 + <d48>-base_gravada_16.
    ENDLOOP.
    me->add_row(
      EXPORTING
        iv_casilla = '048'
        iv_seccion = 'IV - RETENCIONES'
        iv_desc    = 'BIENES SUJETOS A RETENCIÓN PROVEEDORES INFORMALES (Operaciones Gravadas al 16%) (Norma No. 08-10)'
        iv_op      = '+'
        iv_monto   = c48
      CHANGING
        ct_res     = lt_res ).

    DATA c49 TYPE ty_monto.
    c49 = c47 + c48.
    me->add_row(
      EXPORTING
        iv_casilla = '049'
        iv_seccion = 'IV - RETENCIONES'
        iv_desc    = 'TOTAL BIENES SUJETOS A RETENCIÓN PROVEEDORES INFORMALES (Norma No. 08-10) (Sumar casillas 47 48)'
        iv_op      = '='
        iv_monto   = c49
      CHANGING
        ct_res     = lt_res ).

    DATA c50 TYPE ty_monto.
    c50 = c41 * '0.18'.
    me->add_row(
      EXPORTING
        iv_casilla = '050'
        iv_seccion = 'IV - RETENCIONES'
        iv_desc    = 'ITBIS POR SERVICIOS SUJETOS A RETENCIÓN PERSONAS FÍSICAS Y ENTIDADES NO LUCRATIVAS (18% de la casilla 41)'
        iv_op      = '+'
        iv_monto   = c50
      CHANGING
        ct_res     = lt_res ).

    DATA c51 TYPE ty_monto.
    c51 = c42 * '0.18'.
    me->add_row(
      EXPORTING
        iv_casilla = '051'
        iv_seccion = 'IV - RETENCIONES'
        iv_desc    = 'ITBIS POR SERVICIOS SUJETOS A RETENCIÓN SOCIEDADES (18% de la casilla 42) (Norma No. 07-09)'
        iv_op      = '+'
        iv_monto   = c51
      CHANGING
        ct_res     = lt_res ).

    DATA c52 TYPE ty_monto.
    c52 = c43 * '0.18' * '0.30'.
    me->add_row(
      EXPORTING
        iv_casilla = '052'
        iv_seccion = 'IV - RETENCIONES'
        iv_desc    = 'ITBIS POR SERVICIOS SUJETOS A RETENCIÓN SOCIEDADES (18% de la casilla 43 por 0.30) (Norma No. 02 05 y 07-07)'
        iv_op      = '+'
        iv_monto   = c52
      CHANGING
        ct_res     = lt_res ).

    DATA c53 TYPE ty_monto.
    c53 = c44 * '0.18'.
    me->add_row(
      EXPORTING
        iv_casilla = '053'
        iv_seccion = 'IV - RETENCIONES'
        iv_desc    = 'ITBIS RETENIDO A CONTRIBUYENTES ACOGIDOS AL RST (18% de la casilla 44)'
        iv_op      = '+'
        iv_monto   = c53
      CHANGING
        ct_res     = lt_res ).

    DATA c54 TYPE ty_monto.
    c54 = c45 * '0.16'.
    me->add_row(
      EXPORTING
        iv_casilla = '054'
        iv_seccion = 'IV - RETENCIONES'
        iv_desc    = 'ITBIS RETENIDO A CONTRIBUYENTES ACOGIDOS AL RST (16% de la casilla 45)'
        iv_op      = '+'
        iv_monto   = c54
      CHANGING
        ct_res     = lt_res ).

    DATA c55 TYPE ty_monto.
    c55 = c53 + c54.
    me->add_row(
      EXPORTING
        iv_casilla = '055'
        iv_seccion = 'IV - RETENCIONES'
        iv_desc    = 'TOTAL ITBIS RETENIDO A CONTRIBUYENTES ACOGIDOS AL RST (Sumar casillas 53 54)'
        iv_op      = '='
        iv_monto   = c55
      CHANGING
        ct_res     = lt_res ).

    DATA c56 TYPE ty_monto.
    c56 = c47 * '0.18' * '0.75'.
    me->add_row(
      EXPORTING
        iv_casilla = '056'
        iv_seccion = 'IV - RETENCIONES'
        iv_desc    = 'ITBIS POR BIENES SUJETOS A RETENCIÓN PROVEEDORES INFORMALES (18% de la casilla 47 por 0.75) (Norma No. 08-10)'
        iv_op      = '+'
        iv_monto   = c56
      CHANGING
        ct_res     = lt_res ).

    DATA c57 TYPE ty_monto.
    c57 = c48 * '0.16' * '0.75'.
    me->add_row(
      EXPORTING
        iv_casilla = '057'
        iv_seccion = 'IV - RETENCIONES'
        iv_desc    = 'ITBIS POR BIENES SUJETOS A RETENCIÓN PROVEEDORES INFORMALES (16% de la casilla 48 por 0.75) (Norma No. 08-10)'
        iv_op      = '+'
        iv_monto   = c57
      CHANGING
        ct_res     = lt_res ).

    DATA c58 TYPE ty_monto.
    c58 = c56 + c57.
    me->add_row(
      EXPORTING
        iv_casilla = '058'
        iv_seccion = 'IV - RETENCIONES'
        iv_desc    = 'TOTAL POR BIENES SUJETOS A RETENCIÓN PROVEEDORES INFORMALES (Sumar casillas 56 57)'
        iv_op      = '='
        iv_monto   = c58
      CHANGING
        ct_res     = lt_res ).

    DATA(c59) = CONV ty_monto( 0 ).
    me->add_row(
      EXPORTING
        iv_casilla = '059'
        iv_seccion = 'IV - RETENCIONES'
        iv_desc    = 'TOTAL ITBIS PERCIBIDO EN VENTA'
        iv_op      = '='
        iv_monto   = c59
      CHANGING
        ct_res     = lt_res ).

    DATA c60 TYPE ty_monto.
    c60 = c50 + c51 + c52 + c55 + c58 + c59.
    me->add_row(
      EXPORTING
        iv_casilla = '060'
        iv_seccion = 'IV - RETENCIONES'
        iv_desc    = 'IMPUESTO A PAGAR (Sumar casillas 50 51 52 55 58 59)'
        iv_op      = '='
        iv_monto   = c60
      CHANGING
        ct_res     = lt_res ).

    DATA(c61) = CONV ty_monto( 0 ).
    me->add_row(
      EXPORTING
        iv_casilla = '061'
        iv_seccion = 'IV - RETENCIONES'
        iv_desc    = 'PAGOS COMPUTABLES A CUENTA'
        iv_op      = '-'
        iv_monto   = c61
      CHANGING
        ct_res     = lt_res ).

    DATA c62_raw TYPE ty_monto.
    c62_raw = c60 - c61.
    DATA c62 TYPE ty_monto.
    c62 = COND ty_monto( WHEN c62_raw > 0 THEN c62_raw ELSE 0 ).
    me->add_row(
      EXPORTING
        iv_casilla = '062'
        iv_seccion = 'IV - RETENCIONES'
        iv_desc    = 'DIFERENCIA A PAGAR (Si el valor de las casillas 60 61 es Positivo)'
        iv_op      = '='
        iv_monto   = c62
      CHANGING
        ct_res     = lt_res ).

    DATA c63 TYPE ty_monto.
    c63 = COND ty_monto( WHEN c62_raw < 0 THEN ABS( c62_raw ) ELSE 0 ).
    me->add_row(
      EXPORTING
        iv_casilla = '063'
        iv_seccion = 'IV - RETENCIONES'
        iv_desc    = 'NUEVO SALDO A FAVOR (Si el valor de las casillas 60 61 es Negativo)'
        iv_op      = '='
        iv_monto   = c63
      CHANGING
        ct_res     = lt_res ).

    DATA(c64) = CONV ty_monto( 0 ).
    me->add_row(
      EXPORTING
        iv_casilla = '064'
        iv_seccion = 'IV - RETENCIONES'
        iv_desc    = 'RECARGOS'
        iv_op      = '+'
        iv_monto   = c64
      CHANGING
        ct_res     = lt_res ).

    DATA(c65) = CONV ty_monto( 0 ).
    me->add_row(
      EXPORTING
        iv_casilla = '065'
        iv_seccion = 'IV - RETENCIONES'
        iv_desc    = 'INTERÉS INDEMNIZATORIO'
        iv_op      = '+'
        iv_monto   = c65
      CHANGING
        ct_res     = lt_res ).

    DATA(c66) = CONV ty_monto( 0 ).
    me->add_row(
      EXPORTING
        iv_casilla = '066'
        iv_seccion = 'IV - RETENCIONES'
        iv_desc    = 'SANCIONES'
        iv_op      = '+'
        iv_monto   = c66
      CHANGING
        ct_res     = lt_res ).

    DATA c67 TYPE ty_monto.
    c67 = c62 + c64 + c65 + c66.
    me->add_row(
      EXPORTING
        iv_casilla = '067'
        iv_seccion = 'IV - RETENCIONES'
        iv_desc    = 'TOTAL A PAGAR (Sumar casillas 62 64 65 66)'
        iv_op      = '='
        iv_monto   = c67
      CHANGING
        ct_res     = lt_res ).

    DATA c68 TYPE ty_monto.
    c68 = c38 + c67.
    me->add_row(
      EXPORTING
        iv_casilla = '068'
        iv_seccion = 'TOTAL GENERAL'
        iv_desc    = 'TOTAL GENERAL (Sumar casillas 38 67)'
        iv_op      = '='
        iv_monto   = c68
      CHANGING
        ct_res     = lt_res ).

    rt_result = lt_res.
  ENDMETHOD.
ENDCLASS.
