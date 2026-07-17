CLASS zcl_ncf_anulados608_http DEFINITION
  PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_http_service_extension.
ENDCLASS.



CLASS ZCL_NCF_ANULADOS608_HTTP IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.

    DATA(lv_bukrs)  = CONV bukrs( request->get_form_field( 'bukrs'  ) ).
    DATA(lv_gjahr)  = CONV gjahr( request->get_form_field( 'gjahr'  ) ).
    DATA(lv_p_low)  = CONV d(    request->get_form_field( 'p_low'   ) ).
    DATA(lv_p_high) = CONV d(    request->get_form_field( 'p_high'  ) ).
    DATA(lv_blart)  = CONV blart( request->get_form_field( 'blart'  ) ).
    CONDENSE lv_blart NO-GAPS.

    IF lv_bukrs IS INITIAL OR lv_gjahr IS INITIAL OR lv_p_low IS INITIAL.
        response->set_status( i_code = 400 i_reason = 'Bad Request' ).
        DATA(lv_err) = cl_abap_conv_codepage=>create_out( codepage = 'UTF-8' )->convert( 'Parámetros requeridos: bukrs, gjahr, p_low' ).
        response->set_binary( lv_err ).
        RETURN.
    ENDIF.

    IF lv_p_high IS INITIAL. lv_p_high = lv_p_low. ENDIF.

    " 1. RNC de la Sociedad
    SELECT SINGLE VATRegistration
      FROM I_CompanyCode
      WHERE CompanyCode = @lv_bukrs
      INTO @DATA(lv_rnc).
    REPLACE ALL OCCURRENCES OF '-' IN lv_rnc WITH ''.
    CONDENSE lv_rnc NO-GAPS.

    " 2. NCFs de SD
    SELECT BillingDocument,
           VATRegistration     AS stceg,
           BillingDocumentDate AS fkdat,
           FiscalYear
      FROM I_BillingDocument
      WHERE CompanyCode                = @lv_bukrs
        AND FiscalYear                 = @lv_gjahr
        AND BillingDocumentDate BETWEEN @lv_p_low AND @lv_p_high
        AND VATRegistration           <> @space
        AND BillingDocumentIsCancelled = 'X'
      INTO TABLE @DATA(lt_sd).

    " 3. NCFs de FI
    SELECT AccountingDocument,
           AccountingDocumentHeaderText AS ncf,
           DocumentDate                 AS bldat,
           FiscalYear
      FROM I_JournalEntry
      WHERE CompanyCode    = @lv_bukrs
        AND FiscalYear     = @lv_gjahr
        AND PostingDate BETWEEN @lv_p_low AND @lv_p_high
        AND ( ReverseDocument <> @space OR IsReversal = 'X' OR IsReversed = 'X' )
        AND ReferenceDocumentType <> 'VBRK'
        AND ( @lv_blart IS INITIAL OR AccountingDocumentType = @lv_blart )
        "AND ( AccountingDocumentHeaderText LIKE 'B11%'
        "   OR AccountingDocumentHeaderText LIKE 'B13%'
        "   OR AccountingDocumentHeaderText LIKE 'B01%'
        "   OR AccountingDocumentHeaderText LIKE 'B02%'
        "   OR AccountingDocumentHeaderText LIKE 'B03%'
        "   OR AccountingDocumentHeaderText LIKE 'B04%'
        "   OR AccountingDocumentHeaderText LIKE 'B15%'
        "   OR AccountingDocumentHeaderText LIKE 'B16%'
        "   OR AccountingDocumentHeaderText LIKE 'B17%' )
      INTO TABLE @DATA(lt_fi).

    " 4. Consolidar y eliminar duplicados por NCF
    TYPES: BEGIN OF ty_det,
             ncf   TYPE stceg,
             fecha TYPE d,
             tipo  TYPE n LENGTH 2,
           END OF ty_det.
    DATA lt_det TYPE TABLE OF ty_det.

    LOOP AT lt_sd INTO DATA(wa_sd).
      APPEND VALUE ty_det( ncf = wa_sd-stceg  fecha = wa_sd-fkdat  tipo = '04' ) TO lt_det.
    ENDLOOP.
    LOOP AT lt_fi INTO DATA(wa_fi).
      APPEND VALUE ty_det( ncf = wa_fi-ncf  fecha = wa_fi-bldat  tipo = '04' ) TO lt_det.
    ENDLOOP.

    SORT lt_det BY ncf.
    DELETE ADJACENT DUPLICATES FROM lt_det COMPARING ncf.

    DATA(lv_cant) = lines( lt_det ).
    DATA lv_cant_str TYPE string.
    lv_cant_str = lv_cant.
    CONDENSE lv_cant_str NO-GAPS.

    " 5. Cabecera: 608|RNC|AAAA|MM|cantidad
    DATA(lv_periodo) = lv_p_low(4).
    DATA(lv_mes)     = lv_p_low+4(2).

    DATA lv_content TYPE string.
    CONCATENATE '608' lv_rnc lv_periodo lv_mes lv_cant_str
      INTO lv_content SEPARATED BY '|'.

    " 6. Líneas de detalle: NCF|AAAAMMDD|04
    LOOP AT lt_det INTO DATA(det).
      DATA lv_line  TYPE string.
      DATA lv_fecha TYPE c LENGTH 8.
      lv_fecha = det-fecha.
      CONCATENATE det-ncf lv_fecha det-tipo INTO lv_line SEPARATED BY '|'.
      CONCATENATE lv_content cl_abap_char_utilities=>newline lv_line INTO lv_content.
    ENDLOOP.

    " 7. Responder como descarga
    DATA(lv_filename) = |NCF_608_Anulados_{ lv_periodo }{ lv_mes }.txt|.


    response->set_status( i_code = 200 i_reason = 'OK' ).
    response->set_content_type( 'text/plain; charset=utf-8' ).
    response->set_header_field( i_name = 'Content-Disposition' i_value = |attachment; filename="{ lv_filename }"| ).

    DATA(lv_xdata) = cl_abap_conv_codepage=>create_out( codepage = 'UTF-8' )->convert( lv_content ).
    response->set_binary( lv_xdata ).

  ENDMETHOD.
ENDCLASS.
