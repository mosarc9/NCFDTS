@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'alue Help - Tipo Retención'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true

@UI.headerInfo: {
    typeName: 'Tipo Retención',
    typeNamePlural: 'Tipos de Retención'
}

define view entity ZI_TIPORET_VH
  as select from I_Language
{
      @UI.lineItem:       [ { position: 10, label: 'Código' } ]
      @UI.selectionField: [ { position: 10 } ]
      @UI.identification: [ { position: 10 } ]
      @Search.defaultSearchElement: true
  key cast( '030' as abap.char(3) ) as TipoRet,
      cast( 'Retención 30%' as abap.char(40) ) as Descripcion
}
where Language = 'S'

union all
  select from I_Language
{
  key cast( '100' as abap.char(3) ) as TipoRet,
      cast( 'Retención 100%' as abap.char(40) ) as Descripcion
}
where Language = 'S'

union all
  select from I_Language
{
  key cast( 'IVA' as abap.char(3) ) as TipoRet,
      cast( 'ITBIS' as abap.char(40) ) as Descripcion
}
where Language = 'S'
