CLASS zcl_ncf_anulados608_query DEFINITION
  PUBLIC FINAL CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
ENDCLASS.



CLASS ZCL_NCF_ANULADOS608_QUERY IMPLEMENTATION.


    METHOD if_rap_query_provider~select.

    " --- Read parameters
    DATA lt_ranges TYPE if_rap_query_filter=>tt_name_range_pairs.
    DATA lv_bukrs  TYPE bukrs.
    DATA lv_gjahr  TYPE gjahr.
    DATA lv_p_low  TYPE d.
    DATA lv_p_high TYPE d.
    DATA lv_blart  TYPE blart.

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
        WHEN 'FECHA_COMPROBANTE'.
          READ TABLE filter-range INTO DATA(r_fecha) INDEX 1.
          IF sy-subrc = 0.
            lv_p_low  = r_fecha-low.
            lv_p_high = r_fecha-high.
          ENDIF.
      ENDCASE.
    ENDLOOP.

    IF lv_p_high IS INITIAL.
        lv_p_high = lv_p_low.
    ENDIF.

    DATA lv_host TYPE string.
    CASE sy-mandt.
      WHEN '080'.
        lv_host = 'https://my406252.s4hana.cloud.sap'.
      WHEN OTHERS.
        lv_host = 'https://my406684.s4hana.cloud.sap'.
    ENDCASE.

    DATA(lv_download_url) = |{ lv_host }/sap/bc/http/sap/zncf_anulados608_http| &&
                        |?bukrs={ lv_bukrs }| &&
                        |&gjahr={ lv_gjahr }| &&
                        |&p_low={ lv_p_low }| &&
                        |&p_high={ lv_p_high }|.

    DATA lt_result TYPE TABLE OF zce_ncf_anulados608.

    " =============================================================
    " SD: Cancelled Billing Documents
    " =============================================================
    SELECT BillingDocument,
           CompanyCode,
           VATRegistration     AS ncf,
           BillingDocumentDate AS fkdat,
           FiscalYear
     FROM I_BillingDocument
     WHERE CompanyCode                  = @lv_bukrs
       AND   FiscalYear                 = @lv_gjahr
       AND   BillingDocumentDate BETWEEN @lv_p_low AND @lv_p_high
       AND   VATRegistration            <> @space
       AND   BillingDocumentIsCancelled = 'X'
    INTO TABLE @DATA(lt_sd).

    SORT lt_sd BY ncf.
    DELETE ADJACENT DUPLICATES FROM lt_sd COMPARING ncf.

    LOOP AT lt_sd INTO DATA(wa_sd).
        APPEND VALUE #(
            belnr             = wa_sd-BillingDocument
            doc_fi            = wa_sd-BillingDocument
            bukrs             = wa_sd-CompanyCode
            gjahr             = wa_sd-FiscalYear
            ncf               = wa_sd-ncf
            fecha_comprobante = wa_sd-fkdat
            tipo_anulacion    = '04'
            download_url      = lv_download_url
        ) TO lt_result.
    ENDLOOP.

    " =============================================================
    " FI: Revert Documents
    " =============================================================
    SELECT AccountingDocument,
           CompanyCode,
           AccountingDocumentHeaderText AS ncf,
           DocumentDate                 AS bldat,
           FiscalYear,
           ReverseDocument,
           IsReversal,
           IsReversed,
           ReferenceDocumentType,
           AccountingDocumentType
     FROM I_JournalEntry
     WHERE CompanyCode           = @lv_bukrs
       AND FiscalYear            = @lv_gjahr
       AND PostingDate BETWEEN @lv_p_low AND @lv_p_high
       AND ( ReverseDocument <> @space OR IsReversal = 'X' OR IsReversed = 'X' )
       AND ReferenceDocumentType <> 'VBRK'
       AND ( @lv_blart IS INITIAL OR AccountingDocumentType = @lv_blart )
       "AND (    AccountingDocumentHeaderText LIKE 'B11%' OR AccountingDocumentHeaderText LIKE 'B13%'
       "     OR AccountingDocumentHeaderText LIKE 'B01%' OR AccountingDocumentHeaderText LIKE 'B02%'
       "     OR AccountingDocumentHeaderText LIKE 'B03%' OR AccountingDocumentHeaderText LIKE 'B04%'
       "     OR AccountingDocumentHeaderText LIKE 'B15%' OR AccountingDocumentHeaderText LIKE 'B16%'
       "     OR AccountingDocumentHeaderText LIKE 'B17%' )
    INTO TABLE @DATA(lt_fi).

    SORT lt_fi BY ncf.
    DELETE ADJACENT DUPLICATES FROM lt_fi COMPARING ncf.

    LOOP AT lt_fi INTO DATA(wa_fi).
        APPEND VALUE #(
            belnr             = wa_fi-AccountingDocument
            doc_fi            = wa_fi-AccountingDocument
            bukrs             = wa_fi-CompanyCode
            gjahr             = wa_fi-FiscalYear
            ncf               = wa_fi-ncf
            fecha_comprobante = wa_fi-bldat
            tipo_anulacion    = '04'
            download_url      = lv_download_url
        ) TO lt_result.
    ENDLOOP.

    " =============================================================
    " Item Information
    " =============================================================
    LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<row>).
        SELECT SINGLE Segment
         FROM I_JournalEntryItem
         WHERE CompanyCode         = @<row>-bukrs
           AND AccountingDocument  = @<row>-doc_fi
           AND FiscalYear          = @<row>-gjahr
           AND Segment            <> @space
        INTO @<row>-segment.

        IF <row>-segment IS NOT INITIAL.
          SELECT SINGLE SegmentName
           FROM I_SegmentText
           WHERE Segment  = @<row>-segment
             AND Language = 'S'
          INTO @<row>-segment_name.
        ENDIF.
    ENDLOOP.

    " =============================================================
    " Deleting global duplications
    " =============================================================
    SORT lt_result BY ncf.
    DELETE ADJACENT DUPLICATES FROM lt_result COMPARING ncf.

    " Download Link on first value
    IF lt_result IS NOT INITIAL.
      lt_result[ 1 ]-dummyaction = 'Descargar Reporte 608'.
    ENDIF.

    " Paging — Required for RAP framework
    IF io_request->is_total_numb_of_rec_requested( ).
      io_response->set_total_number_of_records( lines( lt_result ) ).
    ENDIF.

    DATA(lo_paging)    = io_request->get_paging( ).
    DATA(lv_offset)    = lo_paging->get_offset( ).
    DATA(lv_page_size) = lo_paging->get_page_size( ).

    IF lv_offset > 0 AND lv_offset < lines( lt_result ).
      DELETE lt_result TO lv_offset.
    ENDIF.
    IF lv_page_size <> if_rap_query_paging=>page_size_unlimited.
      IF lines( lt_result ) > lv_page_size.
        DELETE lt_result FROM lv_page_size + 1.
      ENDIF.
    ENDIF.

    io_response->set_data( lt_result ).

    ENDMETHOD.
ENDCLASS.
