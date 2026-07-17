@EndUserText.label: 'Mapeo Códigos de  HP a DGII Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@ObjectModel.semanticKey: [ 'SingletonID' ]
@UI: {
  headerInfo: {
    typeName: 'MapeoCDigosDeHpAAll'
  }
}
define root view entity ZI_MapeoCDigosDeHpADgi_S
  as select from I_Language
    left outer join I_CstmBizConfignLastChgd on I_CstmBizConfignLastChgd.ViewEntityName = 'ZI_MAPEOCDIGOSDEHPADGI'
  association [0..*] to I_ABAPTransportRequestText as _ABAPTransportRequestText on $projection.TransportRequestID = _ABAPTransportRequestText.TransportRequestID
  composition [0..*] of ZI_MapeoCDigosDeHpADgi as _MapeoCDigosDeHpADgi
{
  @UI.facet: [ {
    id: 'ZI_MapeoCDigosDeHpADgi', 
    purpose: #STANDARD, 
    type: #LINEITEM_REFERENCE, 
    label: 'Mapeo Códigos de  HP a DGII', 
    position: 1 , 
    targetElement: '_MapeoCDigosDeHpADgi'
  } ]
  @UI.lineItem: [ {
    position: 1 
  } ]
  key 1 as SingletonID,
  _MapeoCDigosDeHpADgi,
  @UI.hidden: true
  I_CstmBizConfignLastChgd.LastChangedDateTime as LastChangedAtMax,
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
