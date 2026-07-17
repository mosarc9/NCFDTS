@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection View - GL Accounts'
@Metadata.allowExtensions: true
@Search.searchable: true

define root view entity ZI_C_MAPCTA
  provider contract transactional_query
  as projection on ZT_R_MAPCTA{
     @UI.selectionField: [{ position: 10, element: 'account_from' }]
    key account_from,
     @UI.selectionField: [{ position: 20, element: 'account_to' }]
    account_to,
    tipo_ret,
    tipo_b_s,
    descripcion,
    last_changed_at
}
