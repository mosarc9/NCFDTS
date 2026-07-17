@EndUserText.label: 'Table - Tax Codes'
@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
define view entity ZI_TableTaxCodes
  as select from ZTAB_MAP_TC
  association to parent ZI_TableTaxCodes_S as _TableTaxCodesAll on $projection.SingletonID = _TableTaxCodesAll.SingletonID
{
  key TAX_CODE as TaxCode,
  TIPO_TASA as TipoTasa,
  DESCRIPTION as Description,
  @Semantics.user.createdBy: true
  LOCAL_CREATED_BY as LocalCreatedBy,
  @Semantics.systemDateTime.createdAt: true
  LOCAL_CREATED_AT as LocalCreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  @Consumption.hidden: true
  LOCAL_LAST_CHANGED_BY as LocalLastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  @Consumption.hidden: true
  LOCAL_LAST_CHANGED_AT as LocalLastChangedAt,
  @Semantics.systemDateTime.lastChangedAt: true
  LAST_CHANGED_AT as LastChangedAt,
  @Consumption.hidden: true
  1 as SingletonID,
  _TableTaxCodesAll
}
