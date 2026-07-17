*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
CLASS lcl_je_created_handler DEFINITION
  INHERITING FROM cl_abap_behavior_event_handler.
  PRIVATE SECTION.

    METHODS on_created
        FOR ENTITY EVENT created
          FOR journalentry~created.



ENDCLASS.

CLASS lcl_je_created_handler IMPLEMENTATION.

  METHOD on_created.

    DATA lt_je    TYPE TABLE FOR ACTION IMPORT i_journalentrytp~change.
    DATA lv_ncf   TYPE zcomprobante.
    DATA lv_doc   TYPE belnr_d.
    DATA lv_bukrs TYPE bukrs.
    DATA lv_gjahr TYPE gjahr.
    DATA lv_cldoc TYPE zcl_doc.
    DATA iv_object TYPE cl_numberrange_intervals=>nr_object.
    DATA lv_b TYPE n LENGTH 8.
    DATA lv_e TYPE n LENGTH 10.


    SELECT FROM i_journalentry AS a INNER JOIN i_journalentryitem AS b ON a~accountingdocument = b~accountingdocument AND
                                                                a~companycode = b~companycode AND
                                                                a~fiscalyear  = b~fiscalyear
                                    INNER JOIN @created AS c ON a~accountingdocument = c~accountingdocument AND
                                                                a~companycode = c~companycode AND
                                                                a~fiscalyear  = c~fiscalyear
    FIELDS
    a~companycode, a~fiscalyear, a~accountingdocument, a~accountingdocumenttype,
    a~documentdate, b~financialaccounttype, b~supplier
    WHERE
    b~supplier IS NOT INITIAL
    INTO TABLE @DATA(lt_data).


    SELECT FROM zconfi_ncf AS a INNER JOIN @created AS b ON a~bukrs = b~companycode
    FIELDS
    a~bukrs,
    a~cl_doc,
    a~serie,
    a~znrnr
    WHERE a~serie <> ''
    AND a~znrnr <> ''
    INTO TABLE @DATA(lt_config).

    LOOP AT created INTO DATA(ls_event).

      CLEAR: lv_ncf, lt_je, lv_doc, iv_object.

      IF line_exists( lt_data[ companycode = ls_event-companycode
                               fiscalyear  = ls_event-fiscalyear
                               accountingdocument = ls_event-accountingdocument ] ).

        DATA(ls_data) =  lt_data[ companycode = ls_event-companycode
                                  fiscalyear  = ls_event-fiscalyear
                                  accountingdocument = ls_event-accountingdocument ].

        CHECK ls_data-financialaccounttype EQ 'K'. "Verificar que sea documento de proveedor
        CHECK ls_data-companycode EQ '5000'.

        lv_doc   = ls_event-accountingdocument.
        lv_bukrs = ls_event-companycode.
        lv_gjahr = ls_event-fiscalyear.

*       Generar el NCF
        IF line_exists( lt_config[ bukrs  = ls_event-companycode
                                   cl_doc = ls_data-accountingdocumenttype ] ).

          DATA(ls_config) = lt_config[ bukrs  = ls_event-companycode
                                       cl_doc = ls_data-accountingdocumenttype ].
*         Generar Comprobante


          CASE ls_config-serie.
            WHEN 'B'.
              iv_object = 'ZCESTANDAR'. "Estandar
            WHEN 'E'.
              iv_object = 'ZCELECTRON'. "Electronico
          ENDCASE.

          TRY.

              cl_numberrange_runtime=>number_get(
                EXPORTING
                  nr_range_nr       = '01'
                  object            = iv_object
                IMPORTING
                  number            = DATA(lv_number)
              ).

              CASE ls_config-serie.
                WHEN 'B'.
                  lv_b = lv_number.

                  lv_ncf = |{ ls_config-serie }| & |{ ls_config-znrnr }| & |{ lv_b }|.
                WHEN 'E'.
                  lv_e = lv_number.

                  lv_ncf = |{ ls_config-serie }| & |{ ls_config-znrnr }| & |{ lv_e }|.
                WHEN OTHERS.
                  RETURN.
              ENDCASE.
*              lv_ncf = |{ ls_config-serie }| & |{ ls_config-znrnr }| & |{ lv_number }|.


            CATCH cx_nr_object_not_found INTO DATA(lx_obj1).
              CLEAR lv_ncf.
            CATCH cx_number_ranges INTO DATA(lx_obj3).
              CLEAR lv_ncf.
          ENDTRY.


        ENDIF.


        IF lv_ncf IS INITIAL.
          CONTINUE.
        ENDIF.

        " Llamar I_JournalEntryTP~Change
*        DATA lt_je TYPE TABLE FOR ACTION IMPORT
*                        i_journalentrytp~change.

        APPEND INITIAL LINE TO lt_je
          ASSIGNING FIELD-SYMBOL(<je>).

        DATA ls_ctrl LIKE <je>-%param-%control.
        ls_ctrl-documentheadertext = if_abap_behv=>mk-on.

        <je>-accountingdocument = lv_doc.
        <je>-companycode        = lv_bukrs.
        <je>-fiscalyear         = lv_gjahr.
        <je>-%param = VALUE #(
                                documentheadertext = lv_ncf
                                %control           = ls_ctrl
        ).

        MODIFY ENTITIES OF i_journalentrytp
          ENTITY journalentry
          EXECUTE change FROM lt_je
          FAILED   DATA(lt_failed)
          REPORTED DATA(lt_reported)
          MAPPED   DATA(lt_mapped).

        " Log en tabla Z
        IF lt_failed IS INITIAL.

          INSERT zpending_ncf FROM @( VALUE zpending_ncf(
            client              = sy-mandt
            accounting_document = lv_doc
            company_code        = lv_bukrs
            fiscal_year         = lv_gjahr
            vendor              = ls_data-supplier
            ncf                 = lv_ncf
            status              = 'D'
            created_at          = cl_abap_context_info=>get_system_date( )
            created_by          = cl_abap_context_info=>get_user_alias( )
          ) ).
        ELSE.
          INSERT zpending_ncf FROM @( VALUE zpending_ncf(
            client              = sy-mandt
            accounting_document = lv_doc
            company_code        = lv_bukrs
            fiscal_year         = lv_gjahr
            vendor              = ls_data-supplier
            status              = 'E'
            created_at          = cl_abap_context_info=>get_system_date( )
            created_by          = cl_abap_context_info=>get_user_alias( )
          ) ).
        ENDIF.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
