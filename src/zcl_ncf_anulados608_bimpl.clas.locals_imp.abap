*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
CLASS lcl_handler DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS descargar_archivo608 FOR MODIFY
      IMPORTING keys FOR ACTION ZCE_NCF_ANULADOS608~DescargarArchivo608
      RESULT    result.
ENDCLASS.

CLASS lcl_handler IMPLEMENTATION.

  METHOD descargar_archivo608.
    LOOP AT keys INTO DATA(key).

      DATA(lv_bukrs)  = key-%param-bukrs.
      DATA(lv_gjahr)  = key-%param-gjahr.
      DATA lv_p_low  TYPE string.
      DATA lv_p_high TYPE string.
      DATA(lv_blart)  = key-%param-blart.

      lv_p_low  = key-%param-p_low.
      lv_p_high = key-%param-p_high.

      DATA lv_host TYPE string.
      CASE sy-mandt.
        WHEN '080'.
          lv_host = 'https://my406252.s4hana.cloud.sap'.
        WHEN '100'.
          lv_host = 'https://my406684.s4hana.cloud.sap'.
        WHEN OTHERS.
          lv_host = 'https://my406684.s4hana.cloud.sap'.
      ENDCASE.

      DATA(lv_url) = |{ lv_host }/sap/bc/http/sap/zncf_anulados608_http| &&
               |?bukrs={ lv_bukrs }| &&
               |&gjahr={ lv_gjahr }| &&
               |&p_low={ lv_p_low }| &&
               |&p_high={ lv_p_high }| &&
               |&blart={ lv_blart }|.

      APPEND VALUE #(
        %cid                = key-%cid
        %param-file_content = lv_url
        %param-filename     = 'Haz clic en el link de file_content para descargar'
      ) TO result.

      APPEND VALUE #(
        %msg = new_message_with_text(
        severity = if_abap_behv_message=>severity-information
        text     = |URL de descarga: { lv_url }|
        )
      ) TO reported-zce_ncf_anulados608.

    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
