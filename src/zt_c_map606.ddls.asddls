@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption entity - Map 606'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
//@Search.searchable: true
define root view entity ZT_C_MAP606
  provider contract transactional_query
  as projection on ZT_R_MAP606
{
  key Uuid,
//      @Search.defaultSearchElement: true
//      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_GLAccountInCompanyCodeStdVH',
//                                                   element: 'GLAccount' },
//                                         useForValidation: true }]

    @EndUserText.label: 'Cód.Cuenta'
      Saknr,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZZ1_DGII_TYPE',
                                                    element: 'Dgiitype' },
                                         useForValidation: true
                                          }]
//      @Search.defaultSearchElement: true
      @ObjectModel.text.element: [ 'Descr' ]                         
      Dgiitype,
      _Dgii.Descr,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZZ1_GDSSERV_VH',
                                                   element: 'Staging' },
                                         useForValidation: true }]
      @ObjectModel.text.element: [ 'Description' ]                                         
      Gdsserv,
      _GdsServ.Description,
      
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,
      /* Associations */
      _AccountText,
      _Dgii,
      _GdsServ
}
