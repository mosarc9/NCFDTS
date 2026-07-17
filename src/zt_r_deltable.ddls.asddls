@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Delete table NCF/RCN'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZT_R_DELTABLE
  as select from ztfirncncf_e
{
  key id_uuid          as IdUuid,
      rcn              as Rcn,
      nombre_comercial as NombreComercial,
      prefijo          as Prefijo,
      valido_hasta     as ValidoHasta,
      ncfini           as Ncfini,
      ncffin           as Ncffin
}
