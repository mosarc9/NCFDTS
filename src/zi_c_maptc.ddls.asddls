@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption entity - Map Tax Codes'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZI_C_MAPTC 
    provider contract transactional_query
    as projection on ZT_R_MAPTC
{
    key Uuid,
    key TaxCode,
    TipoTasa,
    Descripcion,
    LocalCreatedBy,
    LocalCreatedAt,
    LocalLastChangedBy,
    LocalLastChangedAt,
    LastChangedAt
}
