@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption entity - DGII Type'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZT_C_DGII_TYPE
  provider contract transactional_query
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
