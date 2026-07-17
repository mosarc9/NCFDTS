@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption entity - Tax 606'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
//@Search.searchable: true
define root view entity ZT_C_TAX606
  provider contract transactional_query
  as projection on zt_r_tax606
{
  key Uuid,
//      @Search.defaultSearchElement: true
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZZ1_TAXCODE_VH',
                                                   element: 'TaxCode' },
                                         useForValidation: true }]
      Taxcode,

      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZZ1_INDTYPES_VH',
                                                    element: 'Staging' },
                                          useForValidation: true }]
      @ObjectModel.text.element: [ 'Description' ]                                          
      Indtype,
       _Ind.Description,
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,
      
       _Ind
}
