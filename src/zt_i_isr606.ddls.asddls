@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface entity - Tax 606'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZT_I_ISR606
  provider contract transactional_interface
  as projection on ZT_R_ISR606
{
  key Uuid,
      Taxcode,
      Isrtype,
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,
      
       _Ind
}
