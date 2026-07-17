@EndUserText.label: 'IT-1 DGII'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_CE_IT1_QUERY'
@Metadata.allowExtensions: true
define custom entity ZCE_IT1_MAIN
{
  key casilla     : abap.numc(3);
      periodo     : abap.char(7);
      bukrs       : bukrs;
      seccion     : abap.char(60);
      descripcion : abap.char(150);
      operacion   : abap.char(5);
      monto       : abap.dec(15,2);
}
