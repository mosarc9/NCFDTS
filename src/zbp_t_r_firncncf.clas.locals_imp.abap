CLASS lhc_firncncf DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR firncncf RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR firncncf RESULT result.

    METHODS precheck_update FOR PRECHECK
      IMPORTING entities FOR UPDATE firncncf.

    METHODS resume FOR MODIFY
      IMPORTING keys FOR ACTION firncncf~resume.

    METHODS uploadtxt FOR MODIFY
      IMPORTING keys FOR ACTION firncncf~uploadtxt.

    METHODS validatercn FOR VALIDATE ON SAVE
      IMPORTING keys FOR firncncf~validatercn.
    METHODS get_global_features FOR GLOBAL FEATURES
      IMPORTING REQUEST requested_features FOR firncncf RESULT result.

ENDCLASS.

CLASS lhc_firncncf IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD precheck_update.
  ENDMETHOD.

  METHOD resume.
  ENDMETHOD.

  METHOD uploadtxt.




  ENDMETHOD.

  METHOD validatercn.
  ENDMETHOD.

  METHOD get_global_features.
  ENDMETHOD.

ENDCLASS.
