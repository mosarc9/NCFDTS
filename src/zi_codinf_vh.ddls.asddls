@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help - Código Informe'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS
@Search.searchable: true

@UI.headerInfo: {
    typeName: 'Código Informe',
    typeNamePlural: 'Códigos Informe'
}

define view entity ZI_CODINF_VH
  as select from I_Language
{
      @UI.lineItem:       [ { position: 10, label: 'Código' } ]
      @UI.selectionField: [ { position: 10 } ]
      @UI.identification: [ { position: 10 } ]
      @Search.defaultSearchElement: true
  key cast( '606' as abap.char(3) ) as cod_inf,
      cast( 'Compras de Bienes y Servicios' as abap.char(40) ) as descripcion
}
where Language = 'S'

union all
  select from I_Language
{
  key cast( '607' as abap.char(3) ) as cod_inf,
      cast( 'Ventas de Bienes y Servicios' as abap.char(40) ) as descripcion
}
where Language = 'S'
