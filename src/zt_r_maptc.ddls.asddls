@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root Entity - Map Tax Code'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZT_R_MAPTC 
as select from ztab_it1_tc_map
{
    key uuid as Uuid,
    key tax_code as TaxCode,
        tipo_tasa as TipoTasa,
        descripcion as Descripcion,
        @Semantics.user.createdBy: true
        local_created_by      as LocalCreatedBy,
        @Semantics.systemDateTime.createdAt: true
        local_created_at      as LocalCreatedAt,
        @Semantics.user.localInstanceLastChangedBy: true
        local_last_changed_by as LocalLastChangedBy,
        @Semantics.systemDateTime.localInstanceLastChangedAt: true
        local_last_changed_at as LocalLastChangedAt,
        @Semantics.systemDateTime.lastChangedAt: true
        last_changed_at       as LastChangedAt
}
