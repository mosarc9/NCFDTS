@EndUserText.label: 'Custom Entity - Reporte retenciones 609'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_RET609_QUERY'

@UI: {
    headerInfo: { 
        typeName: 'Retención: 609',
        typeNamePlural: 'Retenciones: 609'
    } 
} 
define custom entity ZCE_RET609
{
  
  @EndUserText.label: 'Sociedad' 
  @UI.lineItem: [{ position: 10, label: 'Sociedad' }]
  @UI.selectionField: [{ position: 10 }]
  key bukrs: bukrs;
  
  @EndUserText.label: 'Ejercicio' 
  @UI.lineItem: [{ position: 20, label: 'Ejercicio' }]
  @UI.selectionField: [{ position: 20 }]
  key gjahr: gjahr;
  
  @EndUserText.label: 'Periodo' 
  @UI.lineItem: [{ position: 30, label: 'Período' }]
  @UI.selectionField: [{ position: 30 }]
  key poper: abap.numc( 3 ); 
  
  @UI.lineItem: [{ position: 40, label: 'Documento' }]
  key accounting_document: belnr_d; 
  
  @UI.lineItem: [{ position: 50, label: 'Acreedor' }]
  key supplier: lifnr;
  
    @UI.lineItem: [{ position: 60, label: 'Nombre' }]
  supplier_name        : abap.char(80);

  @UI.lineItem: [{ position: 70, label: 'RNC/Cédula' }]
  tax_number           : stceg;

  @UI.lineItem: [{ position: 80, label: 'Tipo ID' }]
  tipo_id              : abap.char(1);

  @UI.lineItem: [{ position: 90, label: 'País DGII' }]
  country_dgii         : abap.char(3);

  @UI.lineItem: [{ position: 100, label: 'NCF' }]
  ncf                  : stceg;

  @UI.lineItem: [{ position: 110, label: 'Fecha Factura' }]
  fecha_factura        : abap.dats;

  @UI.lineItem: [{ position: 120, label: 'Fecha Retención' }]
  fecha_retencion      : abap.dats;

  @UI.lineItem: [{ position: 130, label: 'Monto Factura' }]
  monto_factura        : abap.dec(16,2);

  @UI.lineItem: [{ position: 140, label: 'ITBIS Retenido' }]
  itbis_retenido       : abap.dec(16,2);

  @UI.lineItem: [{ position: 150, label: 'ISR Retenido' }]
  isr_retenido         : abap.dec(16,2);

  @UI.lineItem: [{ position: 160, label: 'Tipo Servicio' }]
  tipo_servicio        : abap.char(2);

  @UI.lineItem: [{ position: 170, label: 'Cod. Retención ISR' }]
  whtax_code_isr       : abap.char(4);
  
  @UI.lineItem: [{ position: 180, label: 'Renta Presunta' }]
  renta_presunta       : abap.dec(16,2);
  
  @UI.hidden: true
  url_descarga: abap.string( 0 ); 
  
  @UI.lineItem: [{
    type: #WITH_URL,
    url: 'url_descarga',
    label: ' * ',
    position: 5
  }]
  url_text         : abap.char(20);   // Texto visible: 'Descargar Reporte 609'
}
