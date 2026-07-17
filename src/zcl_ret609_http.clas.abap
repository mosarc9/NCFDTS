CLASS zcl_ret609_http DEFINITION
  PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_http_service_extension.
ENDCLASS.



CLASS ZCL_RET609_HTTP IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.

    DATA lv_poper TYPE n LENGTH 3.

    DATA(lv_bukrs) = request->get_form_field( 'bukrs' ).
    DATA(lv_gjahr) = CONV gjahr( request->get_form_field( 'gjahr' ) ).
    lv_poper = request->get_form_field( 'poper' ).

    " ── RNC de la empresa ─────────────────────────────────────────────────
    DATA lv_rnc TYPE stceg.
    SELECT SINGLE VATRegistration
      FROM I_CompanyCode
      WHERE CompanyCode = @lv_bukrs
      INTO @lv_rnc.

    " ── Retenciones del período ───────────────────────────────────────────
    SELECT wt~CompanyCode,
           wt~AccountingDocument,
           wt~FiscalYear,
           wt~CustomerSupplierAccount AS Supplier,
           wt~WithholdingTaxType,
           wt~WithholdingTaxCode,
           wt~WhldgTaxBaseAmtInCoCodeCrcy AS BaseAmount,
           wt~WhldgTaxAmtInCoCodeCrcy     AS TaxAmount,
           je~AccountingDocumentHeaderText AS Ncf,
           je~DocumentDate,
           je~PostingDate,
           je~FiscalPeriod
      FROM I_WithholdingTaxItem AS wt
      INNER JOIN I_JournalEntry AS je
        ON  wt~CompanyCode        = je~CompanyCode
        AND wt~AccountingDocument = je~AccountingDocument
        AND wt~FiscalYear         = je~FiscalYear
      WHERE wt~CompanyCode  = @lv_bukrs
        AND wt~FiscalYear   = @lv_gjahr
        AND je~FiscalPeriod = @lv_poper
      INTO TABLE @DATA(lt_wt).

    " ── Agrupar / Pivot ───────────────────────────────────────────────────
    TYPES: BEGIN OF ty_line,
             supplier            TYPE lifnr,
             accounting_document TYPE belnr_d,
             ncf                 TYPE stceg,
             fecha_factura       TYPE d,
             fecha_retencion     TYPE d,
             monto_factura       TYPE p LENGTH 9 DECIMALS 2,
             itbis_retenido      TYPE p LENGTH 9 DECIMALS 2,
             isr_retenido        TYPE p LENGTH 9 DECIMALS 2,
             whtax_code_isr      TYPE c LENGTH 4,
           END OF ty_line.
    DATA lt_lines TYPE TABLE OF ty_line.

    LOOP AT lt_wt INTO DATA(wa_wt).
      READ TABLE lt_lines ASSIGNING FIELD-SYMBOL(<ln>)
        WITH KEY accounting_document = wa_wt-AccountingDocument
                 supplier            = wa_wt-Supplier.
      IF sy-subrc <> 0.
        APPEND INITIAL LINE TO lt_lines ASSIGNING <ln>.
        <ln>-supplier            = wa_wt-Supplier.
        <ln>-accounting_document = wa_wt-AccountingDocument.
        <ln>-ncf                 = wa_wt-Ncf.
        <ln>-fecha_factura       = wa_wt-DocumentDate.
        <ln>-fecha_retencion     = wa_wt-PostingDate.
        <ln>-monto_factura       = ABS( wa_wt-BaseAmount ).
      ENDIF.
      CASE wa_wt-WithholdingTaxType.
        WHEN 'IB'.
          <ln>-itbis_retenido = <ln>-itbis_retenido + ABS( wa_wt-TaxAmount ).
        WHEN 'IS'.
          <ln>-isr_retenido   = <ln>-isr_retenido + ABS( wa_wt-TaxAmount ).
          IF <ln>-whtax_code_isr IS INITIAL.
            <ln>-whtax_code_isr = wa_wt-WithholdingTaxCode.
          ENDIF.
      ENDCASE.
    ENDLOOP.

    " ── Construir TXT ─────────────────────────────────────────────────────
    DATA(lv_periodo_yyyymm) = |{ lv_gjahr }{ lv_poper+1(2) }|.  " ej: 202501

    DATA lv_content TYPE string.
    DATA(lv_count) = lines( lt_lines ).

    " Cabecera
    lv_content = |609\|{ lv_rnc }\|{ lv_periodo_yyyymm }\|{ lv_count }| && cl_abap_char_utilities=>cr_lf.

    " Detalle
    LOOP AT lt_lines INTO DATA(wa_ln).

      SELECT SINGLE SupplierName, TaxNumber1, Country
        FROM I_Supplier
        WHERE Supplier = @wa_ln-supplier
        INTO @DATA(ls_sup).

      DATA lv_tipo_id  TYPE c LENGTH 1.
      DATA lv_pais     TYPE c LENGTH 3.
      DATA lv_tipo_serv TYPE c LENGTH 2.

      IF strlen( ls_sup-TaxNumber1 ) <= 9.
        lv_tipo_id = '1'.
      ELSE.
        lv_tipo_id = '2'.
      ENDIF.

      CASE ls_sup-Country.
        WHEN 'DO'. lv_pais = '214'.
        WHEN 'CO'. lv_pais = '170'.
        WHEN 'US'. lv_pais = '840'.
        WHEN 'PA'. lv_pais = '591'.
        WHEN 'MX'. lv_pais = '484'.
        WHEN 'VE'. lv_pais = '862'.
        WHEN OTHERS. lv_pais = '214'.
     ENDCASE.

    CASE wa_ln-whtax_code_isr.
      WHEN 'S1'. lv_tipo_serv = '05'.
      WHEN 'S2'. lv_tipo_serv = '02'.
      WHEN 'S3'. lv_tipo_serv = '03'.
      WHEN 'S4'. lv_tipo_serv = '06'.
      WHEN OTHERS. lv_tipo_serv = '05'.
    ENDCASE.

      DATA(lv_fecha_fac) = |{ wa_ln-fecha_factura+0(4) }{ wa_ln-fecha_factura+4(2) }{ wa_ln-fecha_factura+6(2) }|.
      DATA(lv_fecha_ret) = |{ wa_ln-fecha_retencion+0(4) }{ wa_ln-fecha_retencion+4(2) }{ wa_ln-fecha_retencion+6(2) }|.
      DATA(lv_monto) = |{ wa_ln-monto_factura DECIMALS = 2 }|.
      DATA(lv_isr)   = |{ wa_ln-isr_retenido  DECIMALS = 2 }|.

      lv_content = lv_content &&
          ls_sup-SupplierName && '|' &&
          lv_tipo_id          && '|' &&
          ls_sup-TaxNumber1   && '|' &&
          lv_pais             && '|' &&
          lv_tipo_serv        && '|51|0|' &&
          wa_ln-ncf           && '|' &&
          lv_fecha_fac        && '|' &&
          lv_monto            && '|' &&
          lv_fecha_ret        && '|' &&
          lv_monto            && '|' &&
          lv_isr              &&
          cl_abap_char_utilities=>cr_lf.

    ENDLOOP.

    " ── Respuesta HTTP ────────────────────────────────────────────────────
    DATA(lv_filename) = |Reporte_609_{ lv_gjahr }{ lv_poper }.txt|.
    DATA(lv_xdata) = cl_abap_conv_codepage=>create_out( codepage = 'UTF-8' )->convert( lv_content ).

    response->set_header_field(
      i_name  = 'Content-Disposition'
      i_value = |attachment; filename="{ lv_filename }"|
    ).
    response->set_header_field(
      i_name  = 'Content-Type'
      i_value = 'text/plain; charset=UTF-8'
    ).
    response->set_binary( lv_xdata ).
    response->set_status( i_code = 200 i_reason = 'OK' ).

  ENDMETHOD.
ENDCLASS.
