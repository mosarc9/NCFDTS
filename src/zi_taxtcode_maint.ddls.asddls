@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root View - Mantenimiento ITBIS'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true
@UI.headerInfo: {
    typeName: 'Tax Code',
    typeNamePlural: 'Tax Codes'
}
define root view entity zi_taxtcode_maint 

as select from ztab_tc
{
    @UI.facet: [ { id: 'General', type: #IDENTIFICATION_REFERENCE, label: 'Configuración', position: 10 } ]
        
          @UI.lineItem:       [ { position: 10, label: 'Código Impuesto' } ]
          @UI.selectionField: [ { position: 10 } ]
          @UI.identification: [ { position: 10 } ]
          @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_TAXCODE_VH', element: 'TaxCode' } }]
          
          @Search.defaultSearchElement: true -- ESTA ES LA QUE TE FALTA
          @Search.fuzzinessThreshold: 0.8    -- Opcional: permite errores tipográficos leves
          @EndUserText.label: 'Código Impuesto'
      key tax_code,
    
    
          @UI.lineItem:       [ { position: 20, label: 'Tasa ITBIS (%)' } ]
          @UI.selectionField: [ { position: 20 } ]
          @UI.identification: [ { position: 20 } ]
          @EndUserText.label: 'Tasa ITBIS'
          @Consumption.valueHelpDefinition: [{ 
            entity: { name: 'ZI_ITBIS_RATE_VH', element: 'ItbisRate' },
            additionalBinding: [ { localElement: 'itbis_rate', element: 'ItbisRate' } ]
          }]
          itbis_rate,
    
          @Semantics.systemDateTime.lastChangedAt: true
          last_changed_at
}
