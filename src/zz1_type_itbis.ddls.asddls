@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ISR Type'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZZ1_TYPE_ITBIS
  as select from ZZ1_REP_606        as a
    inner join   I_JournalEntryItem as Item on  a.CompanyCode        = Item.CompanyCode
                                            and a.FiscalYear         = Item.FiscalYear
                                            and a.AccountingDocument = Item.AccountingDocument
    inner join   ztax_606           as b    on Item.TaxCode = b.taxcode
{
  key a.CompanyCode,
  key a.FiscalYear,
  key a.AccountingDocument,
      b.taxcode
}
