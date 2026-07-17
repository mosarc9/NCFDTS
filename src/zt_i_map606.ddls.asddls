@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface entity - Map 606'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZT_I_MAP606
  provider contract transactional_interface
  as projection on ZT_R_MAP606
{
  key Uuid,
      Saknr,
      Dgiitype,
      Gdsserv,
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,
      /* Associations */
      _AccountText,
      _Dgii,
      _GdsServ
}
