@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption entity - Map 606'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@Search.searchable: true
define root view entity zt_c_606
  provider contract transactional_query
  as projection on ZT_R_606
{
  key Uuid,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_GLAccountStdVH',
                                                    element: 'GLAccount' },
                                          useForValidation: true }]
      Saknr,
      @ObjectModel.text.element: [ 'Descr' ]
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZZ1_DGII_TYPE',
                                                   element: 'Dgiitype' },
                                         useForValidation: true }]
      @Search.defaultSearchElement: true
      Dgiitype,
      _Dgii.Descr as Descr,
      @ObjectModel.text.element: [ 'Description' ]
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZZ1_GDSSERV_VH',
                                                   element: 'Staging' },
                                         useForValidation: true }]
      Gdsserv,
      _GdsServ.Description,

      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,

      /* Associations */
      _GdsServ,
      _Dgii,
      _AccountText
}
