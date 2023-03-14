-- Transiting WEST <--> EAST
local route_west_to_east  = DCAF.AIR_ROUTE:New("ULDUR RETEL .. PARAR", "ULDUR RETEL ROTEL TUMAK FJV ALSAS PARAR")
local route_east_to_west  = route_west_to_east:CloneReversed("PARAR .. ULDUR")
local route_west_to_east_2  = DCAF.AIR_ROUTE:New("GADSI .. RASDI .. SIDAD PARAR", "ULDUR SIDAD IMDOX RASDI KAPUM BOSEV IMLIP LAKLU GEVED SETSI PARAR")
local route_east_to_west_2  = route_west_to_east_2:CloneReversed("PARAR SIDAD .. RASDI .. ULDUR")

-- -- Landing UAE, from west and east
local route_in_west_to_Dubai  = DCAF.AIR_ROUTE:New("ULDUR .. TUMAK OMDB", "ULDUR RETEL ROTEL TUMAK OMDB")
local route_in_west_to_AbuDhabi  = DCAF.AIR_ROUTE:New("ULDUR .. DOH OMAA", "ULDUR RETEL ROTEL DOH OMAA")
local route_in_east_to_Dubai  = DCAF.AIR_ROUTE:New("PARAR .. FJV OMDB", "PARAR ALSAS FJV OMDB")
local route_in_east_to_AbuDhabi  = DCAF.AIR_ROUTE:New("PARAR .. DESPI OMAA", "PARAR ALSAS DESPI OMAA")
local route_in_east_to_AbuDhabi  = DCAF.AIR_ROUTE:New("PARAR .. DESPI OMAA", "PARAR ALSAS DESPI OMAA")

-- -- Depart UAE, east and west
local route_depart_Dubai_west = DCAF.AIR_ROUTE:New("OMDB TUMAK .. ULDUR", "OMDB TUMAK ROTEL RETEL ULDUR") 
local route_depart_AbuDhabi_west = DCAF.AIR_ROUTE:New("OMAA DOH .. ULDUR", "OMAA DOH ROTEL RETEL ULDUR")
local route_depart_Dubai_east = DCAF.AIR_ROUTE:New("OMDB FJV .. PARAR", "OMDB FJV ALSAS PARAR")
local route_depart_AbuDhabi_east = DCAF.AIR_ROUTE:New("OMAA DESPI .. PARAR", "OMAA DESPI ALSAS PARAR")

-- Regional, Iran  <-->  UAE
----- Shiraz
local route_Shiraz_to_Dubai = DCAF.AIR_ROUTE:New("OISS > VUTEB .. OMDB", "OISS LVA ORSAR TOTKU VUTEB OMDB")
local route_Dubai_to_Shiraz = route_Shiraz_to_Dubai:CloneReversed()
local route_Shiraz_to_AbuDhabi = DCAF.AIR_ROUTE:New("OISS > ELOVU .. OMAA", "OISS LVA ORSAR TOTKU ELOVU OMAA")
local route_AbuDhabi_to_Shiraz = route_Shiraz_to_AbuDhabi:CloneReversed()
local route_Shiraz_to_KishIntl = DCAF.AIR_ROUTE:New("OISS LAM OIBK", "OISS LAM OIBK")
local route_KishIntl_to_Shiraz = route_Shiraz_to_KishIntl:CloneReversed()

----- Kerman
local route_Kerman_to_Dubai = DCAF.AIR_ROUTE:New("Kerman --> Dubai", "OIKK LVA ORSAR VUTEB ELOVU OMDB")
local route_Dubai_to_Kerman = route_Kerman_to_Dubai:CloneReversed()
local route_Kerman_to_BandarAbbas = DCAF.AIR_ROUTE:New("Kerman --> Bandar Abbas", "OIKK SRJ OIKB")
local route_BandarAbbas_to_Kerman = route_Kerman_to_BandarAbbas:CloneReversed()
local route_Kerman_to_KishIntl = DCAF.AIR_ROUTE:New("Kerman --> Kish Intl", "OIKK SRJ OIBK")
local route_KishIntl_to_Kerman = route_Kerman_to_KishIntl:CloneReversed()

CIV.RUT_WEST_TO_LAND = {
    --route_in_west_to_Dubai,
    route_in_west_to_AbuDhabi
}
CIV.BEIRUT = {
    route_in_east_to_Dubai,
    route_in_east_to_AbuDhabi
}
CIV.RUT_TRANSIT = {
    -- route_west_to_east,
    route_west_to_east_2,
    -- route_east_to_west,
    route_east_to_west_2
}
CIV.RUT_DEPART_WEST = {
    -- route_depart_Dubai_west,
    route_depart_AbuDhabi_west
}
CIV.RUT_DEPART_EAST = {
    route_depart_AbuDhabi_east,
    route_depart_AbuDhabi_east
}
CIV.RUT_REGIONAL = {
    -- route_Shiraz_to_Dubai,
    -- route_Dubai_to_Shiraz,
    -- route_Shiraz_to_AbuDhabi,
    -- route_AbuDhabi_to_Shiraz,
    route_Shiraz_to_KishIntl,
    route_KishIntl_to_Shiraz,
    -- route_Kerman_to_Dubai,
    -- route_Dubai_to_Kerman,
    route_Kerman_to_BandarAbbas,
    route_BandarAbbas_to_Kerman,
    route_Kerman_to_KishIntl,
    route_KishIntl_to_Kerman,
}
CIV.AC_INTERNATIONAL = {
    "NUT CIV A380 Emirates",
    "NUT CIV B737 Thomson",
    "NUT CIV B737 UPS",
    "NUT CIV B737 Lufthansa",
    "NUT CIV B737 Egypt",
    "NUT CIV B737 EasyJet",
    "NUT CIV B737 Algerie",
    "NUT CIV B737 Oman",
    "NUT CIV B737 TNT",
    "NUT CIV B757 DHL",
    "NUT CIV B757 Speedbird",
    "NUT CIV B757 Thomson",
    "NUT CIV B747 Air France",
    "NUT CIV B747 Turkish",
    "NUT CIV B747 Cathay",
}
CIV.AC_REGIONAL = {
    "NUT CIV A320 Etihad",
    "NUT CIV A320 Gulf Air",
    "NUT CIV A320 Kuwait",
    "NUT CIV A320 Iran",
    "NUT CIV A320 MEA",
    "NUT CIV B737 Oman",
    "NUT CIV B737 TNT"
}

local CIV_SPAWNS_IFF_7000 = { -- dictionary
  -- key = group template name
  -- value = #SPAWN
}

local CIV_SPAWNS_IFF_7100 = { -- dictionary
  -- key = group template name
  -- value = #SPAWN
}

----------------------------------------------------------------------------------------------

Trace("DCAF_PEG_CIV.lua was loaded")

----------------------------------------------------------------------------------------------

local interval = Minutes(28)

CIV:Schedule( CIV.RUT_WEST_TO_LAND, CIV.AC_INTERNATIONAL, interval ):Populate(224)

CIV:Schedule( CIV.BEIRUT_SOUTHEAST, CIV.AC_INTERNATIONAL, interval ):Populate(224)

CIV:Schedule( CIV.RUT_TRANSIT, CIV.AC_INTERNATIONAL ):Populate(190)

CIV:Schedule( CIV.RUT_DEPART_WEST, CIV.AC_INTERNATIONAL, interval ):Populate(320)

CIV:Schedule( CIV.RUT_DEPART_EAST, CIV.AC_INTERNATIONAL, interval ):Populate(320)

CIV:Schedule( CIV.RUT_REGIONAL, CIV.AC_REGIONAL, interval ):Populate(160)