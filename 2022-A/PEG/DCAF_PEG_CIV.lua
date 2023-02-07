local route_Shiraz_to_Dubai = DCAF.AIR_ROUTE:New("Shiraz --> Dubai", "OISS LVA TUMAK OMDB")

-- Transiting WEST <--> EAST
local route_west_to_east  = DCAF.AIR_ROUTE:New("Int. West --> East", "ULDUR RETEL ROTEL TUMAK FJV ALSAS PARAR")
local route_east_to_west  = route_west_to_east:CloneReversed()

-- Landing, from west
local route_in_west_to_Dubai  = DCAF.AIR_ROUTE:New("Int. West --> OMDB", "ULDUR RETEL ROTEL TUMAK OMDB")
local route_in_west_to_AbuDhabi  = DCAF.AIR_ROUTE:New("Int. West --> OMAA", "ULDUR RETEL ROTEL DOH OMAA")
local route_in_east_to_Dubai  = DCAF.AIR_ROUTE:New("Int. East --> OMDB", "PARAR ALSAS FJV OMDB")
local route_in_east_to_AbuDhabi  = DCAF.AIR_ROUTE:New("Int. East --> OMAA", "PARAR ALSAS DESPI OMAA")

-- Depart, from east
local route_depart_Dubai_west = DCAF.AIR_ROUTE:New("Int. UAE --> West", "OMDB TUMAK ROTEL RETEL ULDUR") 
local route_depart_AbuDhabi_west = DCAF.AIR_ROUTE:New("Int. UAE --> West", "OMAA DOH ROTEL RETEL ULDUR")
local route_depart_Dubai_east = DCAF.AIR_ROUTE:New("Int. UAE --> West", "OMDB FJV ALSAS PARAR")
local route_depart_AbuDhabi_east = DCAF.AIR_ROUTE:New("Int. UAE --> West", "OMAA DESPI ALSAS PARAR")

CIV = {
    WEST_TO_LAND = {
        route_in_west_to_Dubai,
        route_in_west_to_AbuDhabi
    },
    EAST_TO_LAND = {
        route_in_east_to_Dubai,
        route_in_east_to_AbuDhabi
    },
    TRANSIT = {
        route_west_to_east,
        route_east_to_west
    },
    DEPART_WEST = {
        route_depart_Dubai_west,
        route_depart_AbuDhabi_west
    },
    DEPART_EAST = {
        route_depart_AbuDhabi_east,
        route_depart_AbuDhabi_east
    },
    INTERNATIONAL = {
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
    REGIONAL = {
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

function CIV:Schedule(routes, groups, nInterval, nDelay, nIntervalRndFactor)
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
        local route = listRandomItem(routes)
        local group = listRandomItem(groups)
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
end