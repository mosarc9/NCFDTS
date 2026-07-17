@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface entity - Payment 606'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZT_I_PAYMT606
  provider contract transactional_interface
  as projection on ZT_R_PAYMT606
{
  key Uuid,
      Paykey,
      Paymt,

      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,
      
       _Ind
}
