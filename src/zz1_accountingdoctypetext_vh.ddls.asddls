
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'VH for Accounting Doc. Type'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.dataCategory: #TEXT
@ObjectModel.representativeKey: 'AccountingDocumentType'
@Search.searchable: true
define view entity ZZ1_accountingdoctypetext_vh
  as select from I_AccountingDocumentTypeText
{

      @ObjectModel.text.element: [ 'AccountingDocumentTypeName' ]
  key AccountingDocumentType,
      @Semantics.language
  key Language,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @Search.ranking: #HIGH
      @Semantics.text
      AccountingDocumentTypeName,
      /* Associations */
      _DocumentType,
      _Language

}
where
  Language = $session.system_language
