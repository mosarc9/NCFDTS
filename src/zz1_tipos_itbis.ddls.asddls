@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Tipos de Retenciones'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZZ1_TIPOS_ITBIS
  as select from I_ExtendedWhldgTaxCodeText as IndRet
{
  key WithholdingTaxCode,
      @UI.hidden: true
  key Language,
      @UI.hidden: true
  key CountryCode,
  key WithholdingTaxType,
      WhldgTaxCodeName,
      /* Associations */
      _Language


}
where
      CountryCode = 'DO'
  and Language    = 'S'
//  and WithholdingTaxType = 'IB'

group by
  WithholdingTaxCode,
  Language,
  CountryCode,
  WithholdingTaxType,
  WhldgTaxCodeName
