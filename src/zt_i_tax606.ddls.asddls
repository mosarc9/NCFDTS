@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface entity - Tax 606'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZT_I_TAX606
  provider contract transactional_interface
  as projection on zt_r_tax606
{
  key Uuid,
      Taxcode,
      Indtype,
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,
      
       _Ind
}
