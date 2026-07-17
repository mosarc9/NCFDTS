@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Total Taxes in 606 Rep'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZZ1_TOT_TAX606
  as select from    ZZ1_REP_606          as a
  //    inner join      I_JournalEntryItem as Item  on  a.CompanyCode        = Item.CompanyCode
    inner join      I_OperationalAcctgDocTaxItem as Item on  a.CompanyCode        = Item.CompanyCode
                                                 and a.FiscalYear         = Item.FiscalYear
                                                 and a.AccountingDocument = Item.AccountingDocument
    left outer join ztax_606             as Tax1 on  Item.TaxCode = Tax1.taxcode
                                                 and Tax1.indtype            = '01'
    left outer join ztax_606             as Tax2 on  Item.TaxCode = Tax2.taxcode
                                                 and Tax2.indtype            = '02'
    left outer join ztax_606             as Tax3 on  Item.TaxCode = Tax3.taxcode
                                                 and Tax3.indtype            = '03'
    left outer join ztax_606             as Tax4 on  Item.TaxCode = Tax4.taxcode
                                                 and Tax4.indtype            = '04'
    left outer join ztax_606             as Tax5 on  Item.TaxCode = Tax5.taxcode
                                                 and Tax5.indtype            = '05'
    left outer join ztax_606             as Tax6 on  Item.TaxCode = Tax6.taxcode
                                                 and Tax6.indtype            = '06'
    left outer join ztax_606             as Tax7 on  Item.TaxCode = Tax7.taxcode
                                                 and Tax7.indtype            = '07'
    left outer join ztax_606             as Tax8 on  Item.TaxCode = Tax8.taxcode
                                                 and Tax8.indtype            = '08'
{
  key a.CompanyCode,
  key a.FiscalYear,
  key Item.AccountingDocument,

      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      sum( case
            when Tax1.indtype is not null then abs( Item.TaxAmountInCoCodeCrcy )
            else cast( 0 as abap.curr( 23, 2 ) )
           end ) as totaltax1,
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      sum( case
            when Tax2.indtype is not null then abs( Item.TaxAmountInCoCodeCrcy )
            else cast( 0 as abap.curr( 23, 2 ) )
           end ) as totaltax2,
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      sum( case
            when Tax3.indtype is not null then abs( Item.TaxAmountInCoCodeCrcy )
            else cast( 0 as abap.curr( 23, 2 ) )
           end ) as totaltax3,
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      sum( case
            when Tax4.indtype is not null then abs( Item.TaxAmountInCoCodeCrcy )
            else cast( 0 as abap.curr( 23, 2 ) )
           end ) as totaltax4,
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      sum( case
            when Tax5.indtype is not null then abs( Item.TaxAmountInCoCodeCrcy )
            else cast( 0 as abap.curr( 23, 2 ) )
           end ) as totaltax5,
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      sum( case
            when Tax6.indtype is not null then abs( Item.TaxAmountInCoCodeCrcy )
            else cast( 0 as abap.curr( 23, 2 ) )
           end ) as totaltax6,
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      sum( case
            when Tax7.indtype is not null then abs( Item.TaxAmountInCoCodeCrcy )
            else cast( 0 as abap.curr( 23, 2 ) )
           end ) as totaltax7,
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      sum( case
            when Tax8.indtype is not null then abs( Item.TaxAmountInCoCodeCrcy )
            else cast( 0 as abap.curr( 23, 2 ) )
           end ) as totaltax8,
      Item.CompanyCodeCurrency
}
group by
  a.CompanyCode,
  a.FiscalYear,
  Item.AccountingDocument,
  Item.CompanyCodeCurrency
