@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption entity - Tax 606'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
//@Search.searchable: true
define root view entity ZT_C_ISR606
  provider contract transactional_query
  as projection on ZT_R_ISR606
{
  key Uuid,
//      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZZ1_TAXCODE_VH',
//                                                   element: 'TaxCode' },
//                                         useForValidation: true }]
      
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZZ1_TIPOS_RETENCION',
                                           element: 'WithholdingTaxCode' },
                                  useForValidation: true }]                               
      @EndUserText.label: 'Indicador de Retención'                                           
      Taxcode,

      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZZ1_ISRTYPES_VH',
                                                    element: 'Staging' },
                                          useForValidation: true }]
      @ObjectModel.text.element: [ 'Description' ]                                          
      Isrtype,
       _Ind.Description,
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,
      
       _Ind
}
