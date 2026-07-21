@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface entity - Txt File'
//@Metadata.ignorePropagatedAnnotations: true
define root view entity ZT_I_606FILE
  provider contract transactional_interface
  as projection on ZT_R_606FILE
{
  key Uuid,
      Bukrs,
      Gjahr,
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
