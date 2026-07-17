@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface entity - Txt File'
//@Metadata.ignorePropagatedAnnotations: true
define root view entity ZT_I_TXTFILE
  provider contract transactional_interface
  as projection on ZT_R_TXTFILE
{
  key Id,
      Attachment,
      Filename,
      Mimetype,
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt
}
