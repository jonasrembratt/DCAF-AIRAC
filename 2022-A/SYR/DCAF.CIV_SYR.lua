-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                          ROUTES
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-- BEIRUT (OLBA)
local route_southeast_to_Beirut  = DCAF.AIR_ROUTE:New("OTILA .. LEBOR OLBA", "OTILA KUMLO SOKAN SULAF FIRAS KTN LEBOR OLBA")
local route_Beirit_to_southeast = route_southeast_to_Beirut:CloneReversed()
local route_east_to_Beirut  = DCAF.AIR_ROUTE:New("XEAST .. LATEB OLBA", "XEAST MODIK TAN ABBAS BASEM LOTAX LATEB OLBA")
local route_Beirut_to_east = route_east_to_Beirut:CloneReversed()
local route_northwest_to_Beirut = DCAF.AIR_ROUTE:New("EXELA .. KUKLA OLBA", "EXELA DASNI LCA DESPO KUKLA OLBA")
local route_Beirut_to_northwest = route_northwest_to_Beirut:CloneReversed()

-- LARNACA - BEIRUT
local route_Larnaca_to_Beirut = DCAF.AIR_ROUTE:New("LCLK .. OLBA", "LCLK EMILI DESPO KUKLA OLBA")
local route_Beirut_to_Larnaca = route_Larnaca_to_Beirut:CloneReversed()

-- Damascus (OSDI)
local route_east_to_Damascus = DCAF.AIR_ROUTE:New("KASIR .. SOKAN OSDI", "KASIR PASIP KUMLO SOKAN OSDI")
local route_Damascus_to_east = route_east_to_Damascus:CloneReversed()


CIV.BEIRUT_SOUTHEAST = {
    route_southeast_to_Beirut,
    route_Beirit_to_southeast,
    route_east_to_Beirut,
    route_Beirut_to_east
}

CIV.BEIRUT_NORTHWEST = {
    route_northwest_to_Beirut,
    route_Beirut_to_northwest
}

CIV.LARNACA_BEIRUT = {
    route_Larnaca_to_Beirut,
    route_Beirut_to_Larnaca
}

CIV.DAMASCUS_EAST = {
    route_east_to_Damascus,
    route_Damascus_to_east
}

CIV.AC_INTERNATIONAL = {
    "NUT CIV A380 Emirates",
    "NUT CIV A320 MEA",
    "NUT CIV A320 Kuwait",
    "NUT CIV A320 Gulf Air",
    "NUT CIV A320 Etihad",
    "NUT CIV A320 Iran",
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

local interval_Beirut = Minutes(18)
local interval_Damascus = Minutes(28)

CIV:Schedule( CIV.BEIRUT_SOUTHEAST, CIV.AC_INTERNATIONAL, interval_Beirut ):Populate(112)
CIV:Schedule( CIV.BEIRUT_NORTHWEST, CIV.AC_INTERNATIONAL, interval_Beirut ):Populate(112)
CIV:Schedule( CIV.DAMASCUS_EAST, CIV.AC_INTERNATIONAL, interval_Damascus ):Populate(112)
CIV:Schedule( CIV.LARNACA_BEIRUT, CIV.AC_INTERNATIONAL, interval_Damascus ):Populate(112)