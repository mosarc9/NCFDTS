@EndUserText.label: 'Custom Entity - IR17'
@Metadata.allowExtensions: true
@ObjectModel.query.implementedBy: 'ABAP:ZCL_CE_IR17_QUERY'
define custom entity ZCE_IR17
{
  key linea             : abap.numc( 2 ); 
  
  // --- Columnas visibles ---
  concepto_izq          : abap.char(30);
  valor_izq             : abap.char(50);
  no_ret                : abap.char(3);
  concepto_ret          : abap.char(60);
  monto                 : abap.dec(15,2);
  tasa                  : abap.dec(5,2);
  importe               : abap.dec(15,2);
  
 @Consumption.filter: { selectionType: #SINGLE, mandatory: true }
 @EndUserText.label: 'Sociedad'
 p_bukrs               : abap.char(4);  

  // --- Campos de filtro (solo barra de seleccion, no columnas) ---
  @Consumption.filter: { selectionType: #SINGLE, mandatory: true }
  @EndUserText.label: 'Periodo (MM-YYYY)'
  p_periodo             : abap.char(7);
  
  @Consumption.filter: { selectionType: #SINGLE }
  @EndUserText.label: 'Fecha Limite Presentacion (DD/MM/YYYY)'
  p_fecha_limite        : abap.dats;

  @Consumption.filter: { selectionType: #SINGLE, defaultValue: 'NORMAL' }
  @EndUserText.label: 'Tipo de Declaracion'
  p_tipo_declaracion    : abap.char(20);

  @Consumption.filter: { selectionType: #SINGLE }
  @EndUserText.label: 'Premios'
  p_premios             : abap.dec(15,2);

  @Consumption.filter: { selectionType: #SINGLE }
  @EndUserText.label: 'Tasa Premios'
  p_tasa_premios        : abap.dec(5,2);

  @Consumption.filter: { selectionType: #SINGLE }
  @EndUserText.label: 'Ret. Complementarias'
  p_ret_complementarias : abap.dec(15,2);

  //@Consumption.filter: { selectionType: #SINGLE }
  //@EndUserText.label: 'Tasa Ret. Complementarias'
  //p_tasa_ret_compl      : abap.dec(5,2);
  
  // --- Campo para link al PDF (ultima fila) ---
  pdf_link              : abap.char(20);
  pdf_url               : abap.char(1000);
}
