@EndUserText.label: 'NCF Anulados 608'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_NCF_ANULADOS608_QUERY'

@UI: {
    headerInfo: { 
        typeName: 'NCF Anulado',
        typeNamePlural: 'NCFs Anulados 608'
    } 
} 

define root custom entity ZCE_NCF_ANULADOS608
 //with parameters 
    //p_bukrs      : bukrs,       -- Sociedad
    //p_gjahr      : gjahr,       -- Ejercicio
    //p_period_low : abap.dats,   -- Desde
    //p_period_high: abap.dats,   -- Hasta
    //P_blart      : blart        -- Clase de Documento FI
{
    @EndUserText.label: 'Documento SD/FI'
    @UI.lineItem: [{ position: 10, label: 'Documento SD/FI' }]
    //@UI.selectionField: [{ position: 10 }]
    key belnr         : belnr_d;  
    
    @UI.lineItem: [{ position: 1, label: 'Descargar 608' }]
    @UI.hidden: true
    download_url : abap.string(0);
    
    @EndUserText.label: 'Documento FI'
    @UI.lineItem: [{ position: 20, label: 'Documento FI' }]
    doc_fi            : belnr_d;

    @EndUserText.label: 'Sociedad'
    @UI.lineItem:       [{ position: 30, label: 'Sociedad' }]
    @UI.selectionField: [{ position: 30 }]
    @Consumption.valueHelpDefinition: [{ 
        entity: { 
            name: 'I_CompanyCode', 
            element: 'CompanyCode'
        }
    }]
    bukrs             : bukrs;

    @EndUserText.label: 'Ejercicio'
    @UI.lineItem: [{ position: 40, label: 'Ejercicio' }]
    @UI.selectionField: [{ position: 40 }]
    gjahr             : gjahr;
    
    @EndUserText.label: 'Segmento'
    @UI.lineItem: [{ position: 50, label: 'Segmento' }]
    segment           : fb_segment;

    @EndUserText.label: 'Desc. Segmento'
    @UI.lineItem: [{ position: 60, label: 'Desc. Segmento' }]
    segment_name      : abap.char(40);
    
    @EndUserText.label: 'NCF'
    @UI.lineItem:       [{ position: 70, label: 'NCF' }]
    @UI.selectionField: [{ position: 70 }]
    ncf               : stceg;
    
    @EndUserText.label: 'Fecha'
    @UI.lineItem: [{ position: 80, label: 'Fecha Comprobante' }]
    @UI.selectionField: [{ position: 80 }]
    fecha_comprobante : abap.dats;

    @EndUserText.label: 'Tipo de Anulación'
    @UI.lineItem: [{ position: 90, label: 'Tipo de Anulación' }]
    tipo_anulacion    : abap.numc( 2 );
    
    //@UI.lineItem: [{ 
    //    type: #FOR_ACTION,
    //    dataAction: 'DescargarArchivo608', 
    //    label: 'Descargar Archivo 608', 
    //    position: 5
    //}]
    //dymmy_action      : abap_boolean; 
    
    @UI.lineItem: [{
        position: 5,
        label: ' * ',
        type: #WITH_URL,
        url: 'download_url'
    }]
    dummyaction : abap.char(25);
    
}
