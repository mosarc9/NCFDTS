@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface entity - FIRNCNCF'
//@Metadata.ignorePropagatedAnnotations: true
define root view entity ZT_I_FIRNCNCF
  provider contract transactional_interface
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
