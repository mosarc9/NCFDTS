@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help - Sociedades'
@Metadata.ignorePropagatedAnnotations: true
define view entity zi_company_code
  as select from I_CompanyCode
{
  @EndUserText.label: 'Código Sociedad'
  key CompanyCode,
  @EndUserText.label: 'Nombre Sociedad'
      CompanyCodeName
}
