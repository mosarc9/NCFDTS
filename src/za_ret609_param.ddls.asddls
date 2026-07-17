@EndUserText.label: 'Abstract Entity - 609 http parameters'
define abstract entity ZA_RET609_PARAM
  //with parameters parameter_name : parameter_type
{
    @EndUserText.label: 'Sociedad'
    bukrs: bukrs;
    
    @EndUserText.label: 'Ejercicio'
    gjahr: gjahr;
    
    @EndUserText.label: 'Período fiscal'
    poper: abap.numc( 3 );
}
