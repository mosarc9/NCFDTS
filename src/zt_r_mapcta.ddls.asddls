@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root View - GL Accounts'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true

define root view entity ZT_R_MAPCTA as select from ztab_cta_map
{
  @UI.facet: [{ id: 'General', type: #IDENTIFICATION_REFERENCE, label: 'Configuración', position: 10 }]

  @UI.lineItem:      [{ position: 10, label: 'Cuenta GL Desde' }]
  @UI.identification:[{ position: 10, label: 'Cuenta GL Desde' }]
  @UI.selectionField:[{ position: 10 }]
  @Search.defaultSearchElement: true
  @EndUserText.label: 'Cuenta GL Desde'
  key account_from,

  @UI.lineItem:      [{ position: 20, label: 'Cuenta GL Hasta' }]
  @UI.identification:[{ position: 20, label: 'Cuenta GL Hasta' }]
  @Search.defaultSearchElement: true
  @EndUserText.label: 'Cuenta GL Hasta'
      account_to,

  @UI.lineItem:      [{ position: 30, label: 'Tipo Cuenta' }]
  @UI.identification:[{ position: 30, label: 'Tipo Cuenta' }]
  @UI.selectionField:[{ position: 30 }]
  @Consumption.valueHelpDefinition: [{
    entity: { name: 'ZI_TIPORET_VH', element: 'TipoRet' }
  }]
  @EndUserText.label: 'Tipo Cuenta'
      tipo_ret,

  @UI.lineItem:      [{ position: 40, label: 'Tipo Bien/Servicio DGII (01-11)' }]
  @UI.identification:[{ position: 40, label: 'Tipo Bien/Servicio' }]
  @UI.selectionField:[{ position: 40}]
  @Consumption.valueHelpDefinition: [{
         entity: { name: 'ZI_TIPOBS_VH', element: 'TipoBS' }
  }]
  @EndUserText.label: 'Tipo Bien/Servicio DGII (01-11)'
      tipo_b_s,

  @UI.lineItem:      [{ position: 50, label: 'Descripción' }]
  @UI.identification:[{ position: 50, label: 'Descripción' }]
  @EndUserText.label: 'Descripción'
      descripcion,

  @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at
}
