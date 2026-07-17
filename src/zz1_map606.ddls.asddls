@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS for Table ZMAP_606'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZZ1_MAP606
  as select from zmap_606
{
      //    key uuid as Uuid,
  key saknr    as Saknr,
      dgiitype as Dgiitype,
      gdsserv  as Gdsserv
      //    local_created_by as LocalCreatedBy,
      //    local_created_at as LocalCreatedAt,
      //    local_last_changed_by as LocalLastChangedBy,
      //    local_last_changed_at as LocalLastChangedAt,
      //    last_changed_at as LastChangedAt
}
