CLASS zcl_ret609_query DEFINITION
  PUBLIC FINAL CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
ENDCLASS.



CLASS ZCL_RET609_QUERY IMPLEMENTATION.


    METHOD if_rap_query_provider~select.

        DATA lt_ranges TYPE if_rap_query_filter=>tt_name_range_pairs.
        DATA lv_bukrs  TYPE bukrs.
        DATA lv_gjahr  TYPE gjahr.
        DATA lv_poper  TYPE  n LENGTH 3.

        TRY.
            lt_ranges = io_request->get_filter( )->get_as_ranges( ).
          CATCH cx_rap_query_filter_no_range.
        ENDTRY.

        LOOP AT lt_ranges INTO DATA(filter).
          CASE filter-name.
            WHEN 'BUKRS'.
              READ TABLE filter-range INTO DATA(r_bukrs) INDEX 1.
              IF sy-subrc = 0. lv_bukrs = r_bukrs-low. ENDIF.
            WHEN 'GJAHR'.
              READ TABLE filter-range INTO DATA(r_gjahr) INDEX 1.
              IF sy-subrc = 0. lv_gjahr = r_gjahr-low. ENDIF.
            WHEN 'POPER'.
              READ TABLE filter-range INTO DATA(r_poper) INDEX 1.
              IF sy-subrc = 0. lv_poper = r_poper-low. ENDIF.
          ENDCASE.
        ENDLOOP.

        " URL del HTTP handler (igual para todos los registros del período)
        DATA(lv_url) = |/sap/bc/http/sap/zret609_http| &&
                       |?bukrs={ lv_bukrs }| &&
                       |&gjahr={ lv_gjahr }| &&
                       |&poper={ lv_poper }|.

        " ── SELECT principal: retenciones del período ─────────────────────────
        SELECT wt~CompanyCode,
               wt~AccountingDocument,
               wt~FiscalYear,
               wt~CustomerSupplierAccount  AS Supplier,
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
          WHERE wt~CompanyCode = @lv_bukrs
            AND wt~FiscalYear  = @lv_gjahr
            AND je~FiscalPeriod = @lv_poper
          INTO TABLE @DATA(lt_wt).

        " ── Agrupar por documento + proveedor, pivotear ISR / ITBIS ───────────
        TYPES: BEGIN OF ty_result,
                 bukrs               TYPE bukrs,
                 gjahr               TYPE gjahr,
                 poper               TYPE n LENGTH 3,
                 accounting_document TYPE belnr_d,
                 supplier            TYPE lifnr,
                 ncf                 TYPE stceg,
                 fecha_factura       TYPE d,
                 fecha_retencion     TYPE d,
                 monto_factura       TYPE p LENGTH 9 DECIMALS 2,
                 itbis_retenido      TYPE p LENGTH 9 DECIMALS 2,
                 isr_retenido        TYPE p LENGTH 9 DECIMALS 2,
                 whtax_code_isr      TYPE c LENGTH 4,
               END OF ty_result.

        DATA lt_grouped TYPE TABLE OF ty_result.

        LOOP AT lt_wt INTO DATA(wa_wt).
          " Buscar fila existente para este documento+proveedor
          READ TABLE lt_grouped ASSIGNING FIELD-SYMBOL(<grp>)
            WITH KEY accounting_document = wa_wt-AccountingDocument
                     supplier            = wa_wt-Supplier.

          IF sy-subrc <> 0.
            " Nueva fila
            APPEND INITIAL LINE TO lt_grouped ASSIGNING <grp>.
            <grp>-bukrs               = wa_wt-CompanyCode.
            <grp>-gjahr               = wa_wt-FiscalYear.
            <grp>-poper               = wa_wt-FiscalPeriod.
            <grp>-accounting_document = wa_wt-AccountingDocument.
            <grp>-supplier            = wa_wt-Supplier.
            <grp>-ncf                 = wa_wt-Ncf.
            <grp>-fecha_factura       = wa_wt-DocumentDate.
            <grp>-fecha_retencion     = wa_wt-PostingDate.
            <grp>-monto_factura       = ABS( wa_wt-BaseAmount ).
          ENDIF.

          " Acumular por tipo
          CASE wa_wt-WithholdingTaxType.
            WHEN 'IB'.
              <grp>-itbis_retenido = <grp>-itbis_retenido + ABS( wa_wt-TaxAmount ).
            WHEN 'IS'.
              <grp>-isr_retenido   = <grp>-isr_retenido + ABS( wa_wt-TaxAmount ).
              IF <grp>-whtax_code_isr IS INITIAL.
                <grp>-whtax_code_isr = wa_wt-WithholdingTaxCode.
              ENDIF.
          ENDCASE.
        ENDLOOP.

        " ── Enriquecer con datos del proveedor ────────────────────────────────
        DATA lt_result TYPE TABLE OF zce_ret609.

        LOOP AT lt_grouped INTO DATA(wa_grp).

          SELECT SINGLE Supplier, SupplierName, TaxNumber1, Country
            FROM I_Supplier
            WHERE Supplier = @wa_grp-supplier
            INTO @DATA(ls_sup).

          " Tipo ID
          DATA lv_tipo_id TYPE c LENGTH 1.

          IF strlen( ls_sup-TaxNumber1 ) <= 9.
            lv_tipo_id = '1'.
          ELSE.
            lv_tipo_id = '2'.
          ENDIF.

          " País código DGII
          DATA lv_country_dgii TYPE c LENGTH 3.

          CASE ls_sup-Country.
            WHEN 'DO'.
              lv_country_dgii = '214'.
            WHEN 'CO'.
              lv_country_dgii = '170'.
            WHEN 'US'.
              lv_country_dgii = '840'.
            WHEN 'PA'.
              lv_country_dgii = '591'.
            WHEN 'MX'.
              lv_country_dgii = '484'.
            WHEN 'VE'.
              lv_country_dgii = '862'.
            WHEN OTHERS.
              lv_country_dgii = '214'.
            ENDCASE.

          " Tipo de servicio (del código ISR)
          DATA lv_tipo_serv TYPE c LENGTH 2.

          CASE wa_grp-whtax_code_isr.
            WHEN 'S1'.
                lv_tipo_serv = '05'.
            WHEN 'S2'.
                lv_tipo_serv = '02'.
            WHEN 'S3'.
                lv_tipo_serv = '03'.
            WHEN 'S4'.
                lv_tipo_serv = '06'.
            WHEN OTHERS.
                lv_tipo_serv = '05'.
          ENDCASE.


          APPEND VALUE zce_ret609(
            url_text            = 'Descargar 609'
            url_descarga        = lv_url
            bukrs               = wa_grp-bukrs
            gjahr               = wa_grp-gjahr
            poper               = wa_grp-poper
            accounting_document = wa_grp-accounting_document
            supplier            = wa_grp-supplier
            supplier_name       = ls_sup-SupplierName
            tax_number          = ls_sup-TaxNumber1
            tipo_id             = lv_tipo_id
            country_dgii        = lv_country_dgii
            ncf                 = wa_grp-ncf
            fecha_factura       = wa_grp-fecha_factura
            fecha_retencion     = wa_grp-fecha_retencion
            monto_factura       = wa_grp-monto_factura
            itbis_retenido      = wa_grp-itbis_retenido
            isr_retenido        = wa_grp-isr_retenido
            tipo_servicio       = lv_tipo_serv
            whtax_code_isr      = wa_grp-whtax_code_isr
            renta_presunta      = wa_grp-monto_factura
          ) TO lt_result.

        ENDLOOP.

        " ── Paginación (requerida por el framework) ───────────────────────
        DATA(lo_paging)    = io_request->get_paging( ).
        DATA(lv_offset)    = lo_paging->get_offset( ).
        DATA(lv_page_size) = lo_paging->get_page_size( ).

        DATA lt_paged TYPE TABLE OF zce_ret609.
        IF lv_page_size = if_rap_query_paging=>page_size_unlimited.
          lt_paged = lt_result.
        ELSE.
          DATA(lv_top) = lv_offset + lv_page_size.
          LOOP AT lt_result INTO DATA(wa_page) FROM lv_offset + 1 TO lv_top.
            APPEND wa_page TO lt_paged.
          ENDLOOP.
        ENDIF.

        io_response->set_total_number_of_records( lines( lt_result ) ).
        io_response->set_data( lt_result ).


    ENDMETHOD.
ENDCLASS.
