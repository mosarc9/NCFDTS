@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Type Goods/Service'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZZ1_TYPE_GS
  as select from ZZ1_TYPE_GS_I
{
  key CompanyCode,
  key FiscalYear,
  key AccountingDocument,
  key Gdsserv,
      max( Dgiitype ) as Dgiitype
}
group by
  CompanyCode,
  FiscalYear,
  AccountingDocument,
  Gdsserv
