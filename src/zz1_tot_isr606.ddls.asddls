@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Total ISR'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZZ1_TOT_ISR606
  as select from    ZZ1_REP_606        as a
    inner join      I_Withholdingtaxitem as Item on  a.CompanyCode        = Item.CompanyCode
                                               and a.FiscalYear         = Item.FiscalYear
                                               and a.AccountingDocument = Item.AccountingDocument
    left outer join zisr_606           as Tax1 on  Item.WithholdingTaxCode = Tax1.isrcode
                                              
//    left outer join zisr_606           as Tax2 on  Item.TaxCode = Tax2.isrcode
//                                               and Tax2.isrtype = '02'

{
  key a.CompanyCode,
  key a.FiscalYear,
  key Item.AccountingDocument,
      Item.WithholdingTaxType,
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      sum( case
            when Tax1.isrtype is not null and Item.WithholdingTaxType = 'IS'
                then abs( Item.WhldgTaxAmtInCoCodeCrcy )
            else cast( 0 as abap.curr( 23, 2 ) )
           end ) as totalisr1,
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      sum( case
            when Tax1.isrtype is not null and Item.WithholdingTaxType = 'IB'
                then abs( Item.WhldgTaxAmtInCoCodeCrcy )
            else cast( 0 as abap.curr( 23, 2 ) )
           end ) as totalTaxRet,
      Item.CompanyCodeCurrency
}
group by
  a.CompanyCode,
  a.FiscalYear,
  Item.AccountingDocument,
  Item.WithholdingTaxType,
  Item.CompanyCodeCurrency
