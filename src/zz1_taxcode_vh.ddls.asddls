@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Tax Codes'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true
define view entity ZZ1_TAXCODE_VH
  as select from I_TaxCodeText as I_TaxCode
{
  key TaxCalculationProcedure,
      @Search.defaultSearchElement: true
      @Search.ranking: #HIGH
      @Search.fuzzinessThreshold: 0.8
  key TaxCode,
      Language,
      @Search.defaultSearchElement: true
      TaxCodeName
}
where
       TaxCalculationProcedure = '0TXDO' and  
       ( Language                = 'E' or
         Language                = 'S')
   
//  Language = $session.system_language
