@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface entity - DGII Type'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZT_I_DGII_TYPE
  provider contract transactional_interface
  as projection on ZT_R_DGII_TYPE
{
  key Uuid,
      Dgiitype,
      Descr,
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt
}
