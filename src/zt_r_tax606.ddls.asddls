@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root entity - Tax 606'
@Metadata.ignorePropagatedAnnotations: true
define root view entity zt_r_tax606
  as select from ztax_606
    association [0..1] to ZZ1_INDTYPES_VH as _Ind on $projection.Indtype = _Ind.Staging

{
  key uuid                  as Uuid,
      taxcode               as Taxcode,
      indtype               as Indtype,
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
      
      _Ind

}
