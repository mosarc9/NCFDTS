@EndUserText.label: 'Abstract Entity - txt data'
define abstract entity Z_A_TXTDATA
  //  with parameters
  //    parameter_name : parameter_type
{

  @Semantics.largeObject: { mimeType: 'Mimetype',
                            fileName: 'Filename',
                            contentDispositionPreference: #ATTACHMENT }
  Attachment : zattachement;
  Filename   : abap.char(128);
  @Semantics.mimeType: true
  Mimetype   : abap.char(128);

}
