@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption entity - Header 606'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true
@Metadata.allowExtensions: true
define root view entity ZT_C_H606
  provider contract transactional_query
  as projection on ZT_R_H606
{
      @Consumption.valueHelpDefinition: [{ entity          : { name   : 'I_CompanyCodeStdVH', element: 'CompanyCode' },
                                           useForValidation: true }]
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @ObjectModel.text.element: [ 'CompanyCodeName' ]
  key CompanyCode,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CalendarYear', element: 'CalendarYear' }  }]
  key FiscalYear,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CalendarMonthVH', element: 'CalendarMonth' }  }]
      @ObjectModel.text.element: [ 'CalendarMonthName' ]
  key FMonth,
      _Company.CompanyCodeName,
      _Month.CalendarMonthName,
      Periodo,
      /* Associations */

      _Items : redirected to composition child ZT_C_D606,
      _Company,
      _Month
}
