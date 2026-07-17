@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface entity - 606 Header'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZT_I_H606
  provider contract transactional_interface
  as projection on ZT_R_H606

{
  key CompanyCode,
  key FiscalYear,
  key FMonth,
      Periodo
      /* Associations */
  ,
      _Items : redirected to composition child ZT_I_D606,
      _Company,
      _Month

}
