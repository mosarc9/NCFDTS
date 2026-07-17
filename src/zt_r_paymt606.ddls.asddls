@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root entity - Payment 606'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZT_R_PAYMT606
  as select from zpaymt_606
  association [0..1] to ZZ1_PAYMENTMT_VH as _Ind on $projection.Paymt = _Ind.Staging

{
  key uuid                     as Uuid,
      paykey                   as Paykey,
      paymt                    as Paymt,

      @Semantics.user.createdBy: true
      local_created_by         as LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      local_created_at         as LocalCreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      local_last_changed_by    as LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at    as LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at          as LastChangedAt,

      _Ind

}
