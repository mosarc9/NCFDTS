@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS for Table ZDGII_TYPE'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZZ1_DGII_TYPE
  as select from zdgii_type
{
  key dgiitype              as Dgiitype,
      descr                 as Descr
//      local_created_by      as LocalCreatedBy,
//      local_created_at      as LocalCreatedAt,
//      local_last_changed_by as LocalLastChangedBy,
//      local_last_changed_at as LocalLastChangedAt,
//      last_changed_at       as LastChangedAt
}
