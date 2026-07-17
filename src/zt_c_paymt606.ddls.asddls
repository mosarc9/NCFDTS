@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption entity - Payment 606'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
//@Search.searchable: true
define root view entity ZT_C_PAYMT606
  provider contract transactional_query
  as projection on ZT_R_PAYMT606
{
  key Uuid,
//      @Search.defaultSearchElement: true
      @Consumption.valueHelpDefinition: [{ entity: {  name: 'I_PaymentMethodText', element: 'PaymentMethod' },
                                additionalBinding: [{ element: 'Language', localConstant: 'S' },
                                                    { element: 'Country' , localConstant: 'DO' }],
                                 useForValidation: true }]
      Paykey,

      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZZ1_PAYMENTMT_VH',
                                                    element: 'Staging' },
                                          useForValidation: true }]
      @ObjectModel.text.element: [ 'Description' ]                                          
      Paymt,
       _Ind.Description,
      
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,
      
       _Ind
}
