@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help - Tax Code'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true                 

@UI.headerInfo: {
    typeName: 'Código de Impuesto',
    typeNamePlural: 'Códigos de Impuestos'
}

define view entity ZI_TAXCODE_VH as select from I_TaxCode
{
 
      @UI.lineItem:       [ { position: 10, label: 'Código Impuesto' } ]
      @UI.selectionField: [ { position: 10 } ]
      @UI.identification: [ { position: 10 } ]
      @Search.defaultSearchElement: true
      @EndUserText.label: 'Código Impuesto'
  key TaxCode, 
  
      @UI.lineItem:       [ { position: 20, label: 'Código procedencia' } ]
      @UI.selectionField: [ { position: 20 } ]
      @UI.identification: [ { position: 20 } ]      
      @EndUserText.label: 'Procedencia'
  key TaxCalculationProcedure
}
