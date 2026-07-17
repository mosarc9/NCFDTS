@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ISR Type'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZZ1_TYPE_ISR
  as select from ZZ1_REP_606          as a
    inner join   I_Withholdingtaxitem as Item on  a.CompanyCode        = Item.CompanyCode
                                              and a.FiscalYear         = Item.FiscalYear
                                              and a.AccountingDocument = Item.AccountingDocument
    inner join   zisr_606             as b    on  Item.WithholdingTaxCode = b.isrcode
                                              and Item.WithholdingTaxType = 'IS'
{
  key a.CompanyCode,
  key a.FiscalYear,
  key a.AccountingDocument,
      b.isrcode,
      b.isrtype
}
