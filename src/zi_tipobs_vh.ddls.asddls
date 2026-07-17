@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help - Tipo Bien/Servicio DGII'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true

@UI.headerInfo: {
    typeName: 'Tipo Bien/Servicio',
    typeNamePlural: 'Tipos de Bien/Servicio'
}

define view entity ZI_TIPOBS_VH
  as select from I_Language
{
      @UI.lineItem:       [ { position: 10, label: 'Código' } ]
      @UI.selectionField: [ { position: 10 } ]
      @UI.identification: [ { position: 10 } ]
      @Search.defaultSearchElement: true
  key cast( '01' as abap.char(2) ) as TipoBS,
  
      @UI.lineItem:       [ { position: 20, label: 'Descripción' } ]
      @UI.identification: [ { position: 20 } ]
      cast( 'Gastos de Personal' as abap.char(60) ) as Descripcion
}
where Language = 'S'

union all select from I_Language
{
  key cast( '02' as abap.char(2) ) as TipoBS,
      cast( 'Gastos por Trabajo, Suministros y Servicios' as abap.char(60) ) as Descripcion
}
where Language = 'S'

union all select from I_Language
{
  key cast( '03' as abap.char(2) ) as TipoBS,
      cast( 'Arrendamientos' as abap.char(60) ) as Descripcion
}
where Language = 'S'

union all select from I_Language
{
  key cast( '04' as abap.char(2) ) as TipoBS,
      cast( 'Gastos de Activos Fijos' as abap.char(60) ) as Descripcion
}
where Language = 'S'

union all select from I_Language
{
  key cast( '05' as abap.char(2) ) as TipoBS,
      cast( 'Gastos de Representación' as abap.char(60) ) as Descripcion
}
where Language = 'S'

union all select from I_Language
{
  key cast( '06' as abap.char(2) ) as TipoBS,
      cast( 'Otras Deducciones Admitidas' as abap.char(60) ) as Descripcion
}
where Language = 'S'

union all select from I_Language
{
  key cast( '07' as abap.char(2) ) as TipoBS,
      cast( 'Gastos Financieros' as abap.char(60) ) as Descripcion
}
where Language = 'S'

union all select from I_Language
{
  key cast( '08' as abap.char(2) ) as TipoBS,
      cast( 'Gastos Extraordinarios' as abap.char(60) ) as Descripcion
}
where Language = 'S'

union all select from I_Language
{
  key cast( '09' as abap.char(2) ) as TipoBS,
      cast( 'Compras y Adquisiciones' as abap.char(60) ) as Descripcion
}
where Language = 'S'

union all select from I_Language
{
  key cast( '10' as abap.char(2) ) as TipoBS,
      cast( 'Importaciones' as abap.char(60) ) as Descripcion
}
where Language = 'S'

union all select from I_Language
{
  key cast( '11' as abap.char(2) ) as TipoBS,
      cast( 'Otros Gastos' as abap.char(60) ) as Descripcion
}
where Language = 'S'
