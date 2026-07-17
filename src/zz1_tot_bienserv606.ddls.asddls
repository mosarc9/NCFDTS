@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Total Goods/Service in 606 Rep'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZZ1_TOT_BIENSERV606
  as select from    ZZ1_REP_606      as a
  //    inner join      I_JournalEntryItem as Item  on  a.CompanyCode        = Item.CompanyCode
    inner join      ZZ1_JOURNALENTRY as Item  on  a.CompanyCode        = Item.CompanyCode
                                              and a.FiscalYear         = Item.FiscalYear
                                              and a.AccountingDocument = Item.AccountingDocument
    left outer join ZZ1_MAP606       as Goods on  (
        Item.cta3                                               = Goods.Saknr
        or Item.cta4                                            = Goods.Saknr
      )
                                              and Goods.Gdsserv = '1'
    left outer join ZZ1_MAP606       as Serv  on  (
         Item.cta3                                             = Serv.Saknr
         or Item.cta4                                          = Serv.Saknr
       )
                                              and Serv.Gdsserv = '2'
{
  key a.CompanyCode,
  key a.FiscalYear,
  key Item.AccountingDocument,


      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      sum( case
      when Goods.Saknr is not null and ( Goods.Saknr = Item.cta3 or Goods.Saknr = Item.cta4 ) then abs( Item.AmountInCompanyCodeCurrency )
      else cast( 0 as abap.curr( 23, 2 ) )
      end ) as totalBien,

      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      sum( case
      when Serv.Saknr is not null and ( Serv.Saknr = Item.cta3 or Serv.Saknr = Item.cta4 ) then abs( Item.AmountInCompanyCodeCurrency )
      else cast( 0 as abap.curr( 23, 2 ) )
      end ) as totalServicio,
      Item.CompanyCodeCurrency
}
where
      Item.SourceLedger = '0L'
  and Item.IsReversed   = ''
group by
  a.CompanyCode,
  a.FiscalYear,
  Item.AccountingDocument,
  Item.CompanyCodeCurrency
