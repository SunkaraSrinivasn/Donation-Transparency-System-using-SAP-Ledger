@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Donation Ledger Projection'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true

define root view entity ZC_DonationLedger
  provider contract transactional_query
  as projection on ZI_DonationLedger
{
    key DonationID,
    DonorName,    
    @Semantics.amount.currencyCode: 'Currency'
    Amount,
    Currency,
    Purpose,
    DonationDate, 
    Status,
    LastChangedAt
}
