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
    DATA iv_object TYPE cl_numberrange_intervals=>nr_object.
    DATA lv_b TYPE n LENGTH 8.
    DATA lv_e TYPE n LENGTH 10.


    SELECT FROM i_journalentry AS a INNER JOIN @created AS b ON a~accountingdocument = b~accountingdocument AND
                                                                a~companycode = b~companycode AND
                                                                a~fiscalyear  = b~fiscalyear
    FIELDS
    a~companycode, a~fiscalyear, a~accountingdocument, a~accountingdocumenttype, a~documentdate
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
                  CONTINUE.
              ENDCASE.


            CATCH cx_nr_object_not_found INTO DATA(lx_obj1).
              CLEAR lv_ncf.
            CATCH cx_number_ranges INTO DATA(lx_obj3).
              CLEAR lv_ncf.
          ENDTRY.


        ENDIF.


        IF lv_ncf IS INITIAL.
          CONTINUE.
        ENDIF.


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

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
