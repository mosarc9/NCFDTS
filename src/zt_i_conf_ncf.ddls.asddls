@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface Root entity - Conf. NCF'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZT_I_CONF_NCF
  provider contract transactional_interface
  as projection on ZT_R_CONF_NCF
{
  key IdUuid,
      Bukrs,
      Plant,
      ClDoc,
      Modulo,
      Stcdc,
      Znrnr,
      Serie,
      IsDpp,
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,
      /* Associations */
      _CompanyCode,
      _DocType
}
