@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption entity - Txt File'
@Metadata.allowExtensions: true
//@Metadata.ignorePropagatedAnnotations: true
define root view entity ZT_C_TXTFILE
  provider contract transactional_query
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
