@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root entity - FIRNCNCF'
//@Metadata.ignorePropagatedAnnotations: true
define root view entity ZT_R_FIRNCNCF
  as select from ztfirncncf_e

{
  key id_uuid               as IdUuid,
      rcn                   as Rcn,
      nombre_comercial      as NombreComercial,
      prefijo               as Prefijo,
      valido_hasta          as ValidoHasta,
      ncfini                as Ncfini,
      ncffin                as Ncffin,
      @Semantics.user.createdBy: true
      local_created_by      as LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      local_created_at      as LocalCreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      local_last_changed_by as LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt

}
