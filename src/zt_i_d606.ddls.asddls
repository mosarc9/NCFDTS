@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface entity - 606 Items'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZT_I_D606

  as projection on ZT_R_D606
{
  key CompanyCode,
  key FiscalYear,
  key AccountingDocument,
  key Supplier,
  key FMonth,
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
      _Header : redirected to parent ZT_I_H606,
      _Tax,
      _TypeGS,
      _IsrType
}
