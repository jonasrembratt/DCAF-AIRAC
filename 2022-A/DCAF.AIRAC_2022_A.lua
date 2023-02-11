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
    -- PEG - Iran
    OIBA = AIRBASE_INFO:New("OIBA", country.id.IRAN, AIRBASE.PersianGulf.Abu_Musa_Island_Airport),
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
    -- PEG - United Arab Emirates (UAE)
    OMAA = AIRBASE_INFO:New("OMAA", country.id.UNITED_ARAB_EMIRATES , AIRBASE.PersianGulf.Abu_Dhabi_International_Airport), 
    OMAM = AIRBASE_INFO:New("OMAM", country.id.UNITED_ARAB_EMIRATES , AIRBASE.PersianGulf.Al_Dhafra_AB),
    OMDM = AIRBASE_INFO:New("OMDM", country.id.UNITED_ARAB_EMIRATES , AIRBASE.PersianGulf.Al_Minhad_AB),
    OMDB = AIRBASE_INFO:New("OMDB", country.id.UNITED_ARAB_EMIRATES , AIRBASE.PersianGulf.Dubai_Intl),
    OMLW = AIRBASE_INFO:New("OMLW", country.id.UNITED_ARAB_EMIRATES , AIRBASE.PersianGulf.Liwa_Airbase),
    OMSJ = AIRBASE_INFO:New("OMSJ", country.id.UNITED_ARAB_EMIRATES , AIRBASE.PersianGulf.Sharjah_Intl),
    -- PEG - Oman
    OOKB = AIRBASE_INFO:New("OOKB", country.id.OMAN , AIRBASE.PersianGulf.Khasab),

    -- NTR - Nevada Test and Training Range
    KLAS = AIRBASE_INFO:New("KLAS", country.id.USA, AIRBASE.Nevada.McCarran_International_Airport ),
    KLSV = AIRBASE_INFO:New("KLSV", country.id.USA, AIRBASE.Nevada.Nellis_AFB ),
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
    Fix = "Fix",
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
    Type = DCAF.NAVAID_TYPE.Fix
}

function DCAF.NAVAID_TYPE:IsValid(type)
    return type == DCAF.NAVAID_TYPE.VOR
        or type == DCAF.NAVAID_TYPE.DME
        or type == DCAF.NAVAID_TYPE.TACAN
        or type == DCAF.NAVAID_TYPE.Fix
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
        type = DCAF.NAVAID_TYPE.Fix
    end
    
    local navaid = DCAF.clone(DCAF.NAVAID)
    navaid.Map = map
    navaid.Name = name
    navaid.Coordinate = coordinate
    navaid.Type = type
    return navaid
end

function DCAF.NAVAID:NewFix(map, name, coordinate)
    return DCAF.NAVAID:New(map, name, coordinate, DCAF.NAVAID_TYPE.Fix)
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
    return self.Type ~= DCAF.NAVAID_TYPE.Fix
end

function DCAF.NAVAID:NewVORTAC(map, name, frequency, channel, mode, coordinate)
    if not isNumber(frequency) then
        error("DCAF.NAVAID:NewVORTAC :: `frequency` must be a number but was: " .. DumpPretty(frequency)) end

    local vortac = DCAF.NAVAID:NewTACAN(map, name, channel, mode, coordinate)
    vortac.Frequency = frequency
    return vortac
end

function DCAF.NAVAID:AirTurnpoint(speedKmph, altitudeMeters, tasks)
    if not isNumber(speedKmph) and isNumber(self.SpeedKt) then
        speedKmph = Knots(self.speedKt) end

    if not isNumber(altitudeMeters) and isNumber(self.AltFt) then
        altitudeMeters = Feet(self.AltFt) end
           
    local waypoint = self.Coordinate:WaypointAirTurningPoint(
        COORDINATE.WaypointAltType.BARO,
        speedKmph,
        tasks,
        self.Name)
    if isNumber(altitudeMeters) then
        waypoint.alt = altitudeMeters
    else
        waypoint.alt = nil
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
    ALSAS = DCAF.NAVAID:NewFix(DCSMAP.PersianGulf, "ALSAS", COORDINATE:NewFromLLDD(24.01500000, 59.33194444)),
    DESPI = DCAF.NAVAID:NewFix(DCSMAP.PersianGulf, "DESPI", COORDINATE:NewFromLLDD(23.83083333, 56.51944444)),
    ELOVU = DCAF.NAVAID:NewFix(DCSMAP.PersianGulf, "ELOVU", COORDINATE:NewFromLLDD(24.95583333, 54.33805556)),
    ORSAR = DCAF.NAVAID:NewFix(DCSMAP.PersianGulf, "ORSAR", COORDINATE:NewFromLLDD(26.07500000, 53.95833333)),
    PUTSO = DCAF.NAVAID:NewFix(DCSMAP.PersianGulf, "PUTSO", COORDINATE:NewFromLLDD(23.34361100, 56.88944400)),
    PARAR = DCAF.NAVAID:NewFix(DCSMAP.PersianGulf, "PARAR", COORDINATE:NewFromLLDD(22.82555556, 63.75138889)),
    RETEL = DCAF.NAVAID:NewFix(DCSMAP.PersianGulf, "RETEL", COORDINATE:NewFromLLDD(29.03555556, 48.64222222)),
    ROTEL = DCAF.NAVAID:NewFix(DCSMAP.PersianGulf, "ROTEL", COORDINATE:NewFromLLDD(26.83888889, 50.69611111)),
    TUMAK = DCAF.NAVAID:NewFix(DCSMAP.PersianGulf, "TUMAK", COORDINATE:NewFromLLDD(26.00083333, 52.78694444)),
    TOTKU = DCAF.NAVAID:NewFix(DCSMAP.PersianGulf, "TOTKU", COORDINATE:NewFromLLDD(25.59277778, 54.06944444)),
    ULDUR = DCAF.NAVAID:NewFix(DCSMAP.PersianGulf, "ULDUR", COORDINATE:NewFromLLDD(31.34194444, 47.11500000)),
    VUTEB = DCAF.NAVAID:NewFix(DCSMAP.PersianGulf, "VUTEB", COORDINATE:NewFromLLDD(25.61250000, 54.86361111)),
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
    JIR = DCAF.NAVAID:NewVOR(DCSMAP.PersianGulf, "JIR", 276.00, COORDINATE:NewFromLLDD(28.73194444, 57.67194444)),  -- Iran, Jiroft airport
    KHM = DCAF.NAVAID:NewVOR(DCSMAP.PersianGulf, "KHM", 117.10, COORDINATE:NewFromLLDD(26.76277778, 55.90777778)),  -- Iran, Queshm island
    KIS = DCAF.NAVAID:NewVOR(DCSMAP.PersianGulf, "KIS", 117.40, COORDINATE:NewFromLLDD(26.52500000, 53.96250000)),  -- Iran, Kish isl.
    LAM = DCAF.NAVAID:NewVOR(DCSMAP.PersianGulf, "LAM", 117.00, COORDINATE:NewFromLLDD(27.37305556, 53.18972222)),  -- Iran, 34nm north Lavan isl.
    LAR = DCAF.NAVAID:NewVOR(DCSMAP.PersianGulf, "LAR", 117.90, COORDINATE:NewFromLLDD(27.67472222, 54.41611111)),  -- Iran, Lar airport
    LEN = DCAF.NAVAID:NewVOR(DCSMAP.PersianGulf, "LEN", 114.80, COORDINATE:NewFromLLDD(26.53611111, 54.85111111)),  -- Iran, Bandar Lengeh airport
    LVA = DCAF.NAVAID:NewVOR(DCSMAP.PersianGulf, "LVA", 116.85, COORDINATE:NewFromLLDD(26.81194444, 53.35583333)),  -- Iran, Lavan island
    SRJ = DCAF.NAVAID:NewVOR(DCSMAP.PersianGulf, "SRJ", 114.60, COORDINATE:NewFromLLDD(29.55611111, 55.66277778)),  -- Iran, 78nm SW Kerman
    SYZ = DCAF.NAVAID:NewVOR(DCSMAP.PersianGulf, "SYZ", 117.80, COORDINATE:NewFromLLDD(29.54000000, 52.58861111)),  -- Iran, Shiraz Intl
    ZDN = DCAF.NAVAID:NewVOR(DCSMAP.PersianGulf, "ZDN", 116.00, COORDINATE:NewFromLLDD(29.47861111, 60.89694444)),  -- Iran, 210nm ESE of Kerman 
    -- Persian Gulf (PEG) - (TACAN/VORTAC)
    BNDX = DCAF.NAVAID:NewTACAN( DCSMAP.PersianGulf, "BND",          78, 'X', COORDINATE:NewFromLLDD(27.21694444, 56.38083333)),    -- Iran, Bandar Abbas Intl.
    HDR  = DCAF.NAVAID:NewTACAN( DCSMAP.PersianGulf, "HDR",          47, 'X', COORDINATE:NewFromLLDD(27.16055556, 56.17277778)),    -- Iran, Havadarya airport
    MIN  = DCAF.NAVAID:NewTACAN( DCSMAP.PersianGulf, "MIN",          99, 'X', COORDINATE:NewFromLLDD(25.02694444, 55.39555556)),    -- UAE, Al Minhad AFB
    MA   = DCAF.NAVAID:NewVORTAC(DCSMAP.PersianGulf, "MA",   114.9,  96, nil, COORDINATE:NewFromLLDD(24.24666667, 54.54527778)),    -- UAE, Al Dhafra AFB
    OMLW = DCAF.NAVAID:NewVORTAC(DCSMAP.PersianGulf, "OMLW", 117.4, 121, nil, COORDINATE:NewFromLLDD(23.66750000, 53.80361111)),    -- UAE, Liwa AFB
    SYZ1 = DCAF.NAVAID:NewTACAN( DCSMAP.PersianGulf, "SYZ1",         94, 'X', COORDINATE:NewFromLLDD(29.54166667, 52.58861111)),    -- Iran, Shiraz Intl

    -- Nevada Test and Training Range (NTR) - Waypoints
    BESSY = DCAF.NAVAID:NewFix(DCSMAP.NTTR, "BESSY", COORDINATE:NewFromLLDD(36.17694444, -115.34611111)),
    HRRLY = DCAF.NAVAID:NewFix(DCSMAP.NTTR, "HRRLY", COORDINATE:NewFromLLDD(35.98944444, -115.34694444)),
    JOHKR = DCAF.NAVAID:NewFix(DCSMAP.NTTR, "JOHKR", COORDINATE:NewFromLLDD(35.89527778, -115.93833333)),
    KWYYN = DCAF.NAVAID:NewFix(DCSMAP.NTTR, "KWYYN", COORDINATE:NewFromLLDD(35.86527778, -115.40666667)),
    RAWKK = DCAF.NAVAID:NewFix(DCSMAP.NTTR, "RAWKK", COORDINATE:NewFromLLDD(35.87388889, -115.55694444)),

--[[
    ??? = DCAF.NAVAID:NewVOR(DCSMAP.PersianGulf, "???", ???.??, COORDINATE:NewFromLLDD(XXX, YYY)),
    ??? = DCAF.NAVAID:NewTACAN(DCSMAP.PersianGulf, "???", ??, 'X', COORDINATE:NewFromLLDD(XXX, YYY)),
    ??? = DCAF.NAVAID:NewVORTAC(DCSMAP.PersianGulf, "???", ???.?, ??, 'X', COORDINATE:NewFromLLDD(XXX, YYY)),
]]
}


-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                        AIR ROUTES 
-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-- https://flightcrewguide.com/wiki/rules-regulations/flight-plan/

local DCAF_ROUTE_COUNT = 1

DCAF.AIR_ROUTE = {
    ClassName = "DCAF.ROUTE",
    Name = nil,                         -- #string - name of route
    Waypoints = {},
}

DCAF.AIR_ROUTE_OPTIONS = {
    ClassName = "DCAF.AIR_ROUTE_OPTIONS",
    InvisibleToHostileAI = true,
    CruiseSpeedKnots = 400,
    CruiseAltitudeFeet = 30000,
    SID = true,                        -- #string or #boolean - when set; a SID procedure is inserted into route. Use #string to specify SID or #boolean to auto-select a SID
    STAR = true,                       -- #string or #boolean - when set; a STAR procedure is inserted into route. Use #string to specify STAR or #boolean to auto-select a STAR
    OnArrivalFunc = nil                -- #function 
}

function DCAF.AIR_ROUTE_OPTIONS:OnArrival(func)
    if not isFunction(func) then
        error("DCAF.AIR_ROUTE_OPTIONS:OnArrival :: `func` must be functon, but was " .. type(func)) end

    self.OnArrivalFunc = func
end

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

function DCAF.AIR_ROUTE:New(name, route, phase, proc)
    if not isAssignedString(route) then
        error("DCAF.ROUTE:New :: `route` must be assigned string") end

    local idents = {}
    for ident in route:gmatch("%S+") do 
        table.insert(idents, ident) 
    end
    local airRoute = DCAF.AIR_ROUTE:NewFromNavaids(name, idents, phase, proc)
    airRoute.RouteText = route
    return airRoute
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

DCAF.AIR_ROUTE_SPAWNMETHOD = {
    Air = "air",
    Hot = "hot",
    Cold = "cold",
    Runway = "runway"
}

function DCAF.AIR_ROUTE_SPAWNMETHOD:IsAny(value)
    for _, v in pairs(DCAF.AIR_ROUTE_SPAWNMETHOD) do
        if value == v then
            return v
        end
    end
end

function DCAF.AIR_ROUTE_SPAWNMETHOD:ResolveMOOSETakeoff(value)
    if value == DCAF.AIR_ROUTE_SPAWNMETHOD.Cold then
        return SPAWN.Takeoff.Cold

    elseif DCAF.AIR_ROUTE_SPAWNMETHOD.Hot then
        return SPAWN.Takeoff.Hot

    elseif DCAF.AIR_ROUTE_SPAWNMETHOD.Runway then
        return SPAWN.Takeoff.Runway

    elseif DCAF.AIR_ROUTE_SPAWNMETHOD.Air then
        return SPAWN.Takeoff.Air

    else
        error("DCAF.AIR_ROUTE_SPAWNMETHOD:ResolveMOOSETakeoff :: cannot resolve value: " .. DumpPretty(value))

    end
end

AIRAC_IDENT = {
    ClassName = "AIRAC_IDENT",
    Name = nil,
    SpeedKt = nil,
    AltFt = nil
}

function AIRAC_IDENT:New(s)
    if not isAssignedString(s) then
        error("IDENT:New :: `s` must be assigned string but was: " .. DumpPretty(s)) end

    local items = {}
    for e in s:gmatch('[^/]+') do
        table.insert(items, e)
    end
    local ident = DCAF.clone(AIRAC_IDENT)
    ident.Name = items[1]
    if #items == 1 then
        return ident end

    local function eatNum(s, start)
        local starts, ends = string.find(s, "%d+")
        if starts == nil then
            return end

        local num = tonumber(string.sub(s, starts, ends))
        return num, ends+1
    end

    local item = items[2]
    local speedKt, alt, altUnit
    local qualifier = string.sub(item, 1, 1)
    if qualifier == 'N' then
        -- speed in knots...
        local kt, next = eatNum(item, 2)
        item = string.sub(item, next)
        ident.SpeedKt = kt
    elseif qualifier == 'M' then
        -- speed in MACH...
        local m, next = eatNum(item, 2)
        ident.SpeedKt = MachToKnots(m/100)
        item = string.sub(item, next)
    end
    if string.len(item) == 0 then
        return ident end

    qualifier = string.sub(item, 1, 1)
    if qualifier == 'F' or qualifier == 'A' then
        -- altitude in Flight level (feet / 100)...
        local ft, next = eatNum(item, 2)
        ident.AltFt = ft * 100
        item = string.sub(item, next)
    elseif qualifier == 'S' or qualifier == 'M' then
        -- altitude in standard metric (meters / 10)...
        local m, next = eatNum(item, 2)
        ident.AltFt = UTILS.MetersToFeet(m * 10)
        item = string.sub(item, next)
    end
    return ident
end

function AIRAC_IDENT:IsRestricted()
    return isNumber(self.AltFt) or isNumber(self.SpeedKt)
end

function DCAF.AIR_ROUTE:NewFromNavaids(name, idents, phase, proc)
-- Debug("nisse - DCAF.AIR_ROUTE:NewFromNavaids :: idents: " .. DumpPretty(idents))

    if not isAssignedString(name) then
        name = genericRouteName()
    end
    if not isTable(idents) then
        error("DCAF.ROUTE:NewFromNavaids :: `idents` must be table (list of navaid identifiers)") end

    local departureAirbase, destinationAirbase
    local function makeRouteWaypoint(waypoint, index)
        local phase = phase or DCAF.AIR_ROUTE_PHASE.Enroute
        if isClass(waypoint, DCAF.NAVAID.ClassName) then
            waypoint = waypoint:AirTurnpoint()
        elseif isClass(waypoint, AIRBASE.ClassName) then
            local airbase = waypoint
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
            error("DCAF.ROUTE:New :: arg[" .. Dump(index) .. "] was not type " .. DCAF.NAVAID.ClassName .. " or " .. AIRBASE.ClassName)
        end
        waypoint[CONSTANTS.RouteProcedure] = phase
        waypoint[CONSTANTS.RouteProcedureName] = proc
        return waypoint
    end

    local route = DCAF.clone(DCAF.AIR_ROUTE)
    local firstIdent = 1
    local spawnMethod = DCAF.AIR_ROUTE_SPAWNMETHOD.Air
    local ignore = false
    local lastAlt
    for i = 1, #idents, 1 do
        local sIdent = idents[i]
        local waypoint
        if isAssignedString(sIdent) then
            local ident = AIRAC_IDENT:New(sIdent)
            if not ident then
                error("Route ident #" .. Dump(i) .. " is invalid: '" .. Dump(sIdent) .. "'") end

            local navaid = DCAF.AIRAC.NAVAIDS[ident.Name]
Debug("nisse - DCAF.AIR_ROUTE:NewFromNavaids :: ident.Name: " .. ident.Name .. " :: navaid: " .. DumpPrettyDeep(navaid))
            if not navaid then
                if i == firstIdent or i == #idents then
                    if DCAF.AIR_ROUTE_SPAWNMETHOD:IsAny(idents[i]) then
                        spawnMethod = idents[i]
                        firstIdent = firstIdent+1
                        ignore = true
                    else
                        local airbaseName = DCAF.AIRAC.ICAO[idents[i]].Name
                        if not ignore and airbaseName then
                            local airbase = AIRBASE:FindByName(airbaseName)
                            if airbase then
                                waypoint = airbase
                            end
                        end
                    end
                end
            elseif ident:IsRestricted() then
                -- NAVAID in route specifies SPEED / ALT restriction; clone it and add same restrictions...
                waypoint = DCAF.clone(navaid)
                waypoint.AltFt = ident.AltFt
                waypoint.SpeedKt = ident.SpeedKt
            else
                waypoint = navaid
            end
            if not ignore and not waypoint then
                error("DCAF.ROUTE:New :: idents[" .. Dump(i) .. "] was unknown NAVAID: '" .. sIdent .. "'")  end
        end
        if not ignore and not isClass(waypoint, DCAF.NAVAID.ClassName) and not isClass(waypoint, AIRBASE.ClassName) then
            error("DCAF.ROUTE:New :: idents[" .. Dump(i) .. "] ('" .. Dump(sIdent) .. "') was not type " .. DCAF.NAVAID.ClassName .. " or " .. AIRBASE.ClassName) end

        if not ignore then
            local wp = makeRouteWaypoint(waypoint, i)
            if not wp.alt then
                wp.alt = lastAlt
            end
            lastAlt = wp.alt
            table.insert(route.Waypoints, wp) 
        end

        ignore = false
    end
    route.Name = name
    route.DepartureAirbase = departureAirbase
    route.DestinationAirbase = destinationAirbase
    route.Takeoff = DCAF.AIR_ROUTE_SPAWNMETHOD:ResolveMOOSETakeoff(spawnMethod)
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
    clone.Waypoints = listReverse(self.Waypoints)
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

local function setCruiseParameters(waypoints, cruiseSpeedKnots, cruiseAltitudeFeet)

    local function set(wp, speedKnots, altitudeFeet)
        if wp[CONSTANTS.RouteProcedure] == DCAF.AIR_ROUTE_PHASE.Enroute or wp.alt == nil or wp.alt == 0 then
            wp.alt = Feet(altitudeFeet)
        end
        if wp[CONSTANTS.RouteProcedure] == DCAF.AIR_ROUTE_PHASE.Enroute or wp.speed == nil or wp.speed == 0 then
            wp.speed = Knots(speedKnots)
        end
    end

    local firstWP = waypoints[1]
    set(firstWP, cruiseSpeedKnots, cruiseAltitudeFeet)
    local prevCoord = COORDINATE_FromWaypoint(firstWP)
    for i = 2, #waypoints, 1 do
        local altitude = cruiseAltitudeFeet or 30000
        -- local speed = cruiseSpeedKnots obsolete
        local wp = waypoints[i]
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
                
    if isNumber(cruiseSpeedKt) then
        options.CruiseSpeedKnots = cruiseSpeedKt
    end
    if isNumber(cruiseAltitudeFt) then
        options.CruiseAltitudeFeet = cruiseAltitudeFt
    end
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
-- Debug("nisse - alignCoalitionWithDestination :: destinationCoalition: " .. Dump(destinationCoalition))
    local destinationCountry = DCAF.AIRAC.ICAO:GetCountry(route.DestinationAirbase)
    spawn:InitCountry(destinationCountry)
    spawn:InitCoalition(destinationCoalition)
    return destinationCoalition
end

function DCAF.AIR_ROUTE:Fly(controllable, options)
    if isAssignedString(controllable) then
        local spawn = getSpawn(controllable)
        if spawn then 
            controllable = spawn
        end
    end

    if not isClass(controllable, GROUP.ClassName) and not isClass(controllable, SPAWN.ClassName) then
        error("DCAF.AIR_ROUTE:Fly :: `controllable` must be string, or types: " .. GROUP.ClassName .. ", " .. SPAWN.ClassName .. " but was " .. type(controllable)) end
        
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
        cruiseSpeedKnots = Knots(self.CruiseSpeedKnots) or getGroupMaxSpeed(self.Group) * .8
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
            route.Group = controllable:SpawnAtAirbase(route.DepartureAirbase, route.Takeoff)
        else
            local firstWP = route.Waypoints[1]
            local nextWP
            local coordAirSpawn = COORDINATE_FromWaypoint(firstWP)
            if #route.Waypoints > 1 then
                nextWP = route.Waypoints[2]
                local coordNextWP = COORDINATE_FromWaypoint(nextWP)           
                local initialHeading = coordAirSpawn:GetHeadingTo(coordNextWP)
-- Debug("DCAF.AIR_ROUTE:Fly :: initialHeading: " .. Dump(initialHeading))
                coordAirSpawn:SetHeading(initialHeading)
            end
            coordAirSpawn:SetVelocity(Knots(cruiseSpeedKnots))
            coordAirSpawn:SetAltitude(Feet(cruiseAltitudeFeet))
            route.Group = controllable:SpawnFromCoordinate(coordAirSpawn)
        end
    end
    setCruiseParameters(route.Waypoints, cruiseSpeedKnots, cruiseAltitudeFeet)
    if options.STAR and self.DestinationAirbase then
        route:SetSTAR(options.STAR)
    end

    -- make AI-invisible if configured for it...
    local groupCoalition = route.Group:GetCoalition()
    local country = route.Group:GetCountry()
    if options.InvisibleToHostileAI and groupCoalition ~= coalition.side.NEUTRAL then
        Trace("DCAF.AIR_ROUTE:Fly :: makes group AI invisible: " .. route.Group.GroupName)
        route.Group:SetCommandInvisible(true)
    end
    route.Group:Route(route.Waypoints)
    return route
end

local AIR_ROUTE_CALLBACK_INFO = {
    ClassName = "AIR_ROUTE_CALLBACK_INFO",
    NextId = 1,
    Id = 0,              -- #int
    Func = nil,          -- #function
}

local AIR_ROUTE_CALLBACKS = { -- dictionary
    -- key   = #string
    -- value = #AIR_ROUTE_CALLBACK_INFO
}

local function onRouteArrival(route, func)
    local waypoints
    if isClass(route, DCAF.AIR_ROUTE.ClassName) then
        waypoints = route.Waypoints
    elseif isTable(route) then
        waypoints = route
    else
        error("onRouteArrival :: `route` must be table or " .. DCAF.AIR_ROUTE.ClassName) end

    -- local lastWP = self.Waypoints[2]
    local lastWP = self.Waypoints[#self.Waypoints]
    local callback
    callback = AIR_ROUTE_CALLBACK_INFO:New(function()
        func(self)
        callback:Remove()
    end)
    InsertWaypointAction(lastWP, ScriptAction("DCAF.AIR_ROUTE:Callback(" .. Dump(callback.Id) ..")"))
end

--- calls back a handler function when active route's group reaches last waypoint (might be useful to set parking, destroy group etc.)
function DCAF.AIR_ROUTE:OnArrival(func)
    if not isClass(self.Group, GROUP.ClassName) then
        Warning("DCAF.AIR_ROUTE:OnArrival :: not an active route (no Group flying it) :: IGNORES")
        return
    end
    onRouteArrival(self, func)
    -- local lastWP = self.Waypoints[#self.Waypoints]
    -- local callback
    -- callback = AIR_ROUTE_CALLBACK_INFO:New(function()
    --     func(self)
    --     callback:Remove()
    -- end)
    -- InsertWaypointAction(lastWP, ScriptAction("DCAF.AIR_ROUTE:Callback(" .. Dump(callback.Id) ..")"))
    return self
end

function AIR_ROUTE_CALLBACK_INFO:New(func)
    local info = DCAF.clone(AIR_ROUTE_CALLBACK_INFO)
    info.Func = func
    AIR_ROUTE_CALLBACK_INFO.NextId = AIR_ROUTE_CALLBACK_INFO.NextId + 1
    info.Id = AIR_ROUTE_CALLBACK_INFO.NextId
    AIR_ROUTE_CALLBACKS[tostring(info.Id)] = info
    return info
end

function AIR_ROUTE_CALLBACK_INFO:Remove()
    AIR_ROUTE_CALLBACKS[tostring(self.Id)] = nil
end

function DCAF.AIR_ROUTE:Callback(id)
    local info = AIR_ROUTE_CALLBACKS[tostring(id)]
    if not info then
        Warning("DCAF.AIR_ROUTE:Callback :: no callback found with id: " .. Dump(id) .. " :: IGNORES")
        return
    end
    info.Func()
end

--- Destroys active route (including GROUP flying it)
function DCAF.AIR_ROUTE:Destroy()
    if isClass(self.Group, GROUP.ClassName) then
        self.Group:Destroy()
    end
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

--- generates a 'generic' STAR procedure for specified airbase (just a waypoint 20nm out from, and aligned with, active RWY)
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

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                        ROUTE POPULATION (spawns traffic along a route)
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

DCAF.ROUTE_SPAWN = {
    ClassName = "DCAF.ROUTE_SPAWN",
    Index = 0,                  -- #number - internal index of route spawn
    Coordinate = nil,           -- #CORE.COORDINATE
    Heading = nil,              -- #number
    AltitudeFt = nil,           -- #number (feet)
    Route = nil,                -- #table (route / list of waypoints)
    Method = DCAF.AIR_ROUTE_SPAWNMETHOD.Air,
    Airbase = nil               -- #AIRBASE
}

function DCAF.ROUTE_SPAWN:New(index, coordinate, heading, route, method)
    local route_spawn = DCAF.clone(DCAF.ROUTE_SPAWN)
    route_spawn.Index = index
    route_spawn.Coordinate = coordinate
    route_spawn.Heading = heading
    route_spawn.Route = listCopy(route)
    route_spawn.Method = method or DCAF.AIR_ROUTE_SPAWNMETHOD.Air
    return route_spawn
end

local ROUTE_SPAWN_TEMPLATES_CACHE = { -- dictionary
    -- key   = #string - name of template
    -- value = #SPAWN
}

function ROUTE_SPAWN_TEMPLATES_CACHE:Get(name)
    local spawn = ROUTE_SPAWN_TEMPLATES_CACHE[name]
    if spawn then 
        return spawn end
        
    spawn = SPAWN:New(name)
    ROUTE_SPAWN_TEMPLATES_CACHE[name] = spawn
    return spawn
end

function DCAF.ROUTE_SPAWN:Spawn(spawn, options)
    if isAssignedString(spawn) then
        spawn = ROUTE_SPAWN_TEMPLATES_CACHE:Get(spawn)
    elseif not isClass(spawn, SPAWN.ClassName) then
        error("DCAF.ROUTE_SPAWN:SpawnFrom :: `spawn` must be type " .. SPAWN.ClassName)
    end
    if not isClass(options, DCAF.AIR_ROUTE_OPTIONS.ClassName) then
        options = DCAF.AIR_ROUTE_OPTIONS:New() 
    end

    spawn:InitGroupHeading(self.Heading)
    local group
    if self.Method == DCAF.AIR_ROUTE_SPAWNMETHOD.Air then
        group = spawn:SpawnFromCoordinate(self.Coordinate)
    else
        group = spawn:SpawnAtAirbase(self.Airbase, self.Method:ResolveMOOSETakeoff())
    end
    group:Route(self.Route)
    return self
end

function DCAF.ROUTE_SPAWN:OnArrival(func)
    onRouteArrival(self.Route, func)
    return self
end

function DCAF.AIR_ROUTE:Populate(separationNm, spawnFunc, options)
    if not isClass(options, DCAF.AIR_ROUTE_OPTIONS.ClassName) then
        options = DCAF.AIR_ROUTE_OPTIONS:New() 
    end

Debug("nisse - DCAF.AIR_ROUTE:Populate :: separationNm: " .. Dump(separationNm) .. " :: isNumber(separationNm): " .. Dump(isNumber(separationNm)))

    if separationNm == nil then
        separationNm = VariableValue:New(NauticalMiles(80), .4)
    elseif isNumber(separationNm) then
        separationNm = VariableValue:New(NauticalMiles(separationNm))
    elseif not isClass(separationNm, VariableValue.ClassName) then
        error("getDistributedRouteSpawns :: `separation` must be type " .. VariableValue.ClassName) 
    end

    if isNumber(maxCount) then
        maxCount = math.max(1, maxCount)
    end

    local route_spawns = {}
    if #self.Waypoints < 2 then
        return route_spawns end

    local waypoints = listCopy(self.Waypoints) -- clone the list of waypoints (we will affect it)
    setCruiseParameters(waypoints, options.CruiseSpeedKnots, options.CruiseAltitudeFeet)

-- Debug("nisse - DCAF.AIR_ROUTE:Populate :: waypoints: " .. DumpPrettyDeep(waypoints))
    
    local prevWP = waypoints[1]
    local coordPrevWP = COORDINATE_FromWaypoint(prevWP)
    local nextWP = waypoints[2]
    local coordNextWP = COORDINATE_FromWaypoint(nextWP)
    local heading = coordPrevWP:GetHeadingTo(coordNextWP)
    local altitude
    local count = 1

    local function next()
        if isNumber(maxCount) and count == maxCount then
            return end
        
        local sep = separationNm:GetValue()
        local distance = coordPrevWP:Get2DDistance(coordNextWP)
        local effectiveSeparation = sep
        local diff = sep - distance
        while distance < effectiveSeparation do
            -- remove 1st waypoint from route and recalculate initial WP...
            effectiveSeparation = effectiveSeparation - distance
            coordPrevWP = coordNextWP
            local length
            prevWP = waypoints[1]
            waypoints, length = listCopy(waypoints, {}, 2)
            if length == 0 then
                return end -- we're done; terminate 
            
            nextWP = waypoints[1]
            coordNextWP = COORDINATE:New(nextWP.x, nextWP.alt, nextWP.y)
            heading = coordPrevWP:GetAngleDegrees(coordPrevWP:GetDirectionVec3(coordNextWP))
            distance = coordPrevWP:Get2DDistance(coordNextWP)
        end

        if prevWP.alt == nextWP.alt then
            altitude = nextWP.alt
        else
            local maxAlt = math.max(prevWP.alt, nextWP.alt)
            local minAlt = math.min(prevWP.alt, nextWP.alt)
            local diff = maxAlt - minAlt
            local factor = effectiveSeparation / distance
            if prevWP.alt > nextWP.alt then
                -- descending
                factor = 1 - factor 
            end
            altitude = minAlt + (diff * factor)
        end
        count = count + 1
        return coordPrevWP:Translate(effectiveSeparation, heading)
    end
    
    local count = 1
    coordPrevWP = next()
    while coordPrevWP do
        coordPrevWP:SetAltitude(altitude)
        local rs = DCAF.ROUTE_SPAWN:New(count, coordPrevWP, heading, waypoints)
        if isFunction(options.OnArrivalFunc) then
            rs:OnArrival(options.OnArrivalFunc)
        end
        local spawn = spawnFunc(rs)
        if isAssignedString(spawn) then
            -- function provided a template name; get a SPAWN...
            spawn = getSpawn(spawn)
        end
        if isClass(spawn, SPAWN.ClassName) then
            -- function provided a SPAWN (rather than spawning a group)...
            alignCoalitionWithDestination(spawn, self)
            rs:Spawn(spawn)
        end
        coordPrevWP = next()
        count = count+1
    end    

    return self
end

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

    AIRAC_Aerodrome:New(AIRBASE.PersianGulf.Sharjah_Intl, 'OMSJ')
            :WithATIS( 375.60 ) -- ??
            :WithGND({ 250.05, 118.05 })
            :WithTWR({ 250.30, 118.70 })
            :WithDEP({ 250.60, 118.60 })
            :WithILS({ 
                ["12L"] = 108.55, ["30R"] = 111.95 })
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