CLASS lcl_buffer DEFINITION.

  PUBLIC SECTION.

    CONSTANTS: created TYPE c LENGTH 1 VALUE 'C',
               updated TYPE c LENGTH 1 VALUE 'U',
               deleted TYPE c LENGTH 1 VALUE 'D'.

    TYPES: BEGIN OF ty_buffer_master.
             INCLUDE TYPE ztxtfile AS data.
    TYPES:   flag TYPE c LENGTH 1,
           END OF ty_buffer_master.

    TYPES: tt_master TYPE SORTED TABLE OF ty_buffer_master WITH UNIQUE KEY id.

    CLASS-DATA mt_buffer_master TYPE tt_master.

ENDCLASS.

CLASS lhc_txtfile DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR txtfile RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR txtfile RESULT result.

    METHODS resume FOR MODIFY
      IMPORTING keys FOR ACTION txtfile~resume.

    METHODS getdatafile FOR DETERMINE ON SAVE
      IMPORTING keys FOR txtfile~getdatafile.

    METHODS validatefilename FOR VALIDATE ON SAVE
      IMPORTING keys FOR txtfile~validatefilename.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE txtfile.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE txtfile.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE txtfile.

    METHODS read FOR READ
      IMPORTING keys FOR READ txtfile RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK txtfile.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR txtfile RESULT result.

ENDCLASS.

CLASS lhc_txtfile IMPLEMENTATION.

  METHOD get_instance_authorizations.

    DATA: update_requested TYPE abap_bool.
*          update_granted   TYPE abap_bool.

    READ ENTITIES OF zt_r_txtfile IN LOCAL MODE
        ENTITY txtfile
        FIELDS ( id )
        WITH CORRESPONDING #( keys )
        RESULT DATA(txtfiles).


    IF keys[ 1 ]-%is_draft = if_abap_behv=>mk-off.

      update_requested = COND #( WHEN requested_authorizations-%update = if_abap_behv=>mk-on
                                   OR requested_authorizations-%action-edit = if_abap_behv=>mk-on
                                 THEN abap_true
                                 ELSE abap_false ).


      LOOP AT txtfiles INTO DATA(txtfile).

        IF update_requested EQ abap_true.


          APPEND VALUE #( LET upd_auth = COND #( WHEN txtfile-filename = ''
                                                 THEN if_abap_behv=>auth-allowed
                                                 ELSE if_abap_behv=>auth-unauthorized )

                    IN
                        %tky         = txtfile-%tky
*                       %update      = upd_auth
                        %action-edit = upd_auth
*                       %delete      = del_auth
                        ) TO result.
        ENDIF.
      ENDLOOP.

    ENDIF.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD resume.
  ENDMETHOD.

  METHOD getdatafile.
  ENDMETHOD.

  METHOD validatefilename.
    READ ENTITIES OF zt_r_txtfile IN LOCAL MODE
    ENTITY txtfile
    FIELDS ( attachment )
    WITH CORRESPONDING #( keys )
    RESULT DATA(txtfiles).

    LOOP AT txtfiles INTO DATA(ls_txtfile).

      APPEND VALUE #( %tky        = ls_txtfile-%tky
                     %state_area = 'VALIDATE_FILE' ) TO reported-txtfile.

      IF ls_txtfile-attachment IS INITIAL.
        APPEND VALUE #( %tky = ls_txtfile-%tky ) TO failed-txtfile.


        APPEND VALUE #( %tky = ls_txtfile-%tky
                        %state_area = 'VALIDATE_FILE'
                        %msg = new_message( id   = 'Z_NCF_MC'
                                            number   = '005'
                                            severity = if_abap_behv_message=>severity-error )
                        %element-attachment    = if_abap_behv=>mk-on ) TO reported-txtfile.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD create.

    DATA: ls_buffer TYPE  lcl_buffer=>ty_buffer_master.


    LOOP AT entities INTO DATA(entity).

      TRY.
          ls_buffer-data-id                    = entity-%data-id.
          ls_buffer-data-attachment            = entity-%data-attachment.
          ls_buffer-data-filename              = entity-%data-filename.
          ls_buffer-data-mimetype              = entity-%data-mimetype.
          ls_buffer-data-local_created_by      = entity-%data-localcreatedby.
          ls_buffer-data-local_created_at      = entity-%data-localcreatedat.
          ls_buffer-data-local_last_changed_by = entity-%data-locallastchangedby.
          ls_buffer-data-local_last_changed_at = entity-%data-locallastchangedat.
          ls_buffer-data-last_changed_at       = entity-%data-lastchangedat.
          ls_buffer-flag                       = lcl_buffer=>created.
          INSERT ls_buffer INTO TABLE lcl_buffer=>mt_buffer_master.
        CATCH cx_uuid_error INTO DATA(cx).

      ENDTRY.

      IF entity-%cid IS NOT INITIAL.
        INSERT VALUE #( %cid = entity-%cid
                         id  = ls_buffer-id ) INTO TABLE mapped-txtfile.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD update.

    LOOP AT entities INTO DATA(entity).
      GET TIME STAMP FIELD entity-%data-locallastchangedat.
      entity-%data-locallastchangedby = sy-uname.

      SELECT SINGLE * FROM ztxtfile
             WHERE id EQ @entity-id
             INTO @DATA(ls_ddbb).

      IF sy-subrc EQ 0.

        INSERT VALUE #( flag = lcl_buffer=>updated
                data = VALUE #(
*                                attachment      = COND #( WHEN entity-%control-attachment = if_abap_behv=>mk-on
*                                                          THEN entity-attachment
*                                                          ELSE ls_ddbb-attachment )
                                 attachment     = entity-attachment

                                mimetype        = COND #( WHEN entity-%control-mimetype = if_abap_behv=>mk-on
                                                          THEN entity-mimetype
                                                          ELSE ls_ddbb-mimetype )

                                filename        = COND #( WHEN entity-%control-filename = if_abap_behv=>mk-on
                                                          THEN entity-filename
                                                          ELSE ls_ddbb-filename )

                                client                = ls_ddbb-client
                                id                    = entity-id
                                local_last_changed_at = entity-%data-locallastchangedat
                                local_last_changed_by = sy-uname
                                local_created_by      = ls_ddbb-local_created_by
                                local_created_at      = ls_ddbb-local_created_at
                                last_changed_at       = entity-%data-locallastchangedat
                            ) ) INTO TABLE lcl_buffer=>mt_buffer_master.

        IF entity-id IS NOT INITIAL.


          INSERT VALUE #( %cid = entity-id
                          id   = entity-id ) INTO TABLE mapped-txtfile.
        ENDIF.

      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD delete.

    LOOP AT keys INTO DATA(entity).
      INSERT VALUE #( flag = lcl_buffer=>deleted
                      data = VALUE #( id = entity-id ) ) INTO TABLE lcl_buffer=>mt_buffer_master.
      IF entity-id IS NOT INITIAL.
        INSERT VALUE #( %cid = entity-id
                        id   = entity-id ) INTO TABLE mapped-txtfile.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD read.

    LOOP AT keys INTO DATA(ls_key).

      "Fetch header record
      SELECT SINGLE *
        FROM ztxtfile
        WHERE id = @ls_key-id
        INTO @DATA(ls_hdr).


      IF sy-subrc = 0.
        APPEND VALUE #( %tky      = ls_key-%tky
*                      mandt     = ls_hdr-mandt
                        id             = ls_hdr-id
                        attachment     = ls_hdr-attachment
                        filename       = ls_hdr-filename
                        mimetype       = ls_hdr-mimetype
                        lastchangedat  = ls_hdr-last_changed_at
                        localcreatedat = ls_hdr-local_created_at
                        localcreatedby = ls_hdr-local_created_by
                        locallastchangedat = ls_hdr-local_last_changed_at
                        locallastchangedby = ls_hdr-local_last_changed_by ) TO result.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD get_instance_features.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_zt_r_textfile DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zt_r_textfile IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.

    TYPES:
      BEGIN OF ty_str,
        sttr TYPE c LENGTH 200,
      END OF ty_str,

      ty_t_str TYPE TABLE OF ty_str.

    DATA: lt_data_created TYPE STANDARD TABLE OF ztxtfile,
          lt_data_updated TYPE STANDARD TABLE OF ztxtfile,
          lt_data_deleted TYPE STANDARD TABLE OF ztxtfile,
          ls_dtable       TYPE ztfirncncf_e,
          lt_dtable       TYPE STANDARD TABLE OF ztfirncncf_e,
          lt_str          TYPE ty_t_str.



    lt_data_created = VALUE #( FOR <row> IN lcl_buffer=>mt_buffer_master WHERE ( flag = lcl_buffer=>created ) ( <row>-data ) ).

    IF lt_data_created IS NOT INITIAL.
      INSERT ztxtfile FROM TABLE @lt_data_created.

      IF sy-subrc EQ 0.

        DATA lv_x TYPE xstring.

        DATA lv_lf_xs TYPE xstring VALUE '0A'.  " \n
        DATA lv_cr    TYPE x LENGTH 1 VALUE '0D'. " \r

        DATA off  TYPE i VALUE 0.
        DATA moff TYPE i.
        DATA mlen TYPE i.
        DATA xline TYPE xstring.
        DATA ls_txt TYPE string.
        DATA lv_xline_len TYPE i.
        DATA lv_last_off  TYPE i.

        DATA ls_data TYPE ztfirncncf_e.

        DATA(lv_uname) = cl_abap_context_info=>get_user_technical_name( ).

*       En S/4HANA Cloud los Communication Users siempre tienen el prefijo CC.
*       Los usuarios de diálogo (Fiori) tienen otro formato
        IF lv_uname(2) <> 'CC'.
          DELETE FROM ztfirncncf_e.
        ENDIF.

************************************************************************

        LOOP AT lt_data_created INTO DATA(ldata).

          lv_x = ldata-attachment.

          CLEAR:
          ls_txt,
          lt_dtable.

          WHILE off < xstrlen( lv_x ).

            FIND FIRST OCCURRENCE OF lv_lf_xs
              IN SECTION OFFSET off OF lv_x
              IN BYTE MODE
              MATCH OFFSET moff MATCH LENGTH mlen.

            IF sy-subrc = 0.
              " Bytes antes del LF
              DATA(var) = moff - off.
              xline = lv_x+off(var).
              " Avanza después del LF
              off = moff + 1.
            ELSE.
              " Última línea
              DATA(var2) = xstrlen( lv_x ) - off.
              xline = lv_x+off(var2).
              off = xstrlen( lv_x ).
            ENDIF.

            " Quitar CR si el archivo viene con CRLF
            lv_xline_len = xstrlen( xline ).
            IF lv_xline_len > 0.
              lv_last_off = lv_xline_len - 1.
              IF xline+lv_last_off(1) = lv_cr.
                xline = xline(lv_last_off).
              ENDIF.
            ENDIF.

            TRY.
                " Convertir SOLO esta línea (UTF-8) usando XCO (permitido)
                ls_txt = xco_cp=>xstring( xline
                         )->as_string( xco_cp_character=>code_page->utf_8
                         )->value.

              CATCH cx_root INTO DATA(cx).
                APPEND VALUE #( id          = ldata-id
                                %state_area = 'INSERT'
                                %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                              text     = cx->get_longtext( ) )
                              ) TO reported-txtfile.
            ENDTRY.
            IF ls_txt IS INITIAL.
              CONTINUE.
            ENDIF.

            CLEAR:
              ls_dtable-id_uuid,
              ls_dtable-rcn,
              ls_dtable-prefijo,
              ls_dtable-nombre_comercial,
              ls_dtable-valido_hasta,
              ls_dtable-ncfini,
              ls_dtable-ncffin,

              ls_data.

            TRY.
                ls_dtable-id_uuid = cl_system_uuid=>create_uuid_x16_static( ).
              CATCH cx_uuid_error INTO DATA(cxuid).
                CONTINUE.
            ENDTRY.

            ls_dtable-last_changed_at        = ldata-last_changed_at.
            ls_dtable-local_created_at       = ldata-local_created_at.
            ls_dtable-local_created_by       = ldata-local_created_by.
            ls_dtable-local_last_changed_at  = ldata-local_last_changed_at.
            ls_dtable-local_last_changed_by  = ldata-local_last_changed_by.

            SPLIT ls_txt AT '|' INTO ls_dtable-rcn
                                     ls_dtable-nombre_comercial
                                     ls_dtable-prefijo
                                     ls_dtable-ncfini
                                     ls_dtable-ncffin
                                     ls_dtable-valido_hasta.

            ls_dtable-ncfini = |{ ls_dtable-ncfini ALPHA = IN }|.
            ls_dtable-ncffin = |{ ls_dtable-ncffin ALPHA = IN }|.


*            SELECT SINGLE *
*              FROM ztfirncncf_e
*              WHERE rcn    = @ls_dtable-rcn          AND
*              prefijo      = @ls_dtable-prefijo      AND
*              valido_hasta = @ls_dtable-valido_hasta AND
*              ncfini       = @ls_dtable-ncfini       AND
*              ncffin       = @ls_dtable-ncffin
*              INTO @ls_data.
*
*            IF sy-subrc EQ 0.
*              UPDATE ztfirncncf_e SET
*                                      nombre_comercial      = @ls_dtable-nombre_comercial,
*                                      ncfini                = @ls_dtable-ncfini,
*                                      ncffin                = @ls_dtable-ncffin,
*                                      local_created_by      = @ls_dtable-local_created_by,
*                                      local_created_at      = @ls_dtable-local_created_at,
*                                      local_last_changed_by = @ls_dtable-local_last_changed_by,
*                                      local_last_changed_at = @ls_dtable-local_last_changed_at,
*                                      last_changed_at       = @ls_dtable-last_changed_at
*                WHERE
*                 rcn          = @ls_dtable-rcn          AND
*                 prefijo      = @ls_dtable-prefijo      AND
*                 valido_hasta = @ls_dtable-valido_hasta AND
*                 ncfini       = @ls_dtable-ncfini       AND
*                 ncffin       = @ls_dtable-ncffin.
*
*            ELSE.


            APPEND ls_dtable TO lt_dtable.

            " Insert por paquetes
            IF lines( lt_dtable ) >= 10000.
              INSERT ztfirncncf_e FROM TABLE @lt_dtable.
              CLEAR lt_dtable.
            ENDIF.
*            ENDIF.

          ENDWHILE.

          " Inserta lo restante
          IF lt_dtable IS NOT INITIAL.
            INSERT ztfirncncf_e FROM TABLE @lt_dtable.
          ENDIF.


        ENDLOOP.

************************************************************************


*        LOOP AT lt_data_created INTO DATA(ldata).
*
*          FINAL(lv_attachment) = ldata-attachment.
*
*          DATA(lt_txt) = xco_cp=>xstring( lv_attachment
*              )->as_string( xco_cp_character=>code_page->utf_8
*              )->split( |\n| )->value.
**              )->split( |{ cl_abap_char_utilities=>cr_lf }| )->value.
*
*
*            LOOP AT lt_txt INTO DATA(ls_txt).
*
*              CLEAR:
*                  ls_dtable-id_uuid,
*                  ls_dtable-rcn,
*                  ls_dtable-prefijo,
*                  ls_dtable-nombre_comercial,
*                  ls_dtable-valido_hasta,
*                  ls_dtable-ncfini,
*                  ls_dtable-ncffin.
*
*              TRY.
*                  ls_dtable-id_uuid = cl_system_uuid=>create_uuid_x16_static( ).
*                CATCH cx_uuid_error INTO DATA(cx2).
*
*              ENDTRY.
*
*              ls_dtable-last_changed_at = ldata-last_changed_at.
*              ls_dtable-local_created_at      = ldata-local_created_at.
*              ls_dtable-local_created_by      = ldata-local_created_by.
*              ls_dtable-local_last_changed_at = ldata-local_last_changed_at.
*              ls_dtable-local_last_changed_by = ldata-local_last_changed_by.
*
*              SPLIT ls_txt AT '|' INTO ls_dtable-rcn
*                                       ls_dtable-nombre_comercial
*                                       ls_dtable-prefijo
*                                       ls_dtable-ncfini
*                                       ls_dtable-ncffin
*                                       ls_dtable-valido_hasta.
*
*              ls_dtable-ncfini = |{ ls_dtable-ncfini ALPHA = IN }|.
*              ls_dtable-ncffin = |{ ls_dtable-ncffin ALPHA = IN }|.
*              APPEND ls_dtable TO lt_dtable.
*
*
*            ENDLOOP.
*
*            IF lines( lt_dtable ) GT 0.
*
*                INSERT ztfirncncf_e FROM TABLE @lt_dtable.
*
*            ENDIF.
*          ENDLOOP.
      ENDIF.
    ENDIF.

    lt_data_updated = VALUE #( FOR <row> IN lcl_buffer=>mt_buffer_master WHERE ( flag = lcl_buffer=>updated ) ( <row>-data ) ).

    IF lt_data_updated IS NOT INITIAL.
      UPDATE ztxtfile FROM TABLE @lt_data_updated.
      CLEAR: var, var2.
      LOOP AT lt_data_updated INTO DATA(ldata_upd).

        lv_x = ldata_upd-attachment.

        CLEAR:
        ls_txt,
        lt_dtable.

        WHILE off < xstrlen( lv_x ).

          FIND FIRST OCCURRENCE OF lv_lf_xs
            IN SECTION OFFSET off OF lv_x
            IN BYTE MODE
            MATCH OFFSET moff MATCH LENGTH mlen.

          IF sy-subrc = 0.
            " Bytes antes del LF
            var = moff - off.
            xline = lv_x+off(var).
            " Avanza después del LF
            off = moff + 1.
          ELSE.
            " Última línea
            var2 = xstrlen( lv_x ) - off.
            xline = lv_x+off(var2).
            off = xstrlen( lv_x ).
          ENDIF.

          " Quitar CR si el archivo viene con CRLF
          lv_xline_len = xstrlen( xline ).
          IF lv_xline_len > 0.
            lv_last_off = lv_xline_len - 1.
            IF xline+lv_last_off(1) = lv_cr.
              xline = xline(lv_last_off).
            ENDIF.
          ENDIF.

          TRY.
              " Convertir SOLO esta línea (UTF-8) usando XCO (permitido)
              ls_txt = xco_cp=>xstring( xline
                       )->as_string( xco_cp_character=>code_page->utf_8
                       )->value.

            CATCH cx_root INTO cx.
              APPEND VALUE #( id          = ldata_upd-id
                              %state_area = 'INSERT'
                              %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                            text     = cx->get_longtext( ) )
                            ) TO reported-txtfile.
          ENDTRY.
          IF ls_txt IS INITIAL.
            CONTINUE.
          ENDIF.

          CLEAR:
            ls_dtable-id_uuid,
            ls_dtable-rcn,
            ls_dtable-prefijo,
            ls_dtable-nombre_comercial,
            ls_dtable-valido_hasta,
            ls_dtable-ncfini,
            ls_dtable-ncffin,

            ls_data.

          TRY.
              ls_dtable-id_uuid = cl_system_uuid=>create_uuid_x16_static( ).
            CATCH cx_uuid_error INTO cxuid.
              CONTINUE.
          ENDTRY.

          ls_dtable-last_changed_at        = ldata_upd-last_changed_at.
          ls_dtable-local_created_at       = ldata_upd-local_created_at.
          ls_dtable-local_created_by       = ldata_upd-local_created_by.
          ls_dtable-local_last_changed_at  = ldata_upd-local_last_changed_at.
          ls_dtable-local_last_changed_by  = ldata_upd-local_last_changed_by.

          SPLIT ls_txt AT '|' INTO ls_dtable-rcn
                                   ls_dtable-nombre_comercial
                                   ls_dtable-prefijo
                                   ls_dtable-ncfini
                                   ls_dtable-ncffin
                                   ls_dtable-valido_hasta.

          ls_dtable-ncfini = |{ ls_dtable-ncfini ALPHA = IN }|.
          ls_dtable-ncffin = |{ ls_dtable-ncffin ALPHA = IN }|.


*          SELECT SINGLE *
*              FROM ztfirncncf_e
*              WHERE rcn    = @ls_dtable-rcn          AND
*              prefijo      = @ls_dtable-prefijo      AND
*              valido_hasta = @ls_dtable-valido_hasta AND
*              ncfini       = @ls_dtable-ncfini       AND
*              ncffin       = @ls_dtable-ncffin
*              INTO @ls_data.
*
*          IF sy-subrc EQ 0.
*            UPDATE ztfirncncf_e SET
*                                    nombre_comercial      = @ls_dtable-nombre_comercial,
*                                    ncfini                = @ls_dtable-ncfini,
*                                    ncffin                = @ls_dtable-ncffin,
*                                    local_created_by      = @ls_dtable-local_created_by,
*                                    local_created_at      = @ls_dtable-local_created_at,
*                                    local_last_changed_by = @ls_dtable-local_last_changed_by,
*                                    local_last_changed_at = @ls_dtable-local_last_changed_at,
*                                    last_changed_at       = @ls_dtable-last_changed_at
*              WHERE
*               rcn          = @ls_dtable-rcn          AND
*               prefijo      = @ls_dtable-prefijo      AND
*               valido_hasta = @ls_dtable-valido_hasta AND
*               ncfini       = @ls_dtable-ncfini       AND
*               ncffin       = @ls_dtable-ncffin.
*
*          ELSE.
          APPEND ls_dtable TO lt_dtable.

          " Insert por paquetes
          IF lines( lt_dtable ) >= 10000.
            INSERT ztfirncncf_e FROM TABLE @lt_dtable.

            CLEAR lt_dtable.
          ENDIF.
*          ENDIF.



        ENDWHILE.

        " Inserta lo restante
        IF lt_dtable IS NOT INITIAL.
          INSERT ztfirncncf_e FROM TABLE @lt_dtable.
        ENDIF.


      ENDLOOP.

    ENDIF.

    lt_data_deleted = VALUE #( FOR <row> IN lcl_buffer=>mt_buffer_master WHERE ( flag = lcl_buffer=>deleted ) ( <row>-data ) ).

    IF lt_data_deleted IS NOT INITIAL.
      DELETE ztxtfile FROM TABLE @lt_data_deleted.
    ENDIF.
  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
