@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption entity - FIRNCNCF'
//@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZT_C_FIRNCNCF
  provider contract transactional_query
  as projection on ZT_R_FIRNCNCF
{
  key IdUuid,
      Rcn,
      NombreComercial,
      Prefijo,
      ValidoHasta,
      Ncfini,
      Ncffin,
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt
}
