@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root entity - Tax 606'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZT_R_ISR606
  as select from zisr_606
    association [0..1] to ZZ1_ISRTYPES_VH as _Ind on $projection.Isrtype = _Ind.Staging

{
  key uuid                  as Uuid,
      isrcode               as Taxcode,
      isrtype               as Isrtype,
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
