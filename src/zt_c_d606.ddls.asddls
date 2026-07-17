@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption entity - 606 Items'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@Search.searchable: true
define view entity ZT_C_D606
  as projection on ZT_R_D606
{
      @Consumption.valueHelpDefinition: [{ entity: { name   : 'I_CompanyCodeStdVH', element: 'CompanyCode' },
                                           useForValidation: true }]
  key CompanyCode,

      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CalendarYear', element: 'CalendarYear' }  }]
  key FiscalYear,

      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @Search.ranking: #HIGH
  key AccountingDocument,

      @Consumption.valueHelpDefinition: [{ entity: { name   : 'I_SupplierCompanyVH', element: 'Supplier' },
                                           additionalBinding: [{ localElement: 'CompanyCode', element: 'CompanyCode', usage: #RESULT }],
                                           useForValidation : true }]
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @Search.ranking: #HIGH
  key Supplier,

      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CalendarMonthVH', element: 'CalendarMonth' }  }]
  key FMonth,

//      @Search.defaultSearchElement: true
//      @Search.fuzzinessThreshold: 0.8
//      @Search.ranking: #MEDIUM
      TaxNumber1,
      Tipo_identificacion,
      NCF,
      dgiitype,
      NCFMod,
      DocumentDate,
      ClearingDate,
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      TotalServicio,
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      TotalBien,
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      TotalFacturado,
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      ITBISFacturado,
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      ITBISRetenido,
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      ITBISPropor,
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      ITBISCosto,
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      ITBISporAdelantar,
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      ITBISPercCompras,
      tipoIsr,
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      MontoRetRenta,
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      ISRRenta,
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      MontoISC,
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      Otros,
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      mPropinaLegal,
      paymt,
      CompanyCodeCurrency,
      /* Associations */
      _Gs,
      _Header : redirected to parent ZT_C_H606,
      _Tax,
      _TypeGS,
      _IsrType
}
