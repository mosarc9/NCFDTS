@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS para tabla ZCONFIG_NCF'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZZ1_CONFIG_NCF
  as select from zconfi_ncf
{

  key id_uuid               as IdUuid,
      bukrs                 as Bukrs,
      werks                 as Werks,
      cl_doc                as ClDoc,
      modulo                as Modulo,
      stcdc                 as Stcdc,
      serie                 as Serie,
      znrnr                 as Znrnr,
      is_dpp                as IsDpp,
      local_created_by      as LocalCreatedBy,
      local_created_at      as LocalCreatedAt,
      local_last_changed_by as LocalLastChangedBy,
      local_last_changed_at as LocalLastChangedAt,
      last_changed_at       as LastChangedAt
}
