@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root View - Map Doc Type'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true

@UI.headerInfo: { typeName: 'Tipo Documento', typeNamePlural: 'Tipos de Documento' }
define root view entity ZT_R_MAPDT
  as select from ztab_dt_map
{
  @UI.facet: [{ id: 'General', type: #IDENTIFICATION_REFERENCE, label: 'Configuración', position: 10 }]

      @UI.lineItem:      [{ position: 10, label: 'Tipo Doc' }]
      @UI.identification:[{ position: 10, label: 'Tipo Doc' }]
      @UI.selectionField:[{ position: 10 }]
      @EndUserText.label: 'Tipo Doc'
      @Search.defaultSearchElement: true
  key doc_type,

      @UI.lineItem:      [{ position: 20, label: 'Código Informe (606/607)' }]
      @UI.identification:[{ position: 20, label: 'Código Informe' }]
      @UI.selectionField:[{ position: 20 }]
      @Consumption.valueHelpDefinition: [{                        
         entity: { name: 'ZI_CODINF_VH', element: 'cod_inf' }    
      }]   
      @EndUserText.label: 'Código Informe'
      cod_inf,

      @UI.lineItem:      [{ position: 30, label: 'Descripción' }]
      @UI.identification:[{ position: 30, label: 'Descripción' }]
      @EndUserText.label: 'Descripción'
      descripcion,
    
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at
}
