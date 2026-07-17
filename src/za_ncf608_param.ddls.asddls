@EndUserText.label: 'Abstract Entity - 608 Parameters'
define abstract entity ZA_NCF608_PARAM
{
   @EndUserText.label: 'Sociedad'
    bukrs  : bukrs;

    @EndUserText.label: 'Ejercicio Fiscal'
    gjahr  : gjahr;

    @EndUserText.label: 'Desde'
    p_low  : abap.dats;

    @EndUserText.label: 'Hasta'
    p_high : abap.dats;

    @EndUserText.label: 'Clase de Documento FI'
    blart  : blart;
}
