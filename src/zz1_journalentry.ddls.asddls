@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Journal Entry'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZZ1_JOURNALENTRY
  as select from I_JournalEntryItem
{
  key     CompanyCode,
  key     FiscalYear,
  key     AccountingDocument,
  key     substring( ltrim( GLAccount, '0' ),1, 3) as cta3,
  key     substring( ltrim( GLAccount, '0' ),1, 4) as cta4,
          CompanyCodeCurrency,
          GLAccount,
          SourceLedger,
          IsReversed,
          @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
          AmountInCompanyCodeCurrency

}
where SourceLedger = '0L'
