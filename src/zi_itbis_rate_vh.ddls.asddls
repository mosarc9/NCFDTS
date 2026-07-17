@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help - ITBIS Rate'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS

define view entity ZI_ITBIS_RATE_VH
  as select from I_Language
{
  key cast( '18.00' as abap.dec(5,2) ) as ItbisRate,
      cast( 'Tasa General 18%' as abap.char(30) ) as Description
}
where Language = 'S'

union all
  select from I_Language
{
  key cast( '16.00' as abap.dec(5,2) ) as ItbisRate,
      cast( 'Tasa Reducida 16%' as abap.char(30) ) as Description
}
where Language = 'S'

union all
  select from I_Language
{
  key cast( '0.00' as abap.dec(5,2) ) as ItbisRate,
      cast( 'Exento 0%' as abap.char(30) ) as Description
}
where Language = 'S'
