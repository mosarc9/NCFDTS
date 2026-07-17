@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Total Amounts in 606 Rep'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZZ1_TOTALES_606
  as select from    I_JournalEntryItem as Item
    inner join      ZZ1_REP_606        as a     on  Item.CompanyCode = a.CompanyCode
                                                and Item.FiscalYear  = a.FiscalYear
                                                and Item.Supplier    = a.Supplier
    left outer join ZZ1_MAP606         as Goods on  Item.GLAccount = Goods.Saknr
                                                and Goods.Gdsserv  = '1'
    left outer join ZZ1_MAP606         as Serv  on  Item.GLAccount = Serv.Saknr
                                                and Serv.Gdsserv   = '2'
{
  key Item.CompanyCode,
  key Item.FiscalYear,
  key Item.AccountingDocument,

      @Semantics.amount.currencyCode: 'TransactionCurrency'
      sum( case
            when Goods.Saknr is not null then Item.AmountInTransactionCurrency
            else cast( 0 as abap.curr( 23, 2 ) )
           end ) as totalBien,

      @Semantics.amount.currencyCode: 'TransactionCurrency'
      sum( case
            when Serv.Saknr is not null then Item.AmountInTransactionCurrency
            else cast( 0 as abap.curr( 23, 2 ) )
           end ) as totalServicio,
      Item.TransactionCurrency
}
where
      Item.SourceLedger = '0L'
  and Item.IsReversed   = ''
group by
  Item.CompanyCode,
  Item.FiscalYear,
  Item.AccountingDocument,
  Item.TransactionCurrency
