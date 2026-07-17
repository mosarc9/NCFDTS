@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root entity - Conf. NCF'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZT_R_CONF_NCF
  as select from zconfi_ncf
  association [0..1] to I_CompanyCode         as _CompanyCode on $projection.Bukrs = _CompanyCode.CompanyCode
  association [0..1] to I_BillingDocumentType as _DocType     on $projection.ClDoc = _DocType.BillingDocumentType
  association [0..1] to I_Plant               as _Plant       on $projection.Plant = _Plant.Plant

{

  key id_uuid               as IdUuid,
      bukrs                 as Bukrs,
      werks                 as Plant,
      cl_doc                as ClDoc,
      modulo                as Modulo,
      stcdc                 as Stcdc,
      znrnr                 as Znrnr,
      serie                 as Serie,
      is_dpp                as IsDpp,
      @Semantics.user.createdBy: true
      local_created_by      as LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      local_created_at      as LocalCreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      local_last_changed_by as LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,

      _CompanyCode,
      _DocType,
      _Plant
}
