@EndUserText.label: 'Table - Tax Codes Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@ObjectModel.semanticKey: [ 'SingletonID' ]
@UI: {
  headerInfo: {
    typeName: 'TableTaxCodesAll'
  }
}
define root view entity ZI_TableTaxCodes_S
  as select from I_Language
    left outer join ZTAB_MAP_TC on 0 = 0
  association [0..*] to I_ABAPTransportRequestText as _ABAPTransportRequestText on $projection.TransportRequestID = _ABAPTransportRequestText.TransportRequestID
  composition [0..*] of ZI_TableTaxCodes as _TableTaxCodes
{
  @UI.facet: [ {
    id: 'ZI_TableTaxCodes', 
    purpose: #STANDARD, 
    type: #LINEITEM_REFERENCE, 
    label: 'Table - Tax Codes', 
    position: 1 , 
    targetElement: '_TableTaxCodes'
  } ]
  @UI.lineItem: [ {
    position: 1 
  } ]
  key 1 as SingletonID,
  _TableTaxCodes,
  @UI.hidden: true
  max( ZTAB_MAP_TC.LAST_CHANGED_AT ) as LastChangedAtMax,
  @ObjectModel.text.association: '_ABAPTransportRequestText'
  @UI.identification: [ {
    position: 1 , 
    type: #WITH_INTENT_BASED_NAVIGATION, 
    semanticObjectAction: 'manage'
  } ]
  @Consumption.semanticObject: 'CustomizingTransport'
  cast( '' as SXCO_TRANSPORT) as TransportRequestID,
  _ABAPTransportRequestText
}
where I_Language.Language = $session.system_language
