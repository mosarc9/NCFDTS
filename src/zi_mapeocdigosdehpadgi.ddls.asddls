@EndUserText.label: 'Mapeo Códigos de  HP a DGII'
@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
define view entity ZI_MapeoCDigosDeHpADgi
  as select from ZDGII_CODOFICIAL
  association to parent ZI_MapeoCDigosDeHpADgi_S as _MapeoCDigosDeHpAAll on $projection.SingletonID = _MapeoCDigosDeHpAAll.SingletonID
{
  key CUSTOM_CODE as CustomCode,
  DGII_CODE as DgiiCode,
  DESCRIPTION as Description,
  @Consumption.hidden: true
  1 as SingletonID,
  _MapeoCDigosDeHpAAll
}
