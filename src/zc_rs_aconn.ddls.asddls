@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
@AccessControl.authorizationCheck: #CHECK
define root view entity ZC_RS_ACONN
  provider contract transactional_query
  as projection on ZR_RS_ACONN
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
