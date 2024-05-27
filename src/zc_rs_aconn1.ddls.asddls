@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
@AccessControl.authorizationCheck: #CHECK
define root view entity ZC_RS_ACONN1
  provider contract TRANSACTIONAL_QUERY
  as projection on ZR_RS_ACONN1
{
  key Uuid,
  CarrierId,
  ConnectionId,
  CityFrom,
  CountryFrom,
  CityTo,
  CountryTo,
  LocalCreatedBy,
  LocalCreatedAt,
  LocalLastChangedBy,
  LocalLastChangedAt,
  LastChangedAt
  
}
