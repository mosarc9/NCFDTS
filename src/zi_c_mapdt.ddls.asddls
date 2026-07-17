@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection View - Map Doc Type'
@Metadata.allowExtensions: true
@Search.searchable: true

define root view entity ZI_C_MAPDT
  provider contract transactional_query
  as projection on ZT_R_MAPDT
{
  @UI.selectionField: [{ position: 10, element: 'doc_type' }]
  key doc_type,
      cod_inf,
      descripcion,
      last_changed_at
}
