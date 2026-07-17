@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root entity - 606'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZT_R_606
  as select from zmap_606
  association [0..1] to ZZ1_GDSSERV_VH  as _GdsServ     on $projection.Gdsserv = _GdsServ.Staging
  association [0..1] to ZZ1_DGII_TYPE   as _Dgii        on $projection.Dgiitype = _Dgii.Dgiitype
  association [0..*] to I_GLAccountText as _AccountText on $projection.Saknr = _AccountText.GLAccount

{
  key uuid                  as Uuid,
      saknr                 as Saknr,
      dgiitype              as Dgiitype,
      gdsserv               as Gdsserv,
      @Semantics.user.createdBy: true
      local_created_by      as LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      local_created_at      as LocalCreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      local_last_changed_by as LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,

      _GdsServ,
      _Dgii,
      _AccountText
}
