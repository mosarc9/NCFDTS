@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Type G/S - line level'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZZ1_TYPE_GS_I
  as select from    ZZ1_DOC_ACCOUNT as a
    left outer join ZZ1_MAP606      as B4 on a.cta4 = B4.Saknr
    left outer join ZZ1_MAP606      as B3 on a.cta3 = B3.Saknr
{
  key a.CompanyCode,
  key a.FiscalYear,
  key a.AccountingDocument,
      case when B4.Saknr is not null then B4.Dgiitype else B3.Dgiitype end as Dgiitype,
      case when B4.Saknr is not null then B4.Gdsserv  else B3.Gdsserv  end as Gdsserv
}
where
     B4.Saknr is not null
  or B3.Saknr is not null
