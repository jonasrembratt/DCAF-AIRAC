-- Transiting WEST <--> EAST
local route_west_to_east  = DCAF.AIR_ROUTE:New("Int. West --> East", "ULDUR RETEL ROTEL TUMAK FJV ALSAS PARAR")
local route_east_to_west  = route_west_to_east:CloneReversed()

-- -- Landing UAE, from west and east
local route_in_west_to_Dubai  = DCAF.AIR_ROUTE:New("Int. West --> OMDB", "ULDUR RETEL ROTEL TUMAK OMDB")
local route_in_west_to_AbuDhabi  = DCAF.AIR_ROUTE:New("Int. West --> OMAA", "ULDUR RETEL ROTEL DOH OMAA")
local route_in_east_to_Dubai  = DCAF.AIR_ROUTE:New("Int. East --> OMDB", "PARAR ALSAS FJV OMDB")
local route_in_east_to_AbuDhabi  = DCAF.AIR_ROUTE:New("Int. East --> OMAA", "PARAR ALSAS DESPI OMAA")

-- -- Depart UAE, east and west
local route_depart_Dubai_west = DCAF.AIR_ROUTE:New("Int. UAE --> West", "OMDB TUMAK ROTEL RETEL ULDUR") 
local route_depart_AbuDhabi_west = DCAF.AIR_ROUTE:New("Int. UAE --> West", "OMAA DOH ROTEL RETEL ULDUR")
local route_depart_Dubai_east = DCAF.AIR_ROUTE:New("Int. UAE --> West", "OMDB FJV ALSAS PARAR")
local route_depart_AbuDhabi_east = DCAF.AIR_ROUTE:New("Int. UAE --> West", "OMAA DESPI ALSAS PARAR")

-- Regional, Iran  <-->  UAE
----- Shiraz
local route_Shiraz_to_Dubai = DCAF.AIR_ROUTE:New("Shiraz --> Dubai", "OISS LVA ORSAR TOTKU VUTEB OMDB")
local route_Dubai_to_Shiraz = route_Shiraz_to_Dubai:CloneReversed()
local route_Shiraz_to_AbuDhabi = DCAF.AIR_ROUTE:New("Shiraz --> Abu Dhabi", "OISS LVA ORSAR TOTKU ELOVU OMAA")
local route_AbuDhabi_to_Shiraz = route_Shiraz_to_AbuDhabi:CloneReversed()
local route_Shiraz_to_KishIntl = DCAF.AIR_ROUTE:New("Shiraz --> Kish Intl", "OISS LAM OIBK")
local route_KishIntl_to_Shiraz = route_Shiraz_to_KishIntl:CloneReversed()

----- Kerman
local route_Kerman_to_Dubai = DCAF.AIR_ROUTE:New("Kerman --> Dubai", "OIKK LVA ORSAR VUTEB ELOVU OMDB")
local route_Dubai_to_Kerman = route_Kerman_to_Dubai:CloneReversed()
local route_Kerman_to_BandarAbbas = DCAF.AIR_ROUTE:New("Kerman --> Bandar Abbas", "OIKK SRJ OIKB")
local route_BandarAbbas_to_Kerman = route_Kerman_to_BandarAbbas:CloneReversed()
local route_Kerman_to_KishIntl = DCAF.AIR_ROUTE:New("Kerman --> Kish Intl", "OIKK SRJ OIBK")
local route_KishIntl_to_Kerman = route_Kerman_to_KishIntl:CloneReversed()

CIV = {
    RUT_WEST_TO_LAND = {
        route_in_west_to_Dubai,
        route_in_west_to_AbuDhabi
    },
    RUT_EAST_TO_LAND = {
        route_in_east_to_Dubai,
        route_in_east_to_AbuDhabi
    },
    RUT_TRANSIT = {
        route_west_to_east,
        route_east_to_west
    },
    RUT_DEPART_WEST = {
        route_depart_Dubai_west,
        route_depart_AbuDhabi_west
    },
    RUT_DEPART_EAST = {
        route_depart_AbuDhabi_east,
        route_depart_AbuDhabi_east
    },
    RUT_REGIONAL = {
        route_Shiraz_to_Dubai,
        route_Dubai_to_Shiraz,
        route_Shiraz_to_AbuDhabi,
        route_AbuDhabi_to_Shiraz,
        route_Shiraz_to_KishIntl,
        route_KishIntl_to_Shiraz,
        route_Kerman_to_Dubai,
        route_Dubai_to_Kerman,
        route_Kerman_to_BandarAbbas,
        route_BandarAbbas_to_Kerman,
        route_Kerman_to_KishIntl,
        route_KishIntl_to_Kerman,
    },
    AC_INTERNATIONAL = {
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
    },
    AC_REGIONAL = {
        "NUT CIV A320 Etihad",
        "NUT CIV A320 Gulf Air",
        "NUT CIV A320 Kuwait",
        "NUT CIV A320 Iran",
        "NUT CIV A320 MEA",
        "NUT CIV B737 Oman",
        "NUT CIV B737 TNT"
    }
}

local CIV_SPAWNS_IFF_7000 = { -- dictionary
  -- key = group template name
  -- value = #SPAWN
}

local CIV_SPAWNS_IFF_7100 = { -- dictionary
  -- key = group template name
  -- value = #SPAWN
}

local CIV_SCHEDULER = SCHEDULER:New(CIV)

local CIV_OP = {
    ClassName = "CIV_OP",
    Routes = nil,       -- #table (of #DCAF.AIR_ROUTE)
    Groups = nil        -- #table (of GROUP template names)
}

function CIV_OP:New(routes, groups)
    local civOp = DCAF.clone(CIV_OP)
    civOp.Routes = routes
    civOp.Groups = groups
    return civOp
end

function CIV:Schedule(routes, groups, nInterval, nDelay, nIntervalRndFactor)
    local civOp = CIV_OP:New(routes, groups)
    return civOp:Schedule(nInteparval, nDelay, nInteparvalRndFactor)
end

function CIV_OP:Schedule(nInterval, nDelay, nIntervalRndFactor)
    if not isNumber(nInterval) then
        nInterval = Minutes(10)
    end
    if not isNumber(nIntervalRndFactor) then
        nIntervalRndFactor = .5
    end
    if not isNumber(nDelay) then
        nDelay = math.random(nInterval)
    end

    CIV_SCHEDULER:Schedule(CIV, function() 
        local route = listRandomItem(self.Routes)
        local group = listRandomItem(self.Groups)
        route
            :Fly(group)
            :OnArrival(function(route) 
                -- destroy group if last WP is en-route (retain if landing at airport)
                local agl = route.Group:GetAltitude(true)
                if agl > 10 then
                    route:Destroy()
                end
            end)
    end, 
    {}, 
    nDelay, nInterval, nIntervalRndFactor)
    return self
end

function CIV:Populate(routes, groups, nSeparation)
    local civOp = CIV_OP:New(routes, groups)
    return civOp:Populate(nSeparation)
end

function CIV_OP:Populate(nSeparation)
Debug("nisse - CIV_OP:Populate... :: Routes: " .. DumpPretty(self.Routes))
    local function randomGroup()
        return listRandomItem(self.Groups)
    end

    for _, route in ipairs(self.Routes) do
Debug("nisse - CIV_OP:Populate :: name: " .. route.Name .. " :: route: " .. route.RouteText .. " :: Waypoints: " .. DumpPrettyDeep(route.Waypoints, 2))
        route:Populate(nSeparation, randomGroup)
            --  :OnArrival()
    end
    return self
end

----------------------------------------------------------------------------------------------

Trace("DCAF_PEG_CIV.lua was loaded")

----------------------------------------------------------------------------------------------

local interval = Minutes(20)

CIV:Schedule( CIV.RUT_WEST_TO_LAND, CIV.AC_INTERNATIONAL, interval ):Populate(160)

CIV:Schedule( CIV.RUT_EAST_TO_LAND, CIV.AC_INTERNATIONAL, interval ):Populate(160)

CIV:Schedule( CIV.RUT_TRANSIT, CIV.AC_INTERNATIONAL )--:Populate(160)

CIV:Schedule( CIV.RUT_DEPART_WEST, CIV.AC_INTERNATIONAL, interval )--:Populate(320)

CIV:Schedule( CIV.RUT_DEPART_EAST, CIV.AC_INTERNATIONAL, interval )--:Populate(320)

CIV:Schedule( CIV.RUT_REGIONAL, CIV.AC_REGIONAL, interval ):Populate(140)