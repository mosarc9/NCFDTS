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
    
    left outer join ZZ1_MAP606 as Goods4 on Goods4.Saknr = Item.cta4 and Goods4.Gdsserv = '1'
    
    left outer join ZZ1_MAP606 as Goods3 on Goods3.Saknr = Item.cta3 and Goods3.Gdsserv = '1'
    
    left outer join ZZ1_MAP606 as Serv4 on Serv4.Saknr = Item.cta4 and Serv4.Gdsserv = '2'
    
    left outer join ZZ1_MAP606 as Serv3 on Serv3.Saknr = Item.cta3 and Serv3.Gdsserv = '2'
{
  key a.CompanyCode,
  key a.FiscalYear,
  key Item.AccountingDocument,


      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      sum(
          case
            when Goods4.Saknr is not null
              then abs( Item.AmountInCompanyCodeCurrency )
        
            when Goods4.Saknr is null
             and Goods3.Saknr is not null
              then abs( Item.AmountInCompanyCodeCurrency )
        
            else cast( 0 as abap.curr(23,2) )
          end
    ) as totalBien,

      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      sum(
          case
            when Serv4.Saknr is not null
              then abs( Item.AmountInCompanyCodeCurrency )
        
            when Serv4.Saknr is null
             and Serv3.Saknr is not null
              then abs( Item.AmountInCompanyCodeCurrency )
        
            else cast( 0 as abap.curr(23,2) )
          end
        ) as totalServicio,
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
