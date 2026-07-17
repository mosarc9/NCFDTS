@EndUserText.label: 'Projection View - Mantenimiento ITBIS'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@Search.searchable: true

@UI.headerInfo: {
    typeName: 'Tax Code',
    typeNamePlural: 'Tax Codes',
    title: { value: 'tax_code' }
}

define root view entity zc_taxcode_maint
  provider contract transactional_query
  as projection on zi_taxtcode_maint
{
@UI.selectionField: [{ position: 10, element: 'tax_code' }]
  key tax_code,
      itbis_rate,
      last_changed_at
}
