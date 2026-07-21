@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root entity - Txt file'
//@Metadata.ignorePropagatedAnnotations: true
define root view entity ZT_R_606FILE
  as select from z606file

{
  key uuid                  as Uuid,
      bukrs                 as Bukrs,
      gjahr                 as Gjahr,
      monat                 as Monat,
      @Semantics.largeObject: { mimeType: 'Mimetype',
                                fileName: 'Filename',
                                contentDispositionPreference: #ATTACHMENT,
                                acceptableMimeTypes: [ 'text/plain' ] }
      attachment            as Attachment,
      filename              as Filename,
      @Semantics.mimeType: true
      mimetype              as Mimetype,
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
