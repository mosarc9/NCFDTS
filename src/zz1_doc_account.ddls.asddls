@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Accounting document Account'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZZ1_DOC_ACCOUNT
  as select from I_JournalEntryItem as a inner join ZZ1_REP_606 as b on a.CompanyCode        = b.CompanyCode
                                                                    and a.FiscalYear         = b.FiscalYear
                                                                    and a.AccountingDocument = b.AccountingDocument
{
  key     a.CompanyCode,
  key     a.FiscalYear,
  key     a.AccountingDocument,
  key     substring( ltrim( a.GLAccount, '0' ),1, 3) as cta3,
  key     substring( ltrim( a.GLAccount, '0' ),1, 4) as cta4,
          a.CompanyCodeCurrency,
          a.GLAccount

}
where
      a.SourceLedger =  '0L'
  and a.IsReversed   <> 'X'
group by a.CompanyCode, a.FiscalYear, a.AccountingDocument, a.CompanyCodeCurrency, a.GLAccount
