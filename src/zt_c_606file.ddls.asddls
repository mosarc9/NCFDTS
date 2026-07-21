@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption entity - 606 File'
@Metadata.allowExtensions: true
//@Metadata.ignorePropagatedAnnotations: true
define root view entity ZT_C_606FILE
  provider contract transactional_query
  as projection on ZT_R_606FILE
{
  key Uuid,
  @Consumption.valueHelpDefinition: [{ entity          : { name   : 'I_CompanyCodeStdVH', element: 'CompanyCode' },
                                       useForValidation: true }]
  Bukrs,
  @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CalendarYear', element: 'CalendarYear' }  }]
  Gjahr,
  @Consumption.filter: { multipleSelections: false }
  @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CalendarMonthVH', element: 'CalendarMonth' }  }]
  Monat,
  Attachment,
  Filename,
  Mimetype,
  LocalCreatedBy,
  LocalCreatedAt,
  LocalLastChangedBy,
  LocalLastChangedAt,
  LastChangedAt
}
