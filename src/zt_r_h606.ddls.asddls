@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root entity - 606 Header'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZT_R_H606
  as select from ZZ1_606_HEADER

  composition [1..*] of ZT_R_D606           as _Items
  association [0..1] to I_CompanyCode       as _Company on  $projection.CompanyCode = _Company.CompanyCode
  association [0..1] to I_CalendarMonthText as _Month   on  $projection.FMonth = _Month.CalendarMonth
                                                        and _Month.Language    = $session.system_language
{

  key CompanyCode,
  key FiscalYear,
      //  key Supplier,
  key FMonth,
      Periodo,
      total,

      _Items,
      _Company,
      _Month
}
