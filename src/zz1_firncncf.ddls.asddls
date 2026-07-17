@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS para tabla ZTFIRNCNCF_E'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZZ1_FIRNCNCF
  as select from ztfirncncf_e
{
  key id_uuid               as IdUuid,
      rcn                   as Rcn,
      nombre_comercial      as NombreComercial,
      prefijo               as Prefijo,
      valido_hasta          as ValidoHasta,
      ncfini                as Ncfini,
      ncffin                as Ncffin,
      local_created_by      as LocalCreatedBy,
      local_created_at      as LocalCreatedAt,
      local_last_changed_by as LocalLastChangedBy,
      local_last_changed_at as LocalLastChangedAt,
      last_changed_at       as LastChangedAt
}
