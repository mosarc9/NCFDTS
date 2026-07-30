@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root entity - 606 Items'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZT_R_D606
  as select from    ZZ1_606_ITEMS     as a
    left outer join I_SupplierCompany as Sc on  a.CompanyCode = Sc.CompanyCode
                                            and a.Supplier    = Sc.Supplier

  association        to parent ZT_R_H606    as _Header   on  $projection.CompanyCode = _Header.CompanyCode
                                                         and $projection.FiscalYear  = _Header.FiscalYear
                                                         and $projection.FMonth      = _Header.FMonth

  //  association [0..1] to I_JournalEntryItem  as _Jei      on  $projection.CompanyCode        = _Jei.CompanyCode
  //                                                         and $projection.FiscalYear         = _Jei.FiscalYear
  //                                                         and $projection.AccountingDocument = _Jei.AccountingDocument
  //                                                         and _Jei.FinancialAccountType      = 'K'
  association [0..1] to I_Supplier          as _Supplier on  $projection.Supplier = _Supplier.Supplier
  association [0..1] to ZZ1_TOT_BIENSERV606 as _Gs       on  $projection.CompanyCode        = _Gs.CompanyCode
                                                         and $projection.FiscalYear         = _Gs.FiscalYear
                                                         and $projection.AccountingDocument = _Gs.AccountingDocument
  association [0..1] to ZZ1_TOT_TAX606      as _Tax      on  $projection.CompanyCode        = _Tax.CompanyCode
                                                         and $projection.FiscalYear         = _Tax.FiscalYear
                                                         and $projection.AccountingDocument = _Tax.AccountingDocument

  association [0..1] to ZZ1_TOT_ISR606      as _Isr      on  $projection.CompanyCode        = _Isr.CompanyCode
                                                         and $projection.FiscalYear         = _Isr.FiscalYear
                                                         and $projection.AccountingDocument = _Isr.AccountingDocument

  association [0..1] to zpaymt_606          as _Pay      on  Sc.PaymentMethodsList = _Pay.paykey

  association [0..1] to ZZ1_TYPE_GS         as _TypeG    on  $projection.CompanyCode        = _TypeG.CompanyCode
                                                         and $projection.FiscalYear         = _TypeG.FiscalYear
                                                         and $projection.AccountingDocument = _TypeG.AccountingDocument
                                                         and _TypeG.Gdsserv                 = '1' --Bien
  association [0..1] to ZZ1_TYPE_GS         as _TypeS    on  $projection.CompanyCode        = _TypeS.CompanyCode
                                                         and $projection.FiscalYear         = _TypeS.FiscalYear
                                                         and $projection.AccountingDocument = _TypeS.AccountingDocument
                                                         and _TypeS.Gdsserv                 = '2' --Servicio
  association [0..1] to ZZ1_TYPE_ISR        as _IsrType  on  $projection.CompanyCode        = _IsrType.CompanyCode
                                                         and $projection.FiscalYear         = _IsrType.FiscalYear
                                                         and $projection.AccountingDocument = _IsrType.AccountingDocument
{
  key a.CompanyCode,
  key a.FiscalYear,
  key a.AccountingDocument,
  key a.Supplier,
  key a.FMonth,
      replace( _Supplier.TaxNumber1, '-', '' )                                                   as TaxNumber1, // RNC o Cédula Proveedor
      case when _Supplier.Country <> 'DO' then '03'
           else case when length(replace( _Supplier.TaxNumber1, '-', '' )) = 9 then '01'
                     else '02'
                end
      end                                                                                        as Tipo_identificacion, // Tipo identificacion
      a.AccountingDocumentHeaderText                                                             as NCF, // NCF
      case
        when ( coalesce( _Gs.totalBien,     cast( 0 as abap.curr(23,2) ) ) = 0
           and coalesce( _Gs.totalServicio, cast( 0 as abap.curr(23,2) ) ) = 0 )
             then cast( '00' as abap.numc( 2 ) )
        when coalesce( _Gs.totalBien,     cast( 0 as abap.curr(23,2) ) ) >=
             coalesce( _Gs.totalServicio, cast( 0 as abap.curr(23,2) ) )
             then cast( coalesce( _TypeG.Dgiitype, '00' ) as abap.numc( 2 ) )
        else      cast( coalesce( _TypeS.Dgiitype, '00' ) as abap.numc( 2 ) )
      end                                                                                        as dgiitype,          // Tipo de Bienes y Servicios Comprados
      a.NCFMod,                                                                                                        // NCF ó Documento Modificado
      a.DocumentDate,                                                                                                  // Fecha Comprobante
      a.ClearingDate,                                                                                                  // Fecha Pago

      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      _Gs.totalServicio                                                                          as TotalServicio,     // Monto Facturado en Servicios
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      _Gs.totalBien                                                                              as TotalBien,         // Monto Facturado en Bienes
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      ( coalesce( _Gs.totalServicio, cast( 0 as abap.curr(23,2) ) ) +
        coalesce( _Gs.totalBien    , cast( 0 as abap.curr(23,2) ) ) )                            as TotalFacturado,    // Total Monto Facturado

      //       -
      //      ( coalesce( _Tax.totaltax1   , cast( 0 as abap.curr(23,2) ) ) -
      //        coalesce( _Isr.totalTaxRet , cast( 0 as abap.curr(23,2) ) ) )              as TotalFacturado,    // Total Monto Facturado

      //     TAXES
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      _Tax.totaltax1                                                                             as ITBISFacturado,    // ITBIS Facturado

      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      coalesce( _Isr[ 1: WithholdingTaxType = 'IB' ].totalTaxRet, cast( 0 as abap.curr(23,2) ) ) as ITBISRetenido,     // ITBIS Retenido

      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      _Tax.totaltax3                                                                             as ITBISPropor,       // ITBIS sujeto a Proporcionalidad

      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      _Tax.totaltax4                                                                             as ITBISCosto,        // ITBIS llevado al Costo

      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      _Tax.totaltax5                                                                             as ITBISporAdelantar, // ITBIS por Adelantar

      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      _Tax.totaltax6                                                                             as ITBISPercCompras,  // ITBIS percibido en compras

      case when _IsrType.isrcode is null then '00'
      else _IsrType.isrtype
      end                                                                                        as tipoIsr,           // Tipo ISR

      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      coalesce( _Isr[ 1: WithholdingTaxType = 'IS' ].totalisr1, cast( 0 as abap.curr(23,2) ) )   as MontoRetRenta,     // Monto Retención Renta

      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      cast( 0 as abap.curr( 23, 2 ) )                                                            as ISRRenta,          // ISR Percibido en compras

      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      _Tax.totaltax7                                                                             as MontoISC,          // Impuesto Selectivo al Consumo

      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      _Tax.totaltax8                                                                             as Otros,             // Otros Impuestos/Tasas

      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      cast( 0 as abap.curr( 23, 2 ) )                                                            as mPropinaLegal,     // Monto Propina Legal

      _Pay.paymt,                                                                                                      // Forma de pago
      _Gs.CompanyCodeCurrency,

      _Header,
      //      _Jei,
      _Gs,
      _Tax,
      _TypeG,
      _TypeS,
      _IsrType
}
