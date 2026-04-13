@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Donation Ledger - Base View'
@Metadata.ignorePropagatedAnnotations: true

define root view entity ZI_DonationLedger
  as select from zdonation_ledger
{
  key donation_id as DonationID,
  donor_name      as DonorName,
  @Semantics.amount.currencyCode: 'Currency'
  amount          as Amount,
  currency        as Currency,
  purpose         as Purpose,
  donation_date   as DonationDate,
  status          as Status,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at as LastChangedAt
}
