@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Reporte DGII 606 Items'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZZ1_606_ITEMS
  as select from ZZ1_REP_606
  association [0..1] to I_JournalEntry as _JE on  $projection.CompanyCode      = _JE.CompanyCode
                                              and $projection.FiscalYear       = _JE.FiscalYear
                                              and $projection.InvoiceReference = _JE.AccountingDocument
  //  association [0..1] to I_Supplier     as _Supplier on  $projection.Supplier = _Supplier.Supplier
  //  association [0..1] to ZZ1_MAP606     as _Map606   on  $projection.GLAccount = _Map606.Saknr

{
  key CompanyCode,
  key FiscalYear,
  key AccountingDocument,
  key FMonth,
  key Supplier,
      AccountingDocumentHeaderText, // NCF
      InvoiceReference, // NCF ó Documento Modificado
      DocumentDate, // Fecha Comprobante
      ClearingDate, // Fecha Pago
      _JE.AccountingDocumentHeaderText as NCFMod,
      
      _JE
}
group by
  CompanyCode,
  FiscalYear,
  AccountingDocument,
  Supplier,
  FMonth,
  AccountingDocumentHeaderText,
  InvoiceReference,
  DocumentDate,
  ClearingDate,
  _JE.AccountingDocumentHeaderText
//where
//  SourceLedger = '0L'
