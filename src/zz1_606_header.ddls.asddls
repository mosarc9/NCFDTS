@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Reporte DGII 606 Header'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZZ1_606_HEADER
  as select from ZZ1_REP_606 as Header
  //    association [0..1] to I_Supplier as _Supplier on $projection.Supplier = _Supplier.Supplier
{
  key CompanyCode,
  key FiscalYear,
  key FMonth,
      Periodo,
      count( * ) as total

}
group by
  CompanyCode,
  FiscalYear,
  FMonth,
  Periodo
