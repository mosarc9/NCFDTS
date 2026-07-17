"-------------------------------------------------------
" Flag para señalizar el borrado total
"-------------------------------------------------------
CLASS lcl_flag DEFINITION.
  PUBLIC SECTION.
    CLASS-DATA delete_all TYPE abap_bool.
ENDCLASS.

CLASS lcl_flag IMPLEMENTATION.
ENDCLASS.

"-------------------------------------------------------
" Behavior Handler
"-------------------------------------------------------
CLASS lhc_zt_r_deltable DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zt_r_deltable RESULT result.

    METHODS deleteall FOR MODIFY
      IMPORTING keys FOR ACTION zt_r_deltable~deleteall.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE zt_r_deltable.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE zt_r_deltable.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE zt_r_deltable.

    METHODS read FOR READ
      IMPORTING keys FOR READ zt_r_deltable RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK zt_r_deltable.

ENDCLASS.

CLASS lhc_zt_r_deltable IMPLEMENTATION.

  METHOD get_global_authorizations.
    result = VALUE #(
      %action-deleteall = if_abap_behv=>auth-allowed
    ).
  ENDMETHOD.

  METHOD deleteall.
    " Activa el flag — el DELETE real se ejecuta en el saver
    lcl_flag=>delete_all = abap_true.
  ENDMETHOD.

  METHOD create.
  ENDMETHOD.

  METHOD update.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

ENDCLASS.

"-------------------------------------------------------
" Behavior Saver — aquí va el DELETE real
"-------------------------------------------------------
CLASS lsc_zt_r_deltable DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS save            REDEFINITION.
    METHODS finalize        REDEFINITION.
    METHODS check_before_save REDEFINITION.
    METHODS cleanup         REDEFINITION.
    METHODS cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_zt_r_deltable IMPLEMENTATION.

  METHOD save.

    IF lcl_flag=>delete_all = abap_true.
      DELETE FROM ztfirncncf_e.                         "#EC CI_NOWHERE
      lcl_flag=>delete_all = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD cleanup.
    lcl_flag=>delete_all = abap_false.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
