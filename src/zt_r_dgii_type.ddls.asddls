@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root entity - DGII Type'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZT_R_DGII_TYPE
  as select from zdgii_type
{
  key uuid                  as Uuid,
      dgiitype              as Dgiitype,
      descr                 as Descr,
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
