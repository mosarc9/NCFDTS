@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption entity - Conf. NCF'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZT_C_CONF_NCF
  provider contract transactional_query
  as projection on ZT_R_CONF_NCF
{
  key IdUuid,
      //      @Search.defaultSearchElement: true
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CompanyCodeVH',
                                                    element: 'CompanyCode' },
                                          useForValidation: true }]
      @ObjectModel.text.element: [ 'CompanyCodeName' ]
      Bukrs,
      _CompanyCode.CompanyCodeName,

      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_PlantStdVH',
                                                   element: 'Plant' },
                                         useForValidation: true }]
      @ObjectModel.text.element: [ 'PlantName' ]
      Plant,
      _Plant.PlantName,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZZ1_accountingdoctypetext_vh',
                                                   element: 'AccountingDocumentType' },
                                         useForValidation: true }]
//      @ObjectModel.text.element: [ 'AccountingDocumentTypeName' ]
      ClDoc,
//      AccountingDocumentTypeName : localized,
      
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZZ1_MODULES_VH',
                                                  element: 'Staging' },
                                        useForValidation: true }]
                                              
      Modulo,
      Stcdc,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZZ1_SERIE_VH',
                                                  element: 'Staging' },
                                        useForValidation: true }]
      Serie,
      Znrnr,
      IsDpp,

      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,
      /* Associations */
      _CompanyCode,
      _DocType
}
