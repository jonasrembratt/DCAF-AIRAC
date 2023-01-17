--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                      AIRAC 2022-A
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

DCAF.AIRAC.Version = "2022-A"
DCAF.AIRAC.Aerodromes = {}

function DCAF.AIRAC:StartATIS(aerodrome, sCulture, sGender, nFrequency)
    local airbase = DCAF.AIRAC.Aerodromes[aerodrome]
    if airbase then
        airbase:StartATIS(sCulture, sGender, nFrequency)
    else
        Warning("DCAF.AIRAC:StartATIS :: aerodrome not supported: " .. DumpPretty(aerodrome))
    end
end

local function addAIRACAerodromes(...)
    for i = 1, #arg, 1 do
        local aerodrome = arg[i]
        DCAF.AIRAC.Aerodromes[aerodrome.Id] = aerodrome
    end
end
 
local AIRBASE_INFO = {
    ClassName = "AIRBASE_INFO",
    Name = nil,                 -- #string - name of airdrome
    ICAO = nil,                 -- #string - OIDC code 
    Country = nil,              -- DCS#country.id - country where airdrome reside

}

function AIRBASE_INFO:New(icao, country, name)
    local info = DCAF.clone(AIRBASE_INFO)
    info.ICAO = icao
    info.Name = name
    info.Country = country
    return info
end

DCAF.AIRAC.ICAO = {
    -- Iran, PEG
    OIBK = AIRBASE_INFO:New("OIBK", country.id.IRAN, AIRBASE.PersianGulf.Kish_International_Airport),
    OIBL = AIRBASE_INFO:New("OIBL", country.id.IRAN, AIRBASE.PersianGulf.Bandar_Lengeh),
    OIBV = AIRBASE_INFO:New("OIBV", country.id.IRAN, AIRBASE.PersianGulf.Lavan_Island_Airport),
    OIKB = AIRBASE_INFO:New("OIKB", country.id.IRAN, AIRBASE.PersianGulf.Bandar_Abbas_Intl),
    OIKJ = AIRBASE_INFO:New("OIKJ", country.id.IRAN, AIRBASE.PersianGulf.Jiroft_Airport), 
    OIKK = AIRBASE_INFO:New("OIKK", country.id.IRAN, AIRBASE.PersianGulf.Kerman_Airport), 
    OIKP = AIRBASE_INFO:New("OIKP", country.id.IRAN, AIRBASE.PersianGulf.Havadarya), 
    OIKQ = AIRBASE_INFO:New("OIKQ", country.id.IRAN, AIRBASE.PersianGulf.Qeshm_Island),
    OISL = AIRBASE_INFO:New("OISL", country.id.IRAN, AIRBASE.PersianGulf.Lar_Airbase),
    OISS = AIRBASE_INFO:New("OISS", country.id.IRAN, AIRBASE.PersianGulf.Shiraz_International_Airport),
    OIZJ = AIRBASE_INFO:New("OIZJ", country.id.IRAN, AIRBASE.PersianGulf.Bandar_e_Jask_airfield),
    -- UAE, PEG
    OMAA = AIRBASE_INFO:New("OMAA", country.id.UNITED_ARAB_EMIRATES , AIRBASE.PersianGulf.Abu_Dhabi_International_Airport), 
    OMAM = AIRBASE_INFO:New("OMAM", country.id.UNITED_ARAB_EMIRATES , AIRBASE.PersianGulf.Al_Dhafra_AB),
    OMDM = AIRBASE_INFO:New("OMDM", country.id.UNITED_ARAB_EMIRATES , AIRBASE.PersianGulf.Al_Minhad_AB),
    OMDB = AIRBASE_INFO:New("OMDB", country.id.UNITED_ARAB_EMIRATES , AIRBASE.PersianGulf.Dubai_Intl),
    OMLW = AIRBASE_INFO:New("OMLW", country.id.UNITED_ARAB_EMIRATES , AIRBASE.PersianGulf.Liwa_Airbase),
    -- Oman, PEG
    OOKB = AIRBASE_INFO:New("OOKB", country.id.OMAN , AIRBASE.PersianGulf.Khasab),
}

function DCAF.AIRAC.ICAO:GetAirbaseICAO(airbase)
    if isClass(airbase, AIRBASE.ClassName) then
        airbase = airbase.AirbaseName
    elseif not isAssignedString(airbase) then
        error("DCAF.AIRAC.ICAO:GetForAirbase :: `airbase` must be assigned string (airbase name) or of type " .. AIRBASE.ClassName)
    end
    for icao, info in pairs(DCAF.AIRAC.ICAO) do
        if isClass(info, AIRBASE_INFO.ClassName) and info.Name == airbase then
            return info.ICAO end
    end
end

function DCAF.AIRAC.ICAO:GetCountry(airbase)
    if isClass(airbase, AIRBASE.ClassName) then
        airbase = DCAF.AIRAC.ICAO:GetAirbaseICAO(airbase)
    end
    if not isAssignedString(airbase) then 
        error("DCAF.AIRAC.ICAO:GetCountry :: unexpected `airbase` value: " .. DumpPretty(airbase)) end

    local info = DCAF.AIRAC.ICAO[airbase]
    if info then
        return info.Country 
    end
end

DCAF.AIRAC.SID = {
    -- list of #DCAF.AIR_ROUTE
}

DCAF.AIRAC.STAR = {
    -- list of #DCAF.AIR_ROUTE
}

local CONSTANTS = {
    RouteProcedure = "proc",
    RouteProcedureName = "proc_name"
}


--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                        NAVAIDS
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

DCAF.NAVAID_TYPE = {
    Waypoint = "Waypoint",
    VOR = "VOR",
    DME = "DME",
    TACAN = "TACAN",
    VORTAC = "VORTAC",
}

DCAF.NAVAID = {
    ClassName = "DCAF.NAVAID",
    Name = nil,                 -- #string - name of NAVAID
    Coordinate = nil,           -- #MOOSE/COORDINATE
    Map = nil,                  -- #string (see MOOSE/DCSMAP)
    Type = DCAF.NAVAID_TYPE.Waypoint
}

function DCAF.NAVAID_TYPE:IsValid(type)
    return type == DCAF.NAVAID_TYPE.VOR
        or type == DCAF.NAVAID_TYPE.DME
        or type == DCAF.NAVAID_TYPE.TACAN
        or type == DCAF.NAVAID_TYPE.Waypoint
end

function DCSMAP:IsValid(map)
    return map == DCSMAP.Caucasus
        or map == DCSMAP.MarianaIslands
        or map == DCSMAP.Normandy
        or map == DCSMAP.NTTR
        or map == DCSMAP.PersianGulf
        or map == DCSMAP.Syria
        or map == DCSMAP.TheChannel
end

function DCAF.NAVAID:New(map, name, coordinate, type)
    if not isAssignedString(map) then
        error("DCAF.NAVAID:New :: `map` must be assigned string") end
    if not DCSMAP:IsValid(map) then
        error("DCAF.NAVAID:New :: unknown map: " .. map) end
    if not isAssignedString(name) then
        error("DCAF.NAVAID:New :: `name` must be assigned string") end
    if not isClass(coordinate, COORDINATE.ClassName) then
        error("DCAF.NAVAID:New :: `coordinate` must be type: " .. COORDINATE.ClassName) end
    if isAssignedString(type) then
        if not DCAF.NAVAID_TYPE:IsValid(type) then
            error("DCAF.NAVAID:New :: invalid `type`: " .. DumpPretty(type)) end
    else
        type = DCAF.NAVAID_TYPE.Waypoint
    end
    
    local navaid = DCAF.clone(DCAF.NAVAID)
    navaid.Map = map
    navaid.Name = name
    navaid.Coordinate = coordinate
    navaid.Type = type
    return navaid
end

function DCAF.NAVAID:NewWaypoint(map, name, coordinate)
    return DCAF.NAVAID:New(map, name, coordinate, DCAF.NAVAID_TYPE.Waypoint)
end

function DCAF.NAVAID:NewVOR(map, name, frequency, coordinate)
    if not isNumber(frequency) then
        error("DCAF.NAVAID:NewVOR :: `frequency` must be a number but was: " .. DumpPretty(frequency)) end
    local vor = DCAF.NAVAID:New(map, name, coordinate, DCAF.NAVAID_TYPE.VOR)
    vor.Frequency = frequency
    return vor
end

function DCAF.NAVAID:NewDME(map, name, frequency, coordinate)
    if not isNumber(frequency) then
        error("DCAF.NAVAID:NewDME :: `frequency` must be a number but was: " .. DumpPretty(frequency)) end
    local dme = DCAF.NAVAID:New(map, name, coordinate, DCAF.NAVAID_TYPE.DME)
    dme.Frequency = frequency
    return dme
end

function DCAF.NAVAID:NewTACAN(map, name, channel, mode, coordinate)
    if not isNumber(channel) then
        error("DCAF.NAVAID:NewTACAN :: `channel` must be a number but was: " .. DumpPretty(channel)) end
    if mode == nil then
        mode = "X"
    end
    if not isAssignedString(mode) then
        error("DCAF.NAVAID:NewTACAN :: `mode` must be assigned string but was: " .. DumpPretty(mode))
    elseif not DCAF_TACAN:IsValidMode(mode) then
        error("DCAF.NAVAID:NewTACAN :: invalid `mode`: " .. DumpPretty(mode))
    end
    
    local tacan = DCAF.NAVAID:New(map, name, coordinate, DCAF.NAVAID_TYPE.TACAN)
    tacan.Channel = channel
    tacan.Mode = mode
    return tacan
end

function DCAF.NAVAID:IsEmitter()
    return self.Type ~= DCAF.NAVAID_TYPE.Waypoint
end

function DCAF.NAVAID:NewVORTAC(map, name, frequency, channel, mode, coordinate)
    if not isNumber(frequency) then
        error("DCAF.NAVAID:NewVORTAC :: `frequency` must be a number but was: " .. DumpPretty(frequency)) end

    local vortac = DCAF.NAVAID:NewTACAN(map, name, channel, mode, coordinate)
    vortac.Frequency = frequency
    return vortac
end

function DCAF.NAVAID:AirTurnpoint(speedKmph, altitudeMeters, tasks)
    local waypoint = self.Coordinate:WaypointAirTurningPoint(
        COORDINATE.WaypointAltType.BARO,
        speedKmph,
        tasks,
        self.Name)
    if isNumber(altitudeMeters) then
        waypoint.alt = altitudeMeters
    end
    return waypoint
end

function DCAF.NAVAID:Draw(coalition, text, color, size)
    if not isTable(color) then
        color = {0,0,0}
    end
    if isBoolean(text) and text then
        text = self.Name
    end
    if not isNumber(size) then
        size = 2000
    end
    if not self:IsEmitter() then
        local coordN = self.Coordinate:Translate(size * .5, 0)
        local coordE = self.Coordinate:Translate(size * .5, 90)
        local coordS = self.Coordinate:Translate(size * .5, 180)
        local coordW = self.Coordinate:Translate(size * .5, 270)
        coordN:QuadToAll(coordE, coordS, coordW, coalition, color, .5, color, 0.5, 0, true)
    end
    -- self.Coordinate:CircleToAll(size, coalition, color, nil, color, .5, 0, true, self.Name)
    if isAssignedString(text) then
        local coordText = self.Coordinate:Translate(size*.5 + 1000, 180)
        -- coordText = coordText:Translate(size*.5, 270)
        coordText:TextToAll(self.Name, coalition, color, nil, nil, 0, 10)
    end
end

function DCAF.AIRAC:DrawNavaids(map, coalition, text, color, size)
    if not isAssignedString(map) then
        error("DCAF.AIRAC:DrawNavaids :: `map` must be assigned string but was: " .. DumpPretty(map)) end
    if not DCSMAP:IsValid(map) then
        error("DCAF.AIRAC:DrawNavaids :: unknown `map`: " .. map) end
    if not isBoolean(text) then
        text = true 
    end
    for name, navaid in pairs(DCAF.AIRAC.NAVAIDS) do
        if navaid.Map == map then
            navaid:Draw(coalition, text, color, size)
        end
    end
end

-- convert Decimal Coords: https://www.latlong.net/degrees-minutes-seconds-to-decimal-degrees
--                     or: https://www.fcc.gov/media/radio/dms-decimal

DCAF.AIRAC.NAVAIDS = {
    -- Persian Gulf (PEG) - Waypoints
    ULDUR = DCAF.NAVAID:NewWaypoint(DCSMAP.PersianGulf, "ULDUR", COORDINATE:NewFromLLDD(31.34194444, 47.11500000)),
    RETEL = DCAF.NAVAID:NewWaypoint(DCSMAP.PersianGulf, "RETEL", COORDINATE:NewFromLLDD(29.03555556, 48.64222222)),
    ROTEL = DCAF.NAVAID:NewWaypoint(DCSMAP.PersianGulf, "ROTEL", COORDINATE:NewFromLLDD(26.83888889, 50.69611111)),
    TUMAK = DCAF.NAVAID:NewWaypoint(DCSMAP.PersianGulf, "TUMAK", COORDINATE:NewFromLLDD(26.00083333, 52.78694444)),
    -- ALSAS = DCAF.NAVAID:NewWaypoint(DCSMAP.PersianGulf, "ALSAS", COORDINATE:NewFromLLDD(24.15972222, 59.18305556)),
    ALSAS = DCAF.NAVAID:NewWaypoint(DCSMAP.PersianGulf, "ALSAS", COORDINATE:NewFromLLDD(24.01500000, 59.33194444)),
    DESPI = DCAF.NAVAID:NewWaypoint(DCSMAP.PersianGulf, "DESPI", COORDINATE:NewFromLLDD(23.83083333, 56.51944444)),
    PUTSO = DCAF.NAVAID:NewWaypoint(DCSMAP.PersianGulf, "PUTSO", COORDINATE:NewFromLLDD(23.34361100, 56.88944400)),
    PARAR = DCAF.NAVAID:NewWaypoint(DCSMAP.PersianGulf, "PARAR", COORDINATE:NewFromLLDD(22.82555556, 63.75138889)),
    -- Persian Gulf (PEG) - VOR/DME)
    ADV = DCAF.NAVAID:NewVOR(DCSMAP.PersianGulf, "ADV", 114.25, COORDINATE:NewFromLLDD(24.44166667, 54.65611111)),  -- UAE, Abu Dhabi Intl. airport
    AJR = DCAF.NAVAID:NewVOR(DCSMAP.PersianGulf, "AJR", 114.90, COORDINATE:NewFromLLDD(30.74694444, 49.66638889)),  -- Iran, Aghajari Airport (north, bordering Iraq)
    ALN = DCAF.NAVAID:NewVOR(DCSMAP.PersianGulf, "ALN", 116.60, COORDINATE:NewFromLLDD(24.25888889, 55.60611111)),   
    AWZ = DCAF.NAVAID:NewVOR(DCSMAP.PersianGulf, "AWZ", 114.00, COORDINATE:NewFromLLDD(31.33361111, 48.75333333)),  -- Iran, Ahwaz airport
    BND = DCAF.NAVAID:NewVOR(DCSMAP.PersianGulf, "BND", 117.20, COORDINATE:NewFromLLDD(27.19694444, 56.36694444)),  -- Iran, Bandar Abbas Intl.
    BUZ = DCAF.NAVAID:NewVOR(DCSMAP.PersianGulf, "BUZ", 117.45, COORDINATE:NewFromLLDD(28.95416667, 50.82250000)),  -- Iran west coast, up north
    CBH = DCAF.NAVAID:NewVOR(DCSMAP.PersianGulf, "CBH", 115.60, COORDINATE:NewFromLLDD(25.44222222, 60.41833333)),  -- Iran, coast, far east
    DOH = DCAF.NAVAID:NewVOR(DCSMAP.PersianGulf, "DOH", 114.40, COORDINATE:NewFromLLDD(25.24666667, 51.60888889)),  -- Quatar, Dohar Intl. airport
    FJV = DCAF.NAVAID:NewVOR(DCSMAP.PersianGulf, "FJV", 113.80, COORDINATE:NewFromLLDD(25.10055556, 56.35444444)),  -- UAE, Fujairah intl airport.
    ISR = DCAF.NAVAID:NewVOR(DCSMAP.PersianGulf, "ISR", 117.00, COORDINATE:NewFromLLDD(27.25083333, 60.74305556)),  -- Iran, 230 nm east Bandar Abbas
    KHM = DCAF.NAVAID:NewVOR(DCSMAP.PersianGulf, "KHM", 117.10, COORDINATE:NewFromLLDD(26.76277778, 55.90777778)),  -- Iran, Queshm island
    LAM = DCAF.NAVAID:NewVOR(DCSMAP.PersianGulf, "LAM", 117.00, COORDINATE:NewFromLLDD(27.37305556, 53.18972222)),  -- Iran, 34nm north Lavan isl.
    LAR = DCAF.NAVAID:NewVOR(DCSMAP.PersianGulf, "LAR", 117.90, COORDINATE:NewFromLLDD(27.67472222, 54.41611111)),  -- Iran, Lar airport
    LEN = DCAF.NAVAID:NewVOR(DCSMAP.PersianGulf, "LEN", 114.80, COORDINATE:NewFromLLDD(26.53611111, 54.85111111)),  -- Iran, Bandar Lengeh airport
    LVA = DCAF.NAVAID:NewVOR(DCSMAP.PersianGulf, "LVA", 116.85, COORDINATE:NewFromLLDD(26.81194444, 53.35583333)),  -- Iran, Lavan island
    SRJ = DCAF.NAVAID:NewVOR(DCSMAP.PersianGulf, "SRJ", 114.60, COORDINATE:NewFromLLDD(29.55611111, 55.66277778)),  -- Iran, 78nm SW Kerman
    SYZ = DCAF.NAVAID:NewVOR(DCSMAP.PersianGulf, "SYZ", 117.80, COORDINATE:NewFromLLDD(29.54000000, 52.58861111)),  -- Iran, Shiraz Intl
    ZDN = DCAF.NAVAID:NewVOR(DCSMAP.PersianGulf, "ZDN", 116.00, COORDINATE:NewFromLLDD(29.47861111, 60.89694444)),  -- Iran, 210nm ESE of Kerman 
    -- Persian Gulf (PEG) - (TACAN/VORTAC)
    BNDX = DCAF.NAVAID:NewTACAN( DCSMAP.PersianGulf, "BND",          78, 'X', COORDINATE:NewFromLLDD(27.21694444, 56.38083333)),    -- Iran, Bandar Abbas Intl.
    MIN  = DCAF.NAVAID:NewTACAN( DCSMAP.PersianGulf, "MIN",          99, 'X', COORDINATE:NewFromLLDD(25.02694444, 55.39555556)),    -- UAE, Al Minhad AFB
    MA   = DCAF.NAVAID:NewVORTAC(DCSMAP.PersianGulf, "MA",   114.9,  96, nil, COORDINATE:NewFromLLDD(24.24666667, 54.54527778)),    -- UAE, Al Dhafra AFB
    OMLW = DCAF.NAVAID:NewVORTAC(DCSMAP.PersianGulf, "OMLW", 117.4, 121, nil, COORDINATE:NewFromLLDD(23.66750000, 53.80361111)),    -- UAE, Liwa AFB
    SYZ1 = DCAF.NAVAID:NewTACAN( DCSMAP.PersianGulf, "SYZ1",         94, 'X', COORDINATE:NewFromLLDD(29.54166667, 52.58861111)),    -- Iran, Shiraz Intl

--[[
    ??? = DCAF.NAVAID:NewVOR(DCSMAP.PersianGulf, "???", ???.??, COORDINATE:NewFromLLDD(XXX, YYY)),
    ??? = DCAF.NAVAID:NewTACAN(DCSMAP.PersianGulf, "???", ??, 'X', COORDINATE:NewFromLLDD(XXX, YYY)),
    ??? = DCAF.NAVAID:NewVORTAC(DCSMAP.PersianGulf, "???", ???.?, ??, 'X', COORDINATE:NewFromLLDD(XXX, YYY)),
]]
}


-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                        AIR ROUTES 
-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

local DCAF_ROUTE_COUNT = 1

DCAF.AIR_ROUTE = {
    ClassName = "DCAF.ROUTE",
    Name = nil,                         -- #string - name of route
    Waypoints = {},
}

DCAF.AIR_ROUTE_OPTIONS = {
    ClassName = "DCAF.AIR_ROUTE_OPTIONS",
    InvisibleToHostileAI = true,
    CruiseSpeedKnots = 0,
    CruiseAltitudeFeet = 0,
    SID = true,                        -- #string or #boolean - when set; a SID procedure is inserted into route. Use #string to specify SID or #boolean to auto-select a SID
    STAR = true                        -- #string or #boolean - when set; a STAR procedure is inserted into route. Use #string to specify STAR or #boolean to auto-select a STAR
}

DCAF.AIR_ROUTE_PHASE = {
    Takeoff = "Takeoff",
    Land = "Land",
    Enroute = "Enroute",
    SID = "SID",
    STAR = "STAR"
}

local function getGroupMaxSpeed(group)
    local lowest = 99999
    for _, unit in ipairs(group:GetUnits()) do
        lowest = math.min(lowest, unit:GetSpeedMax())
    end
    return lowest
end

local function genericRouteName()
    return "ROUTE-" .. Dump(DCAF_ROUTE_COUNT)
end

function DCAF.AIR_ROUTE:New(name, route)
    if not isAssignedString(route) then
        error("DCAF.ROUTE:New :: `route` must be assigned string") end

    local idents = {}
    for ident in route:gmatch("%w+") do 
        table.insert(idents, ident) 
    end
    return DCAF.AIR_ROUTE:NewFromNavaids(name, idents)
end

function DCAF.AIR_ROUTE:NewFromWaypoints(name, waypoints)
    if not isAssignedString(name) then
        name = genericRouteName()
    end
    if not isTable(waypoints) then
        error("DCAF.AIR_ROUTE:NewFromWaypoints :: `waypoints` must be table but was: " .. type(waypoints)) end

    local route = DCAF.clone(DCAF.AIR_ROUTE)
    route.Name = name
    route.Waypoints = waypoints
    DCAF_ROUTE_COUNT = DCAF_ROUTE_COUNT+1
    return route
end

function DCAF.AIR_ROUTE:NewFromNavaids(name, idents)
    if not isAssignedString(name) then
        name = genericRouteName()
    end
    if not isTable(idents) then
        error("DCAF.ROUTE:NewFromNavaids :: `idents` must be table (list of navaid identifiers)") end

    local departureAirbase, destinationAirbase
    local function makeEnrouteWaypoint(ident, index)
        local waypoint
        local phase = DCAF.AIR_ROUTE_PHASE.Enroute
        if isClass(ident, DCAF.NAVAID.ClassName) then
            waypoint = ident:AirTurnpoint()
        elseif isClass(ident, AIRBASE.ClassName) then
            local airbase = ident
            local coord = airbase:GetCoordinate()
            if index == 1 then
                departureAirbase = airbase
                local departureWP = coord:WaypointAirTakeOffParkingHot(COORDINATE.WaypointAltType.BARO) -- todo consider ability to configure type of takeoff
                departureWP.airdromeId = airbase:GetID()
                waypoint =  departureWP
                phase = DCAF.AIR_ROUTE_PHASE.Takeoff
            else
                -- waypoint =  WaypointLandAt(airbase)
                waypoint =  coord:WaypointAirLanding(250, airbase, nil, DCAF.AIRAC.ICAO:GetAirbaseICAO(airbase))
                waypoint.speed = 70
                phase = DCAF.AIR_ROUTE_PHASE.Land
                destinationAirbase = airbase
            end
        else
            error("DCAF.ROUTE:New :: arg[" .. Dump(index) .. "] was not type " .. DCAF.NAVAID.ClassName)
        end
        waypoint[CONSTANTS.RouteProcedure] = phase
        return waypoint
    end

    local route = DCAF.clone(DCAF.AIR_ROUTE)
    for i = 1, #idents, 1 do
        local ident = idents[i]
        if isAssignedString(ident) then
            ident = DCAF.AIRAC.NAVAIDS[ident]
            if not ident then
                if i == 1 or i == #idents then
                    local airbaseName = DCAF.AIRAC.ICAO[idents[i]].Name
                    if airbaseName then
                        local airbase = AIRBASE:FindByName(airbaseName)
                        if airbase then
                            ident = airbase
                        end
                    end
                end
            end
            if not ident then
                error("DCAF.ROUTE:New :: idents[" .. Dump(i) .. "] was unknown NAVAID: '" .. idents[i] .. "'")  end
        end
        if not isClass(ident, DCAF.NAVAID.ClassName) and not isClass(ident, AIRBASE.ClassName) then
            error("DCAF.ROUTE:New :: idents[" .. Dump(i) .. "] was not type " .. DCAF.NAVAID.ClassName) end

        table.insert(route.Waypoints, makeEnrouteWaypoint(ident, i))
    end
    route.Name = name
    route.DepartureAirbase = departureAirbase
    route.DestinationAirbase = destinationAirbase
    DCAF_ROUTE_COUNT = DCAF_ROUTE_COUNT+1
    return route
end

function DCAF.AIR_ROUTE:Clone()
    return DCAF.clone(self)
end

function DCAF.AIR_ROUTE:CloneReversed(name)
    if not isAssignedString(name) then
        name = genericRouteName()
    end
    local clone = DCAF.clone(self)
    clone.Waypoint = listReverse(self.Waypoints)
    clone.Name = name
    DCAF_ROUTE_COUNT = DCAF_ROUTE_COUNT+1
    return clone
end

function DCAF.AIR_ROUTE:WithCruiseAltitude(altitudeFeet)
    self.CruiseAltitudeFeet = altitudeFeet
    if not isNumber(altitudeFeet) then
        error("DCAF.ROUTE:WithAltutide :: `altitudeMeters` must be a number but was: " .. DumpPretty(altitudeFeet)) end
    if #self.Waypoints == 0 then
        error("DCAF.ROUTE:WithAltutide :: route '" .. self.Name .. "' contains no waypoints") end

    for _, wp in ipairs(self.Waypoints) do
        wp.alt = altitudeFeet
    end
    return self 
end

function DCAF.AIR_ROUTE:WithCruiseSpeed(speedKnots)
    self.CruiseSpeedKnots = speedKnots
    if not isNumber(speedKnots) then
        error("DCAF.ROUTE:WithSpeed :: `speedKmph` must be a number but was: " .. DumpPretty(speedKnots)) end
    if #self.Waypoints == 0 then
        error("DCAF.ROUTE:WithSpeed :: route '" .. self.Name .. "' contains no waypoints") end

    for _, wp in ipairs(self.Waypoints) do
        wp.speed = Knots(speedKnots)
    end
    return self 
end

local function setCruiseParameters(airRoute, cruiseSpeedKnots, cruiseAltitudeFeet)

    local function set(wp, speedKnots, altitudeFeet)
        if wp[CONSTANTS.RouteProcedure] == DCAF.AIR_ROUTE_PHASE.Enroute or wp.alt == 0 then
            wp.alt = Feet(altitudeFeet)
        end
        if wp[CONSTANTS.RouteProcedure] == DCAF.AIR_ROUTE_PHASE.Enroute or wp.speed == 0 then
            wp.speed = Knots(speedKnots)
        end
    end

    local firstWP = airRoute.Waypoints[1]
    set(firstWP, cruiseSpeedKnots, cruiseAltitudeFeet)
    local prevCoord = COORDINATE_FromWaypoint(firstWP)
    for i = 2, #airRoute.Waypoints, 1 do
        local altitude = cruiseAltitudeFeet or 30000
        -- local speed = cruiseSpeedKnots obsolete
        local wp = airRoute.Waypoints[i]
        local coord = COORDINATE_FromWaypoint(wp)
        local heading = prevCoord:GetHeadingTo(coord)
        -- correct cruise altitude for heading...
        if heading > 180 then
            if altitude % 2 ~= 0 then
                -- change to even altitude
                altitude = altitude - 1000
            end
        else
            if altitude % 2 == 0 then
                -- change to uneven altitude
                altitude = altitude + 1000
            end
        end
        set(wp, cruiseSpeedKnots, altitude)
        prevCoord = coord
    end
end

function DCAF.AIR_ROUTE_OPTIONS:New(cruiseSpeedKt, cruiseAltitudeFt, sid, star)
    local options = DCAF.clone(DCAF.AIR_ROUTE_OPTIONS)
    if cruiseSpeedKt ~= nil and not isNumber(cruiseSpeedKt) then
        error("DCAF.AIR_ROUTE_OPTIONS:New :: `cruiseSpeedKt` must be a number (knots)") end
    if cruiseAltitudeFt ~= nil and not isNumber(cruiseAltitudeFt) then
        error("DCAF.AIR_ROUTE_OPTIONS:New :: `cruiseAltitudeFt` must be a number (feet)") end
    if sid ~= nil and not isBoolean(sid) and not isAssignedString(sid) then
        error("DCAF.AIR_ROUTE_OPTIONS:New :: `sid` must be a boolean (true to auto assign SID) or a string (name of SID)") end
    if sid ~= nil and not isBoolean(star) and not isAssignedString(star) then
        error("DCAF.AIR_ROUTE_OPTIONS:New :: `star` must be a boolean (true to auto assign STAR) or a string (name of STAR)") end
                
    options.CruiseSpeedKnots = cruiseSpeedKt
    options.CruiseAltitudeFeet = cruiseAltitudeFt
    if sid ~= nil then
        options.SID = sid or DCAF.AIR_ROUTE_OPTIONS.SID
    else
        options.SID = DCAF.AIR_ROUTE_OPTIONS.SID
    end
    if star ~= nil then
        options.STAR = star
    else
        options.STAR = DCAF.AIR_ROUTE_OPTIONS.STAR
    end
    return options
end

local function alignCoalitionWithDestination(spawn, route)
    if not route.DestinationAirbase then
        return end

    local destinationCoalition = route.DestinationAirbase:GetCoalition()
    local destinationCountry = DCAF.AIRAC.ICAO:GetCountry(route.DestinationAirbase)
    -- local spawnCoalition = spawn:GetCoalition()
    -- if destinationCoalition == spawnCoalition then
    --     return end
    
Debug("nisse - alignCoalitionWithDestination :: sets coalition: " .. DumpPretty(destinationCoalition) .. ":: and country: " .. Dump(destinationCountry))
    spawn:InitCountry(destinationCountry)
    spawn:InitCoalition(destinationCoalition)
    return destinationCoalition
end

function DCAF.AIR_ROUTE:Fly(controllable, options) --  cruiseSpeedKmph, cruiseAltitudeMeters, sid, star)
    if not isClass(controllable, GROUP.ClassName) and not isClass(controllable, SPAWN.ClassName) then
        error("DCAF.AIR_ROUTE:Fly :: `controllable` must be type " .. GROUP.ClassName .. " or " .. SPAWN.ClassName) end
    if #self.Waypoints == 0 then
        error("DCAF.AIR_ROUTE:Fly :: route is empty (no waypoints)") end
    
    if not isClass(options, DCAF.AIR_ROUTE_OPTIONS.ClassName) then
        options = DCAF.AIR_ROUTE_OPTIONS:New() 
    end

    local cruiseAltitudeFeet = options.CruiseAltitudeFeet or 30000
    if cruiseAltitudeFeet == 0 then
        cruiseAltitudeFeet = self.CruiseAltitudeFeetFeet or 30000
        -- todo consider optimizing cruise altitude depending on distance
    end
    local cruiseSpeedKnots = options.CruiseSpeedKnots
    if cruiseSpeedKnots == 0 then
Debug("DCAF.AIR_ROUTE:Fly :: route.CruiseSpeedKnots: " .. Dump(route.CruiseSpeedKnots) .. " :: getGroupMaxSpeed: " .. Dump(getGroupMaxSpeed(route.Group)))   
        cruiseSpeedKnots = Knots(route.CruiseSpeedKnots) or getGroupMaxSpeed(route.Group) * .8
    end

    -- clone AIR_ROUTE and set speeds and altitudes ...
    local route = self:Clone()

    -- spawn if `group` is SPAWN...
    route.Group = controllable
    if isClass(controllable, SPAWN.ClassName) then
        -- ensure correct coalition for destination...
        alignCoalitionWithDestination(controllable, route)
        -- spawn group ...
        if route.DepartureAirbase then
            route.Group = controllable:SpawnAtAirbase(route.DepartureAirbase)
        else
            local firstWP = route.Waypoints[1]
            local nextWP
            local coordAirSpawn = COORDINATE_FromWaypoint(firstWP)
            if #route.Waypoints > 1 then
                nextWP = route.Waypoints[2]
                local coordNextWP = COORDINATE_FromWaypoint(nextWP)
                local initialHeading = coordAirSpawn:GetHeadingTo(coordNextWP)
Debug("DCAF.AIR_ROUTE:Fly :: initialHeading: " .. Dump(initialHeading))
                coordAirSpawn:SetHeading(initialHeading)
            end
            coordAirSpawn:SetVelocity(Knots(cruiseSpeedKnots))
            coordAirSpawn:SetAltitude(Feet(cruiseAltitudeFeet))
            route.Group = controllable:SpawnFromCoordinate(coordAirSpawn)
        end
    end
    setCruiseParameters(route, cruiseSpeedKnots, cruiseAltitudeFeet)
    if options.STAR then
        route:SetSTAR(options.STAR)
    end

    -- make AI-invisible if configured for it...
    local groupCoalition = route.Group:GetCoalition()
    local country = route.Group:GetCountry()
Debug("DCAF.AIR_ROUTE:Fly :: groupCoalition: " .. Dump(groupCoalition) .. " :: country: " .. Dump(country) .. " options.InvisibleToHostileAI: " .. DumpPretty(options.InvisibleToHostileAI))
    if options.InvisibleToHostileAI and groupCoalition ~= coalition.side.NEUTRAL then
        Trace("DCAF.AIR_ROUTE:Fly :: makes group AI invisible: " .. route.Group.GroupName)
        route.Group:SetCommandInvisible(true)
    end
    route.Group:Route(route.Waypoints)

    return route
end

function DCAF.AIR_ROUTE:GetSTAR()
    return self.STAR
end

function DCAF.AIR_ROUTE:SetSTAR(star)
    if self.DestinationAirbase == nil then
        error("DCAF.AIR_ROUTE:SetSTAR :: route have no destination airport") end

    if isBoolean(star) then
        -- todo pick suitable STAR for arrival and active runway and 
        if star then
            star = DCAF.AIR_ROUTE:GetGenericSTAR(self.DestinationAirbase)
        else
            return
        end
    else
        if isAssignedString(star) then
            local cached = DCAF.AIRAC.STAR[star]
            if not cached then
                error("DCAF.AIR_ROUTE:SetSTAR :: `star` is not in AIRAC: '" .. star .. "'")  end
            star = cached
        elseif not isClass(star, DCAF.AIR_ROUTE.ClassName) then
            error("DCAF.AIR_ROUTE:SetSTAR :: `star` must be type " .. DCAF.AIR_ROUTE.ClassName) 
        end
    end
    if #star.Waypoints == 0 then
        error("DCAF.AIR_ROUTE:SetSTAR :: `star` is empty (no waypoints)") end

    self:DeleteSTAR()
    local starWaypoints = DCAF.clone(star.Waypoints)
    local waypoints = listCopy(starWaypoints, self.Waypoints, 1, #self.Waypoints)
    self.Waypoints = waypoints
    return self
end

function DCAF.AIR_ROUTE:DeleteSTAR()
    if self.STAR == nil then 
        return self end
    
    local isStar = false
    for i = #self.Waypoints, 1, -1 do
        local wp = self.Waypoints[i]
        if wp.Phase == DCAF.AIR_ROUTE_PHASE.STAR then
            isStar = true
            table.remove(self.Waypoints, i)
        elseif isStar then
            -- no more STAR waypoints...
            break
        end
    end
end

--- Returns length of route (meters)
function DCAF.AIR_ROUTE:GetLength()
    local firstWP = self.Waypoints[1]
    local prevCoord = COORDINATE_FromWaypoint(firstWP)
    local distance = 0
    for i = 2, #self.Waypoints, 1 do
        local wp = self.Waypoints[i]
        local coord = COORDINATE_FromWaypoint(wp)
        distance = distance + prevCoord:Get2DDistance(coord)
        prevCoord = coord
    end
    return distance
end

--- generates a 'generic' STAR procedure for specified airbase (just a waypoint 15nm out from active RWY)
function DCAF.AIR_ROUTE:GetGenericSTAR(airbase, speedKmph)
    local icao = DCAF.AIRAC.ICAO:GetAirbaseICAO(airbase)
    if not icao then
        error("DCAF.AIR_ROUTE:GetGenericStar :: cannot resolve ICAO code for airbase: " .. DumpPretty(airbase)) end
    
    if not isNumber(speedKmph) then
        speedKmph = UTILS.KnotsToKmph(250) end

    local activeRWY = airbase:GetActiveRunwayLanding()
    local starName = icao .. "-" ..  activeRWY.name
    local star = DCAF.AIRAC.STAR:Get(starName)
    if star then 
        return star end

    local hdg = ReciprocalAngle(activeRWY.heading)
    local coordAirbase = airbase:GetCoordinate()
    local coordWP = coordAirbase:Translate(NauticalMiles(20), hdg)
    local airbaseAltitude = airbase:GetAltitude()
    -- coordWP:SetAltitude(Feet(12000))
    local wp = coordWP:WaypointAirTurningPoint(
        COORDINATE.WaypointAltType.BARO,
        speedKmph,
        nil,
        starName)
    wp.alt = Feet(10000)
    wp.alt_type = COORDINATE.WaypointAltType.RADIO
    return DCAF.AIRAC.STAR:New(starName, { wp }) --   DCAF.AIR_ROUTE:NewFromWaypoints(starName, { wp })
end

-- function DCAF.ROUTE:ExecuteFor(source)
--     local group = getGroup(source)
--     if not group then 
--         error("DCAF.ROUTE:ExecuteFor :: cannot resolve group from " .. DumpPretty(source)) end

--     local route = DCAF.clone(self)
--     route.Name = group.GroupName .. "::" .. route.Name
--     group:Route(route.Waypoints)
--     route.ExecutingGroup = group

-- Debug("DCAF.ROUTE:ExecuteFor :: lastWP: " .. DumpPrettyDeep(lastWP))    
--     return route
-- end

-- function DCAF.ROUTE:OnCompleted(func)
--     local lastWP = self.Waypoints[#self.Waypoints]
--     if lastWP.type == "Turning Point" then
--         -- create zone and check for group entering
--         local coordLastWP = COORDINATE:New(lastWP.x, lastWP.alt, lastWP.y)
--         coord
--     elseif lastWP.type == "Land" then
--         local _onLandedFunc
--         local function onLanded(event)
-- Debug("nisse - DCAF.ROUTE:OnCompleted :: onLanded :: event: " .. DumpPrettyDeep(event))
--             MissionEvents:EndOnAircraftLanded(_onLandedFunc)
--         end
--         _onLandedFunc = onLanded
--         MissionEvents:OnAircraftLanded(_onLandedFunc)
--     end
    
-- end

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                   PROCEDURES (SID/STAR)
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function DCAF.AIRAC.STAR:New(name, waypoints)
    if not isAssignedString(name) then
        error("DCAF.AIRAC.STAR:New :: `name` must be assigned string") end
    if DCAF.AIRAC.STAR[name] then
        error("DCAF.AIRAC.STAR:New :: a STAR was already created with same `name`: '" .. name .. "'") end

    local star = DCAF.AIR_ROUTE:NewFromWaypoints(name, waypoints)
    for _, wp in ipairs(waypoints) do
        wp[CONSTANTS.RouteProcedure] = DCAF.AIR_ROUTE_PHASE.STAR
        wp[CONSTANTS.RouteProcedureName] = name
    end
    DCAF.AIRAC.STAR[name] = star -- cache for future reference
    return star
end

function DCAF.AIRAC.STAR:Get(name)
    return DCAF.AIRAC.STAR[name]
end

-- todo


--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                     PEG - Persian Gulf
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

addAIRACAerodromes(
    AIRAC_Aerodrome:New(AIRBASE.PersianGulf.Abu_Dhabi_International_Airport, 'OMAA')
            :WithATIS( 376.50 ) -- OK
            :WithGND({ 250.05, 119.05 })
            :WithTWR({ 250.60, 119.30 })
            :WithDEP({ 250.60, 119.60 })
            :WithTACAN(96)
            :WithVoice(ATIS.Culture.Random, ATIS.Gender.Random),

    AIRAC_Aerodrome:New(AIRBASE.PersianGulf.Al_Dhafra_AB, 'OMAM')
            :WithATIS(  125.00 )  -- OK
            :WithGND({ 251.05, 126.05 })
            :WithTWR({ 251.20, 126.60 })
            :WithDEP({ 251.60, 126.60 })
            :WithTACAN(96)
            :WithILS({ 
                ["13L"] = 111.10, ["31R"] = 109.10, 
                ["13R"] = 108.70, ["31L"] = 108.70 })
            :WithVoice(ATIS.Culture.Random, ATIS.Gender.Random),

    AIRAC_Aerodrome:New(AIRBASE.PersianGulf.Al_Minhad_AB, 'OMDM')
            :WithATIS( 377.75 ) -- OK
            :WithGND({ 250.05, 118.05 })
            :WithTWR({ 250.20, 118.65 })
            :WithDEP({ 250.60, 118.60 })
            :WithTACAN(99)
            :WithILS({ 
                ["27"] = 110.75, ["09"] = 110.70 })
            :WithVoice(ATIS.Culture.Random, ATIS.Gender.Random),

    AIRAC_Aerodrome:New(AIRBASE.PersianGulf.Dubai_Intl, 'OMDB')
            :WithATIS( 375.50 )  -- OK
            :WithGND({ 251.05, 118.05 })
            :WithTWR({ 251.15, 118.85 })
            :WithDEP({ 251.60, 118.60 })
            :WithILS({ 
                ["30R"] = 110.90, ["30L"] = 111.30,
                ["12L"] = 110.10, ["12R"] = 109.50 })
            :WithVoice(ATIS.Culture.Random, ATIS.Gender.Random),

    AIRAC_Aerodrome:New(AIRBASE.PersianGulf.Liwa_Airbase, 'OMAA')
            :WithATIS( 119.55 ) -- OK
            :WithGND({ 251.05, 119.05 })
            :WithTWR({ 251.05, 119.40 })
            :WithDEP({ 251.60, 119.60 })
            :WithTACAN(121)
            :WithVoice(ATIS.Culture.Random, ATIS.Gender.Random),

    AIRAC_Aerodrome:New(AIRBASE.PersianGulf.Khasab, 'OOKB')
            :WithATIS( 127.55 )  -- OK
            :WithGND({ 250.05, 124.05 })
            :WithTWR({ 250.20, 118.65 })
            :WithDEP({ 250.60, 118.60 })
            :WithILS({ ["19"] = 110.30 })
            :WithVoice(ATIS.Culture.Random, ATIS.Gender.Random),

    --== IRAN ==--
    AIRAC_Aerodrome:New(AIRBASE.PersianGulf.Bandar_Abbas_Intl, 'OIKB')
            :WithATIS( 119.85 ) -- OK
            :WithGND({ 251.05, 118.05 })
            :WithTWR({ 251.10, 118.20 })
            :WithDEP({ 251.60, 118.60 })
            :WithTACAN(78)
            :WithILS({ ["21L"] = 109.90 })
            :WithVoice(ATIS.Culture.Random, ATIS.Gender.Random),

    AIRAC_Aerodrome:New(AIRBASE.PersianGulf.Havadarya, 'OIKP')
            :WithATIS( 127.35 ) -- OK
            :WithGND({ 251.05, 123.05 })
            :WithTWR({ 251.40, 123.25 })
            :WithDEP({ 251.60, 123.60 })
            :WithTACAN(47)
            :WithILS({ ["08"] = 108.90 })
            :WithVoice(ATIS.Culture.Random, ATIS.Gender.Random),

    AIRAC_Aerodrome:New(AIRBASE.PersianGulf.Jiroft_Airport, 'OIKP')
            :WithATIS( 117.35 ) --OK
            :WithGND({ 250.05, 136.05 })
            :WithTWR({ 250.95, 136.10 })
            :WithDEP({ 250.60, 136.60 })
            :WithVoice(ATIS.Culture.Random, ATIS.Gender.Random),

    AIRAC_Aerodrome:New(AIRBASE.PersianGulf.Kerman_Airport, 'OIKK')
            :WithATIS( 121.35 ) -- OK
            :WithGND({ 250.05, 118.05 })
            :WithTWR({ 250.40, 118.35 })
            :WithDEP({ 250.60, 118.60 })
            :WithTACAN(97)
            :WithVoice(ATIS.Culture.Random, ATIS.Gender.Random),

    AIRAC_Aerodrome:New(AIRBASE.PersianGulf.Qeshm_Island, 'OIKQ')
            :WithATIS( 120.25 )  -- OK
            :WithGND({ 250.05, 118.05 })
            :WithTWR({ 250.25, 118.15 })
            :WithDEP({ 250.60, 118.60 })
            :WithVoice(ATIS.Culture.Random, ATIS.Gender.Random),

    AIRAC_Aerodrome:New(AIRBASE.PersianGulf.Shiraz_International_Airport, 'OISS')
            :WithATIS( 119.35 ) -- OK
            :WithGND({ 250.05, 118.05 })
            :WithTWR({ 250.30, 118.70 })
            :WithDEP({ 250.60, 118.60 })
            :WithTACAN(94)
            :WithILS({ 
                ["30R"] = 111.95, ["12L"] = 108.55 })
            :WithVoice(ATIS.Culture.Random, ATIS.Gender.Random)
)

function DCAF.AIRAC:StartPersianGulfATIS(SRSPath, SRSPort)
    DCAF.AIRAC:ConfigureSRS(SRSPath, SRSPort)
    for key, aerodrome in pairs(AIRBASE.PersianGulf) do
        DCAF.AIRAC:StartATIS(aerodrome)
    end
end



--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                     SYR - Syria map
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



addAIRACAerodromes(
    AIRAC_Aerodrome:New(AIRBASE.Syria.Incirlik, 'LTAG')
            :WithATIS( 377.50 )
            :WithTWR({ 360.20, 129.40 })
            :WithGND({ 360.05, 129.05 })
            :WithDEP({ 360.60, 129.60 })
            :WithTACAN(21)
            :WithILS({ ["5"] = 109.3, ["23"] = 111.7 })
            :WithVoice(ATIS.Culture.US, ATIS.Gender.Random),

        AIRAC_Aerodrome:New(AIRBASE.Syria.Gaziantep, 'LTAJ')
            :WithATIS( 119.275 )
            :WithTWR({ 250.9, 121.1 })
            :WithGND({ 250.05, 121.05 })
            :WithDEP({ 250.60, 121.60 })
            :WithILS({ ["5"] = 108.7 })
            :WithVOR( 116.7 )
            :WithVoice(ATIS.Culture.US, ATIS.Gender.Random),

        --== SYRIA Map :: BRITISH OVERSEAS TERRITORIES ==--
        AIRAC_Aerodrome:New(AIRBASE.Syria.Akrotiri, 'LCRA')
            :WithATIS( 125.00 )
            :WithTACAN(107)
            :WithGND({ 339.05, 130.05 })
            :WithTWR({ 339.85, 130.075 })
            :WithDEP({ 339.60, 130.60 })
            :WithILS({ ["28"] = 109.7} )
            :WithVoice(ATIS.Culture.GB, ATIS.Gender.Random),
        
        --== SYRIA Map :: REPUBLIC OF CYPRUS ==--
        AIRAC_Aerodrome:New(AIRBASE.Syria.Paphos, 'LCPH')
            :WithATIS( 127.325 )
            :WithTACAN(79)
            :WithGND({ 250.05, 127.05 })
            :WithTWR({ 250.05, 127.80 })
            :WithDEP({ 250.60, 127.60 })
            :WithILS({ ["29"] = 108.9 })
            :WithVoice(ATIS.Culture.Random, ATIS.Gender.Random),

        --== SYRIA Map :: ISRAEL ==--
        AIRAC_Aerodrome:New(AIRBASE.Syria.Ramat_David, 'LLRD')
            :WithATIS( 123.225 )
            :WithTACAN(84)
            :WithGND({ 250.05, 118.05 })
            :WithTWR({ 250.95, 118.60 })
            :WithDEP({ 250.60, 118.60 })
            :WithILS({ ["32"] = 111.1})
            :WithVoice(ATIS.Culture.Random, ATIS.Gender.Random),

        AIRAC_Aerodrome:New(AIRBASE.Syria.Rosh_Pina, 'LLIB')
            :WithATIS( 128.350 )
            :WithGND({ 251.05, 118.05 })
            :WithTWR({ 251.40, 118.90 })
            :WithDEP({ 251.60, 118.60 })
            :WithVoice(ATIS.Culture.Random, ATIS.Gender.Random),

        --== SYRIA Map :: SYRIA ==--
         AIRAC_Aerodrome:New(AIRBASE.Syria.Damascus, 'OSDI')
            :WithATIS( 128.225 )
            :WithGND({ 251.05, 118.05 })
            :WithTWR({ 251.45, 118.50 })
            :WithDEP({ 251.60, 118.60 })
            :WithILS({ ["23R"] = 109.9, ["05R"] = 110.1 })
            :WithVoice(ATIS.Culture.Random, ATIS.Gender.Random)
)

function DCAF.AIRAC:StartSyriaATIS(SRSPath, SRSPort)
    DCAF.AIRAC:ConfigureSRS(SRSPath, SRSPort)
    for key, name in pairs(AIRBASE.Syria) do
        local aerodrome = DCAF.AIRAC.Aerodromes[name]
        if aerodrome then
            aerodrome:StartATIS()
        end
    end
end

----------------------------------------------------------------------------------------------

Trace("DCAF.AIRAC_2022_A.lua was loaded")