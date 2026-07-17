@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS for table ZPENDING_NCF'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType: {
  serviceQuality: #X,
  sizeCategory: #S,
  dataClass: #MIXED
}
define view entity ZZ1_ZPENDING_NCF
  as select from zpending_ncf
{
  key  accounting_document as AccountingDocument,
  key  company_code        as CompanyCode,
  key  fiscal_year         as FiscalYear,
       vendor              as Vendor,
       supplier_invoice    as SupplierInvoice,
       ncf                 as Ncf,
       status              as Status,
       created_at          as CreatedAt,
       created_by          as CreatedBy
}
