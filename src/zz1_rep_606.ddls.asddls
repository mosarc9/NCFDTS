@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Reporte DGII 606'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZZ1_REP_606
  as select from    I_JournalEntry     as JE
    left outer join I_JournalEntryItem as Item on  JE.CompanyCode        = Item.CompanyCode
                                               and JE.FiscalYear         = Item.FiscalYear
                                               and JE.AccountingDocument = Item.AccountingDocument
                                               and Item.SourceLedger     = '0L'

{
  key JE.CompanyCode,
  key JE.FiscalYear,
  key Item.AccountingDocument,
  key cast( substring(JE.DocumentDate, 5, 2) as abap.numc( 2 ) )                          as FMonth,
  key Item.Supplier                                                                       as Supplier,
      cast( concat(JE.FiscalYear, substring(JE.DocumentDate, 5, 2)  ) as abap.numc( 6 ) ) as Periodo,
      JE.DocumentDate,
      JE.AccountingDocumentHeaderText,
      Item.InvoiceReference,
      Item.GLAccount,
      Item.ClearingDate


}
where
  (
           -- Grupo Serie B
           (
             (
               substring( JE.AccountingDocumentHeaderText, 1, 3 )    = 'B01'
               or substring( JE.AccountingDocumentHeaderText, 1, 3 ) = 'B02'
               or substring( JE.AccountingDocumentHeaderText, 1, 3 ) = 'B03'
               or substring( JE.AccountingDocumentHeaderText, 1, 3 ) = 'B04'
               or substring( JE.AccountingDocumentHeaderText, 1, 3 ) = 'B11'
               or substring( JE.AccountingDocumentHeaderText, 1, 3 ) = 'B13'
               or substring( JE.AccountingDocumentHeaderText, 1, 3 ) = 'B14'
               or substring( JE.AccountingDocumentHeaderText, 1, 3 ) = 'B15'
               or substring( JE.AccountingDocumentHeaderText, 1, 3 ) = 'B16'
               or substring( JE.AccountingDocumentHeaderText, 1, 3 ) = 'B17'
             )
             and  length( JE.AccountingDocumentHeaderText )          = 11
           )
    or
    -- Grupo Serie E (e-NCF)
    (
      (
           substring( JE.AccountingDocumentHeaderText, 1, 3 )        = 'E31'
        or substring( JE.AccountingDocumentHeaderText, 1, 3 )        = 'E32'
        or substring( JE.AccountingDocumentHeaderText, 1, 3 )        = 'E33'
        or substring( JE.AccountingDocumentHeaderText, 1, 3 )        = 'E34'
        or substring( JE.AccountingDocumentHeaderText, 1, 3 )        = 'E41'
        or substring( JE.AccountingDocumentHeaderText, 1, 3 )        = 'E43'
        or substring( JE.AccountingDocumentHeaderText, 1, 3 )        = 'E44'
        or substring( JE.AccountingDocumentHeaderText, 1, 3 )        = 'E45'
        or substring( JE.AccountingDocumentHeaderText, 1, 3 )        = 'E46'
        or substring( JE.AccountingDocumentHeaderText, 1, 3 )        = 'E47'
      )
      and  length( JE.AccountingDocumentHeaderText )                 = 13
    )
  )
  -- Filtros globales (se aplican a ambos grupos)
  and      JE.ReversalReason                                         is initial
  and      JE.ReverseDocument                                        is initial
  and      Item.Supplier                                             is not initial
  and      Item.IsReversed                                           = ''
  and      Item.FinancialAccountType                                 = 'K'
