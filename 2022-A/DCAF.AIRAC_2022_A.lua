--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                      AIRAC 2022-A
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

DCAF.AIRAC.Version = "2022-A"
DCAF.AIRAC.Aerodromes = {}

-- nisse
DCAF.Debug = true
Debug("nisse - AIRAC (aaaaa)")

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

DCAF.AIR_ROUTE = {
    ClassName = "DCAF.AIR_ROUTE",
    Name = nil,                         -- #string - name of route
    Waypoints = {},
    DepartureAirbase = nil,             -- #AIRBASE
    DestinationAirbase = nil            -- #AIRBASE
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

DCAF.AIR_ROUTE_PHASE = {
    Takeoff = "Takeoff",
    Land = "Land",
    Enroute = "Enroute",
    SID = "SID",
    STAR = "STAR"
}

DCAF.AIR_ROUTE_SPAWNMETHOD = {
    Air = "air",
    Hot = "hot",
    Cold = "cold",
    Runway = "runway"
}

local AIRBASE_INFO = {
    ClassName = "AIRBASE_INFO",
    Name = nil,                 -- #string - name of airdrome
    ICAO = nil,                 -- #string - OIDC code 
    Country = nil,              -- DCS#country.id - country where airdrome reside
    Departures = {},            -- list of #DCAF.AIR_ROUTE
    Arrivals = {},              -- list of #DCAF.AIR_ROUTE
}

function AIRBASE_INFO:New(icao, country, name)
    if not isAssignedString(icao) then
        error("AIRBASE_INFO:New :: `icao` must be an assigned string, but was:" .. DumpPretty(icao)) end

    if DCAF.AIRAC.ICAO[icao] then
        error("AIRBASE_INFO:New :: airdrome with ICAO code '" .. icao .. "' already exists") end

    local info = DCAF.clone(AIRBASE_INFO)
    info.ICAO = icao
    info.Name = name
    info.Country = country
    DCAF.AIRAC.ICAO[icao] = info
    return info
end

function AIRBASE_INFO:AddDepartures(...)
    if not isList(self.Departures) then
        self.Departures = {}
    end
    for i = 1, #arg, 1 do
        local dep = arg[i]
        if not isClass(dep, DCAF.AIR_ROUTE.ClassName) or dep.Phase ~= DCAF.AIR_ROUTE_PHASE.Takeoff or dep.Proc ~= DCAF.AIR_ROUTE_PHASE.SID then
            error("AIRBASE_INFO:AddDepartures :: invalid departue route: " .. DumpPretty(dep)) end

        table.insert(self.Departures, dep)
    end
    return self
end

function AIRBASE_INFO:AddArrivals(...)
    if not isList(self.Arrivals) then
        self.Arrivals = {}
    end
    for i = 1, #arg, 1 do
        local arr = arg[i]
        if not isClass(arr, DCAF.AIR_ROUTE.ClassName) or arr.Phase ~= DCAF.AIR_ROUTE_PHASE.Land or arr.Proc ~= DCAF.AIR_ROUTE_PHASE.STAR then
            error("AIRBASE_INFO:AddDepartures :: invalid arrival route: " .. DumpPretty(arr)) end

        table.insert(self.Arrivals, arr)
    end
    return self
end

DCAF.AIRAC.ICAO = {}

function DCAF.AIRAC:GetAirbaseICAO(airbase)
    if isClass(airbase, AIRBASE.ClassName) then
        airbase = airbase.AirbaseName
    elseif not isAssignedString(airbase) then
        error("DCAF.AIRAC:GetAirbaseICAO :: `airbase` must be assigned string (airbase name) or of type " .. AIRBASE.ClassName)
    end
    for icao, info in pairs(DCAF.AIRAC.ICAO) do
        if isClass(info, AIRBASE_INFO.ClassName) and info.Name == airbase then
            return info.ICAO end
    end
end

local function getAirbaseInfo(airbase, caller)
    if isAssignedString(airbase) then
        local testAirbase = AIRBASE:FindByName(airbase)
        if not testAirbase then
            if string.len(airbase) == 4 then
                -- assume ICAO code
                local info = DCAF.AIRAC.ICAO[airbase]
                if info then 
                    return info
                end
            end
            error(caller .. " :: cannot resolve airbase from '" .. airbase .. "'") end

        airbase = testAirbase
    end
    if not isClass(airbase, AIRBASE.ClassName) then
        error(caller .. " :: `airbase` must be assigned string (airbase name) or #AIRBASE, but was: " .. DumpPretty(airbase)) end

    for icao, info in pairs(DCAF.AIRAC.ICAO) do
-- Debug("nisse - getAirbaseInfo :: icao: " .. Dump(icao) .. " :: info: " .. Dump(info))
        if info.Name == airbase.AirbaseName then
            return info, airbase
        end
    end
end

function DCAF.AIRAC:GetDepartureRoutes(airbase, runway)
    local info, airbase = getAirbaseInfo(airbase, "DCAF.AIRAC:GetDepartureRoutes")
    if not info then
        return end

    if not isAssignedString(runway) then
        runway = airbase:GetActiveRunwayTakeoff()
        runway = runway.name
    end
    local departures = {}
    for _, dep in ipairs(info.Departures) do
        for _, rwy in ipairs(dep.Runways) do
            if string.find(rwy, runway) then
                table.insert(departures, dep)
                break
            end
        end
    end 
    return departures
end

function DCAF.AIRAC:GetArrivalRoutes(airbase, runway)
    local info, airbase = getAirbaseInfo(airbase, "DCAF.AIRAC:GetArrivalRoutes")
    if not info then
        return end

    if not isAssignedString(runway) then
        runway = airbase:GetActiveRunwayLanding()
        runway = runway.name
    end
    local arrivals = {}
Debug("nisse - DCAF.AIRAC:GetArrivalRoutes :: airbase: " .. airbase.AirbaseName .. " :: runway: " .. Dump(runway) .. " :: info.Arrivals: " .. DumpPretty(info.Arrivals))
    for _, arr in ipairs(info.Arrivals) do
        for _, rwy in ipairs(arr.Runways) do
            if string.find(rwy, runway) then
                table.insert(arrivals, arr)
                break
            end
        end
    end 
    return arrivals
end

function DCAF.AIRAC:GetCountry(airbase)
    if isClass(airbase, AIRBASE.ClassName) then
        airbase = DCAF.AIRAC:GetAirbaseICAO(airbase)
    end
    if not isAssignedString(airbase) then 
        error("DCAF.AIRAC:GetCountry :: unexpected `airbase` value: " .. DumpPretty(airbase)) end

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

DCAF.AIRAC.NAVAIDS = {}

Debug("nisse - AIRAC (aaaaa)")

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
    Type = DCAF.NAVAID_TYPE.Fix,
    Hidden = nil                -- #bool - true = will not be rendered
}

DCAF.AIRAC.NAVAIDS = {}

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

function DCAF.NAVAID:New(map, name, coordinate, type, hidden)
Debug("nisse - DCAF.NAVAID:New ... START :: name: " .. name)

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
    
    if DCAF.AIRAC.NAVAIDS[name] then
        error("DCAF.NAVAID:NewFix :: navaid was already added: '" .. name .. "'") end

    local navaid = DCAF.clone(DCAF.NAVAID)
    navaid.Map = map
    navaid.Name = name
    navaid.Coordinate = coordinate
    navaid.Type = type
    navaid.Hidden = hidden
    DCAF.AIRAC.NAVAIDS[name] = navaid
Debug("nisse - DCAF.NAVAID:New ... END")
    return navaid
end

local _DCAF_defaultMap

function DCAF.NAVAID:NewFix(name, coordinate, map)
    return DCAF.NAVAID:New(map or _DCAF_defaultMap, name, coordinate, DCAF.NAVAID_TYPE.Fix)
end

function DCAF.NAVAID:NewRadial(name, coordinate, map)
    return DCAF.NAVAID:New(map or _DCAF_defaultMap, name, coordinate, DCAF.NAVAID_TYPE.Fix, true)
end

function DCAF.NAVAID:NewVOR(name, frequency, coordinate, map)
    if not isNumber(frequency) then
        error("DCAF.NAVAID:NewVOR :: `frequency` must be a number but was: " .. DumpPretty(frequency)) end

    local vor = DCAF.NAVAID:New(map or _DCAF_defaultMap, name, coordinate, DCAF.NAVAID_TYPE.VOR)
    vor.Frequency = frequency
    return vor
end

function DCAF.NAVAID:NewDME(name, frequency, coordinate, map)
    if not isNumber(frequency) then
        error("DCAF.NAVAID:NewDME :: `frequency` must be a number but was: " .. DumpPretty(frequency)) end

    local dme = DCAF.NAVAID:New(map or _DCAF_defaultMap, name, coordinate, DCAF.NAVAID_TYPE.DME)
    dme.Frequency = frequency
    return dme
end

function DCAF.NAVAID:NewTACAN(name, channel, mode, coordinate, map)
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
    
    local tacan = DCAF.NAVAID:New(map or _DCAF_defaultMap, name, coordinate, DCAF.NAVAID_TYPE.TACAN)
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
    local isCoalition, dcafCoalition = Coalition.IsValid(coalition)
    if isCoalition then
        coalition = Coalition.ToNumber(dcafCoalition)
    end
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
        local outerSize = .5
        local innerSize = .15
        local coordN = self.Coordinate:Translate(size * outerSize, 0)
        local alpha = .8
        local lineType = 0      -- no line
        local readOnly = true   -- is read only (cannot be removed by user)
        local form = {
            self.Coordinate:Translate(size * innerSize, 45),
            self.Coordinate:Translate(size * outerSize, 90),
            self.Coordinate:Translate(size * innerSize, 135),
            self.Coordinate:Translate(size * outerSize, 180),
            self.Coordinate:Translate(size * innerSize, 225),
            self.Coordinate:Translate(size * outerSize, 270),
            self.Coordinate:Translate(size * innerSize, 315),
            coordN
        }
        coordN:MarkupToAllFreeForm(form, coalition, color, alpha, color, alpha, lineType, readOnly)
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

-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                                        AIR ROUTES 
-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


Debug("nisse - AIRAC (bbbbb)")


local DCAF_ROUTE_COUNT = 1

function DCAF.AIR_ROUTE_OPTIONS:OnArrival(func)
    if not isFunction(func) then
        error("DCAF.AIR_ROUTE_OPTIONS:OnArrival :: `func` must be functon, but was " .. type(func)) end

    self.OnArrivalFunc = func
end

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

function DCAF.AIR_ROUTE:NewDeparture(name, runways, route)
    if isAssignedString(runways) then
        runways = { runways }
    end
    if not isList(runways) then
        error("DCAF.AIR_ROUTE:NewDeparture :: `runways` must be an assigned string (RWY name) or a list of strings, but was: " .. DumpPretty(runways)) end

    local r = DCAF.AIR_ROUTE:New(name, route, DCAF.AIR_ROUTE_PHASE.Takeoff, DCAF.AIR_ROUTE_PHASE.SID)
    r.Runways = runways
    return r
end

function DCAF.AIR_ROUTE:NewArrival(name, runways, route)
    if isAssignedString(runways) then
        runways = { runways }
    end
    if not isList(runways) then
        error("DCAF.AIR_ROUTE:NewDeparture :: `runways` must be an assigned string (RWY name) or a list of strings, but was: " .. DumpPretty(runways)) end

    local r = DCAF.AIR_ROUTE:New(name, route, DCAF.AIR_ROUTE_PHASE.Land, DCAF.AIR_ROUTE_PHASE.STAR)
    r.Runways = runways
    return r
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

--- overrides to support passing DCAF.AIR_ROUTE as `route`
function DCAF.Tanker:Route(route)
    if isClass(route, DCAF.AIR_ROUTE.ClassName) then
        route = route.Waypoints
    elseif not isTable(route) then
        error("DCAF.Tanker:Route :: `route` must be a table but was " .. type(route)) end
        
    self.Route = route
    self.Group:Route(route)
    return self
end

--- overrides to support passing DCAF.AIR_ROUTE as `route`
function DCAF.AWACS:Route(route)
    if isClass(route, DCAF.AIR_ROUTE.ClassName) then
        route = route.Waypoints
    elseif not isTable(route) then
        error("DCAF.AWACS:Route :: `route` must be a table but was " .. type(route)) end
        
    self.Route = route
    self.Group:Route(route)
    return self
end

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
-- Debug("nisse - AIRAC_IDENT:New :: s: " .. Dump(s) .. " :: items: " .. DumpPretty(items))
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
    if not isAssignedString(name) then
        name = genericRouteName()
    end
    if not isTable(idents) then
        error("DCAF.AIR_ROUTE:NewFromNavaids :: `idents` must be table (list of navaid identifiers)") end

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
                waypoint = coord:WaypointAirLanding(250, airbase, nil, DCAF.AIRAC:GetAirbaseICAO(airbase))
                waypoint.speed = 70
                phase = DCAF.AIR_ROUTE_PHASE.Land
                destinationAirbase = airbase
            end
        else
            error("DCAF.AIR_ROUTE:New :: arg[" .. Dump(index) .. "] was not type " .. DCAF.NAVAID.ClassName .. " or " .. AIRBASE.ClassName)
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
-- Debug("nisse - DCAF.AIR_ROUTE:NewFromNavaids :: ident: " .. DumpPrettyDeep(ident))            
            if not ident then
                error("Route ident #" .. Dump(i) .. " is invalid: '" .. Dump(sIdent) .. "'") end

            local navaid = DCAF.AIRAC.NAVAIDS[ident.Name]
-- Debug("nisse - DCAF.AIR_ROUTE:NewFromNavaids :: ident.Name: " .. ident.Name .. " :: navaid: " .. DumpPrettyDeep(navaid))
            if not navaid then
                if i == firstIdent or i == #idents then
                    if DCAF.AIR_ROUTE_SPAWNMETHOD:IsAny(idents[i]) then
                        spawnMethod = idents[i]
                        firstIdent = firstIdent+1
                        ignore = true
                    else
                        local airbaseInfo = DCAF.AIRAC.ICAO[ident.Name]
                        if not airbaseInfo then
                            error("DCAF.AIR_ROUTE:New :: idents[" .. Dump(i) .. "] was unknown NAVAID: '" .. sIdent .. "'")  end

                        local airbaseName = airbaseInfo.Name
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
                error("DCAF.AIR_ROUTE:New :: idents[" .. Dump(i) .. "] was unknown NAVAID: '" .. sIdent .. "'")  end
        end
        if not ignore and not isClass(waypoint, DCAF.NAVAID.ClassName) and not isClass(waypoint, AIRBASE.ClassName) then
            error("DCAF.AIR_ROUTE:New :: idents[" .. Dump(i) .. "] ('" .. Dump(sIdent) .. "') was not type " .. DCAF.NAVAID.ClassName .. " or " .. AIRBASE.ClassName) end

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
    route.Phase = phase
    route.Proc = proc
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
    local idents = {}
-- Debug("nisse - DCAF.AIR_ROUTE:CloneReversed :: self.RouteText: " .. Dump(self.RouteText))
    for ident in self.RouteText:gmatch("%S+") do 
        table.insert(idents, ident) 
    end
    local revRouteText = idents[#idents]
    for i = #idents-1, 1, -1 do
        revRouteText = revRouteText .. " " .. idents[i]
    end
-- Debug("nisse - DCAF.AIR_ROUTE:CloneReversed :: revRouteText: " .. Dump(revRouteText))    
    return DCAF.AIR_ROUTE:New(name, revRouteText)
    -- local clone = DCAF.clone(self) obsolete
    -- local navaids = {}
    -- local idx = 0
    -- for i = #self.Waypoints, 1, -1 do
    --     idx = idx+1
    --     navaids[idx] = self.Waypoints[i].name
    -- end
    -- return DCAF.AIR_ROUTE:NewFromNavaids(name, navaids)
end

function DCAF.AIR_ROUTE:WithCruiseAltitude(altitudeFeet)
    self.CruiseAltitudeFeet = altitudeFeet
    if not isNumber(altitudeFeet) then
        error("DCAF.AIR_ROUTE:WithAltutide :: `altitudeMeters` must be a number but was: " .. DumpPretty(altitudeFeet)) end
    if #self.Waypoints == 0 then
        error("DCAF.AIR_ROUTE:WithAltutide :: route '" .. self.Name .. "' contains no waypoints") end

    for _, wp in ipairs(self.Waypoints) do
        wp.alt = altitudeFeet
    end
    return self 
end

function DCAF.AIR_ROUTE:WithCruiseSpeed(speedKnots)
    self.CruiseSpeedKnots = speedKnots
    if not isNumber(speedKnots) then
        error("DCAF.AIR_ROUTE:WithSpeed :: `speedKmph` must be a number but was: " .. DumpPretty(speedKnots)) end
    if #self.Waypoints == 0 then
        error("DCAF.AIR_ROUTE:WithSpeed :: route '" .. self.Name .. "' contains no waypoints") end

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
    local destinationCountry = DCAF.AIRAC:GetCountry(route.DestinationAirbase)
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

local function onRouteArrival(waypoints, func)
    local lastWP = waypoints[#waypoints]
    local callback
    callback = AIR_ROUTE_CALLBACK_INFO:New(function()
        func(lastWP)
        callback:Remove()
    end)
    InsertWaypointAction(lastWP, ScriptAction("DCAF.AIR_ROUTE:Callback(" .. Dump(callback.Id) .. ")"))
end

--- calls back a handler function when active route's group reaches last waypoint (might be useful to set parking, destroy group etc.)
function DCAF.AIR_ROUTE:OnArrival(func)
    if not isClass(self.Group, GROUP.ClassName) then
        Warning("DCAF.AIR_ROUTE:OnArrival :: not an active route (no Group flying it) :: IGNORES")
        return
    end
    onRouteArrival(self.Waypoints, function(waypoint) 
        func(self.Group, waypoint)
    end)
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
    local icao = DCAF.AIRAC:GetAirbaseICAO(airbase)
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

Debug("nisse - AIRAC (ccccc)")


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

function DCAF.ROUTE_SPAWN:New(index, coordinate, heading, waypoints, route, method)
    local route_spawn = DCAF.clone(DCAF.ROUTE_SPAWN)
    route_spawn.Index = index
    route_spawn.Coordinate = coordinate
    route_spawn.Heading = heading
    route_spawn.Waypoints = listCopy(waypoints)
    route_spawn.Method = method or DCAF.AIR_ROUTE_SPAWNMETHOD.Air
    route_spawn.Route = route
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
        local takeoff = DCAF.AIR_ROUTE_SPAWNMETHOD:ResolveMOOSETakeoff(self.Method)
        group = spawn:SpawnAtAirbase(self.Airbase, takeoff)
    end
    self.Group = group
    group:Route(self.Waypoints)
    return self
end

function DCAF.ROUTE_SPAWN:OnArrival(func)
    onRouteArrival(self.Waypoints, function(waypoint) 
        func(self.Group, waypoint)
    end)
    return self
end

function DCAF.AIR_ROUTE:Populate(separationNm, spawnFunc, options)
    if not isClass(options, DCAF.AIR_ROUTE_OPTIONS.ClassName) then
        options = DCAF.AIR_ROUTE_OPTIONS:New() 
    end

-- Debug("nisse - DCAF.AIR_ROUTE:Populate :: separationNm: " .. Dump(separationNm) .. " :: isNumber(separationNm): " .. Dump(isNumber(separationNm)))

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
        local rs = DCAF.ROUTE_SPAWN:New(count, coordPrevWP, heading, waypoints, self)
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
            rs:Spawn(spawn, options)
        end
        coordPrevWP = next()
        count = count+1
    end    

    return self
end

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                   PROCEDURES (SID/STAR)
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Debug("nisse - AIRAC (ddddd)")


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

Debug("nisse - AIRAC (eeeee)")


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

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                              NAVAIDS and FIXES
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////

Debug("nisse - AIRAC (fffff)")


-- convert Decimal Coords: https://www.latlong.net/degrees-minutes-seconds-to-decimal-degrees
--                     or: https://www.fcc.gov/media/radio/dms-decimal
-- https://flightcrewguide.com/wiki/rules-regulations/flight-plan/

    -- Persian Gulf (PEG) - Waypoints
    _DCAF_defaultMap = DCSMAP.PersianGulf
    DCAF.NAVAID:NewFix("ALSAS", COORDINATE:NewFromLLDD(24.01500000, 59.33194444))
    DCAF.NAVAID:NewFix("BOSEV", COORDINATE:NewFromLLDD(24.87027778, 54.20222222))
    DCAF.NAVAID:NewFix("DAVUS", COORDINATE:NewFromLLDD(28.39611111, 49.10611111))
    DCAF.NAVAID:NewFix("DESPI", COORDINATE:NewFromLLDD(23.83083333, 56.51944444))
    DCAF.NAVAID:NewFix("EGMOR", COORDINATE:NewFromLLDD(26.70222222, 50.48500000))
    DCAF.NAVAID:NewFix("ELOVU", COORDINATE:NewFromLLDD(24.95583333, 54.33805556))
    DCAF.NAVAID:NewFix("ENASO", COORDINATE:NewFromLLDD(27.95166667, 49.31972222))
    DCAF.NAVAID:NewFix("GADSI", COORDINATE:NewFromLLDD(30.56611111, 47.18777778))
    DCAF.NAVAID:NewFix("GEVED", COORDINATE:NewFromLLDD(23.01805556, 57.85305556))
    DCAF.NAVAID:NewFix("IMDOX", COORDINATE:NewFromLLDD(29.58194444, 49.24388889))
    DCAF.NAVAID:NewFix("IMLIP", COORDINATE:NewFromLLDD(24.61333333, 54.59694444))
    DCAF.NAVAID:NewFix("IMPED", COORDINATE:NewFromLLDD(25.05138889, 56.08388889))
    DCAF.NAVAID:NewFix("ITRAX", COORDINATE:NewFromLLDD(24.21333333, 55.79694444))
    DCAF.NAVAID:NewFix("KAPUM", COORDINATE:NewFromLLDD(24.97083333, 53.58055556))
    DCAF.NAVAID:NewFix("KOBOK", COORDINATE:NewFromLLDD(26.97750000, 50.56361111))
    DCAF.NAVAID:NewFix("LAKLU", COORDINATE:NewFromLLDD(23.37638889, 57.06694444))
    DCAF.NAVAID:NewFix("LUBAT", COORDINATE:NewFromLLDD(25.03972222, 56.29694444))
    DCAF.NAVAID:NewFix("MEDMA", COORDINATE:NewFromLLDD(26.57250000, 50.91500000))
    DCAF.NAVAID:NewFix("MOGIM", COORDINATE:NewFromLLDD(24.68138889, 54.47222222))
    DCAF.NAVAID:NewFix("ORSAR", COORDINATE:NewFromLLDD(26.07500000, 53.95833333))
    DCAF.NAVAID:NewFix("PUTSO", COORDINATE:NewFromLLDD(23.34361100, 56.88944400))
    DCAF.NAVAID:NewFix("PATOM", COORDINATE:NewFromLLDD(25.97250000, 51.40111111))
    DCAF.NAVAID:NewFix("PARAR", COORDINATE:NewFromLLDD(22.82555556, 63.75138889))
    DCAF.NAVAID:NewFix("RABLA", COORDINATE:NewFromLLDD(26.26583333, 51.89361111))
    DCAF.NAVAID:NewFix("RAMSI", COORDINATE:NewFromLLDD(27.04694444, 50.12055556))
    DCAF.NAVAID:NewFix("RASDI", COORDINATE:NewFromLLDD(26.07361111, 51.42055556))
    DCAF.NAVAID:NewFix("RETEL", COORDINATE:NewFromLLDD(29.03555556, 48.64222222))
    DCAF.NAVAID:NewFix("ROTEL", COORDINATE:NewFromLLDD(26.83888889, 50.69611111))
    DCAF.NAVAID:NewFix("SETSI", COORDINATE:NewFromLLDD(23.07000000, 61.73611111))
    DCAF.NAVAID:NewFix("SIDAD", COORDINATE:NewFromLLDD(29.87527778, 48.49555556))
    DCAF.NAVAID:NewFix("SOLOB", COORDINATE:NewFromLLDD(26.57250000, 50.91500000))
    DCAF.NAVAID:NewFix("TASMI", COORDINATE:NewFromLLDD(30.02222222, 47.91805556))
    DCAF.NAVAID:NewFix("TOKMA", COORDINATE:NewFromLLDD(27.16083333, 50.19972222))
    DCAF.NAVAID:NewFix("TONVO", COORDINATE:NewFromLLDD(25.08333333, 56.53333333))
    DCAF.NAVAID:NewFix("TOSNA", COORDINATE:NewFromLLDD(26.27000000, 52.68777778))
    DCAF.NAVAID:NewFix("TOTKU", COORDINATE:NewFromLLDD(25.59277778, 54.06944444))
    DCAF.NAVAID:NewFix("TUMAK", COORDINATE:NewFromLLDD(26.00083333, 52.78694444))
    DCAF.NAVAID:NewFix("ULDUR", COORDINATE:NewFromLLDD(30.83972222, 47.49944444))
    DCAF.NAVAID:NewFix("UMEVU", COORDINATE:NewFromLLDD(25.09583333, 53.11472222))
    DCAF.NAVAID:NewFix("VELOG", COORDINATE:NewFromLLDD(25.61250000, 54.86361111))
    DCAF.NAVAID:NewFix("VUTEB", COORDINATE:NewFromLLDD(25.61250000, 54.86361111))
    -- Persian Gulf (PEG) - VOR/DME
    DCAF.NAVAID:NewVOR("ADV", 114.25, COORDINATE:NewFromLLDD(24.44166667, 54.65611111))  -- UAE, Abu Dhabi Intl. airport
    DCAF.NAVAID:NewVOR("AJR", 114.90, COORDINATE:NewFromLLDD(30.74694444, 49.66638889))  -- Iran, Aghajari Airport (north, bordering Iraq)
    DCAF.NAVAID:NewVOR("ALN", 116.60, COORDINATE:NewFromLLDD(24.25888889, 55.60611111))   
    DCAF.NAVAID:NewVOR("AWZ", 114.00, COORDINATE:NewFromLLDD(31.33361111, 48.75333333))  -- Iran, Ahwaz airport
    DCAF.NAVAID:NewVOR("BHR", 118.80, COORDINATE:NewFromLLDD(26.25833333, 50.70333333))  -- Bahrain, Bahrain Intl.
    -- DCAF.NAVAID:NewVOR("BND", 117.20, COORDINATE:NewFromLLDD(27.19694444, 56.36694444))  -- Iran, Bandar Abbas Intl.
    DCAF.NAVAID:NewVOR("BUZ", 117.45, COORDINATE:NewFromLLDD(28.95416667, 50.82250000))  -- Iran west coast, up north
    DCAF.NAVAID:NewVOR("CBH", 115.60, COORDINATE:NewFromLLDD(25.44222222, 60.41833333))  -- Iran, coast, far east
    DCAF.NAVAID:NewVOR("DOH", 114.40, COORDINATE:NewFromLLDD(25.24666667, 51.60888889))  -- Quatar, Dohar Intl. airport
    DCAF.NAVAID:NewVOR("FJV", 113.80, COORDINATE:NewFromLLDD(25.10055556, 56.35444444))  -- UAE, Fujairah intl airport.
    DCAF.NAVAID:NewVOR("ISR", 117.00, COORDINATE:NewFromLLDD(27.25083333, 60.74305556))  -- Iran, 230 nm east Bandar Abbas
    DCAF.NAVAID:NewVOR("JIR", 276.00, COORDINATE:NewFromLLDD(28.73194444, 57.67194444))  -- Iran, Jiroft airport
    DCAF.NAVAID:NewVOR("KHM", 117.10, COORDINATE:NewFromLLDD(26.76277778, 55.90777778))  -- Iran, Queshm island
    DCAF.NAVAID:NewVOR("KIS", 117.40, COORDINATE:NewFromLLDD(26.52500000, 53.96250000))  -- Iran, Kish isl.
    DCAF.NAVAID:NewVOR("LAM", 117.00, COORDINATE:NewFromLLDD(27.37305556, 53.18972222))  -- Iran, 34nm north Lavan isl.
    DCAF.NAVAID:NewVOR("LAR", 117.90, COORDINATE:NewFromLLDD(27.67472222, 54.41611111))  -- Iran, Lar airport
    DCAF.NAVAID:NewVOR("LEN", 114.80, COORDINATE:NewFromLLDD(26.53611111, 54.85111111))  -- Iran, Bandar Lengeh airport
    DCAF.NAVAID:NewVOR("LVA", 116.85, COORDINATE:NewFromLLDD(26.81194444, 53.35583333))  -- Iran, Lavan island
    DCAF.NAVAID:NewVOR("SRJ", 114.60, COORDINATE:NewFromLLDD(29.55611111, 55.66277778))  -- Iran, 78nm SW Kerman
    DCAF.NAVAID:NewVOR("SYZ", 117.80, COORDINATE:NewFromLLDD(29.54000000, 52.58861111))  -- Iran, Shiraz Intl
    DCAF.NAVAID:NewVOR("ZDN", 116.00, COORDINATE:NewFromLLDD(29.47861111, 60.89694444))  -- Iran, 210nm ESE of Kerman 
    -- Persian Gulf (PEG) - TACAN/VORTAC
    DCAF.NAVAID:NewTACAN( "BND",          78, 'X', COORDINATE:NewFromLLDD(27.21694444, 56.38083333))    -- Iran, Bandar Abbas Intl.
    DCAF.NAVAID:NewTACAN( "HDR",          47, 'X', COORDINATE:NewFromLLDD(27.16055556, 56.17277778))    -- Iran, Havadarya airport
    DCAF.NAVAID:NewTACAN( "MIN",          99, 'X', COORDINATE:NewFromLLDD(25.02694444, 55.39555556))    -- UAE, Al Minhad AFB
    DCAF.NAVAID:NewVORTAC("MA",   114.9,  96, nil, COORDINATE:NewFromLLDD(24.24666667, 54.54527778))    -- UAE, Al Dhafra AFB
    DCAF.NAVAID:NewVORTAC("OMLW", 117.4, 121, nil, COORDINATE:NewFromLLDD(23.66750000, 53.80361111))    -- UAE, Liwa AFB
    DCAF.NAVAID:NewTACAN( "SYZ1",         94, 'X', COORDINATE:NewFromLLDD(29.54166667, 52.58861111))    -- Iran, Shiraz Intl

    -- Syria (SYR) - Waypoints
    _DCAF_defaultMap = DCSMAP.Syria
    -- xxxxx = DCAF.NAVAID:NewFix(DCSMAP.Syria, "xxxxx", COORDINATE:NewFromLLDD(999, 999))
    DCAF.NAVAID:NewFix("ABBAS", COORDINATE:NewFromLLDD(33.43333333, 37.72500000))
    DCAF.NAVAID:NewFix("ADLOD", COORDINATE:NewFromLLDD(32.56694444, 35.25250000))
    DCAF.NAVAID:NewFix("ALKIS", COORDINATE:NewFromLLDD(35.20027778, 30.00027778))
    DCAF.NAVAID:NewFix("ALSUS", COORDINATE:NewFromLLDD(35.03500000, 34.65666667))
    DCAF.NAVAID:NewFix("ANANE", COORDINATE:NewFromLLDD(34.29861111, 32.72805556))
    DCAF.NAVAID:NewFix("APLON", COORDINATE:NewFromLLDD(33.86694444, 32.06694444))
    DCAF.NAVAID:NewFix("BALMA", COORDINATE:NewFromLLDD(34.48222222, 35.05055556))
    DCAF.NAVAID:NewFix("BASEM", COORDINATE:NewFromLLDD(33.56027778, 37.65194444))
    DCAF.NAVAID:NewFix("DASNI", COORDINATE:NewFromLLDD(35.61694444, 30.85027778))
    DCAF.NAVAID:NewFix("DESPO", COORDINATE:NewFromLLDD(34.44833333, 34.38166667))
    DCAF.NAVAID:NewFix("DOREN", COORDINATE:NewFromLLDD(35.93222222, 33.28277778))
    DCAF.NAVAID:NewFix("ELIKA", COORDINATE:NewFromLLDD(33.83194444, 34.58333333))
    DCAF.NAVAID:NewFix("EMEDA", COORDINATE:NewFromLLDD(34.48166667, 33.80333333))
    DCAF.NAVAID:NewFix("EMILI", COORDINATE:NewFromLLDD(34.63888889, 34.04444444))
    DCAF.NAVAID:NewFix("ESERI", COORDINATE:NewFromLLDD(34.48194444, 32.38527778))
    DCAF.NAVAID:NewFix("EVKIT", COORDINATE:NewFromLLDD(36.25111111, 33.75444444))
    DCAF.NAVAID:NewFix("EXELA", COORDINATE:NewFromLLDD(35.95555556, 29.59777778))
    DCAF.NAVAID:NewFix("FIRAS", COORDINATE:NewFromLLDD(33.87194444, 37.92000000))
    DCAF.NAVAID:NewFix("GALIM", COORDINATE:NewFromLLDD(32.81444444, 34.81000000))
    DCAF.NAVAID:NewFix("GENOS", COORDINATE:NewFromLLDD(34.67888889, 31.90111111))
    DCAF.NAVAID:NewFix("GODED", COORDINATE:NewFromLLDD(32.90027778, 34.57277778))
    DCAF.NAVAID:NewFix("IDAKU", COORDINATE:NewFromLLDD(34.08527778, 32.69944444))
    DCAF.NAVAID:NewFix("KASIR", COORDINATE:NewFromLLDD(32.66500000, 40.52000000))
    DCAF.NAVAID:NewFix("KEREN", COORDINATE:NewFromLLDD(32.37555556, 34.07916667))
    DCAF.NAVAID:NewFix("KUKLA", COORDINATE:NewFromLLDD(34.24388889, 34.74611111))
    DCAF.NAVAID:NewFix("KUMLO", COORDINATE:NewFromLLDD(32.97000000, 38.46888889))
    DCAF.NAVAID:NewFix("LATEB", COORDINATE:NewFromLLDD(34.03166667, 36.41000000))
    DCAF.NAVAID:NewFix("LEBOR", COORDINATE:NewFromLLDD(34.26555556, 36.91638889))
    DCAF.NAVAID:NewFix("LEDRA", COORDINATE:NewFromLLDD(33.20027778, 33.05000000))
    DCAF.NAVAID:NewFix("LOTAX", COORDINATE:NewFromLLDD(33.97638889, 36.55805556))
    DCAF.NAVAID:NewFix("MAROS", COORDINATE:NewFromLLDD(34.61694444, 30.88333333))
    DCAF.NAVAID:NewFix("MESIL", COORDINATE:NewFromLLDD(32.11055556, 34.90138889))
    DCAF.NAVAID:NewFix("MERVA", COORDINATE:NewFromLLDD(32.78166667, 34.54388889))
    DCAF.NAVAID:NewFix("MODIK", COORDINATE:NewFromLLDD(33.46833333, 39.01694444))
    DCAF.NAVAID:NewFix("MURAK", COORDINATE:NewFromLLDD(34.93333333, 36.70027778))
    DCAF.NAVAID:NewFix("NIKAS", COORDINATE:NewFromLLDD(35.19333333, 35.71694444))
    DCAF.NAVAID:NewFix("OTILA", COORDINATE:NewFromLLDD(32.02527778, 39.03138889))
    DCAF.NAVAID:NewFix("PASIP", COORDINATE:NewFromLLDD(33.10027778, 38.93333333))
    DCAF.NAVAID:NewFix("PIDET", COORDINATE:NewFromLLDD(32.52944444, 34.78416667))
    DCAF.NAVAID:NewFix("PIKOG", COORDINATE:NewFromLLDD(32.82527778, 33.62472222))
    DCAF.NAVAID:NewFix("SOKAN", COORDINATE:NewFromLLDD(33.13583333, 38.36861111))
    DCAF.NAVAID:NewFix("SULAF", COORDINATE:NewFromLLDD(33.45500000, 38.17416667))
    DCAF.NAVAID:NewFix("ZAHAV", COORDINATE:NewFromLLDD(32.81444444, 34.81000000))
    DCAF.NAVAID:NewFix("ZUKKO", COORDINATE:NewFromLLDD(32.56166667, 33.94916667))
    DCAF.NAVAID:NewFix("VELOX", COORDINATE:NewFromLLDD(33.81694444, 34.08333333))
    DCAF.NAVAID:NewFix("VESAR", COORDINATE:NewFromLLDD(35.91555556, 34.01611111))
    DCAF.NAVAID:NewFix("XEAST", COORDINATE:NewFromLLDD(33.44638889, 40.45222222))

    -- Syria (SYR) - VOR/DME
    -- xxx = DCAF.NAVAID:NewVOR("xxx", 999.00, COORDINATE:NewFromLLDD(99, 99))  -- ???
    DCAF.NAVAID:NewVOR("ADA", 112.70, COORDINATE:NewFromLLDD(36.94055556, 35.21027778))  -- Turkey, Adana,  Alanya
    DCAF.NAVAID:NewVOR("AYT", 114.00, COORDINATE:NewFromLLDD(36.92083333, 30.79444444))  -- Turkey, Antalya Intl
    DCAF.NAVAID:NewVOR("CAK", 116.20, COORDINATE:NewFromLLDD(34.30027778, 35.69972222))  -- Lebanon, Wujah Al Hajar
    DCAF.NAVAID:NewVOR("GZP", 316.00, COORDINATE:NewFromLLDD(36.30444444, 32.29750000))  -- Turkey, Gazipasa Alanya
    DCAF.NAVAID:NewVOR("KAD", 112.60, COORDINATE:NewFromLLDD(33.80722222, 35.48583333))  -- Lebanon, Beirut, Rafic Hariri Intl
    DCAF.NAVAID:NewVOR("KTN", 117.70, COORDINATE:NewFromLLDD(34.22222222, 37.27361111))  -- Syria, Kariatain, 
    DCAF.NAVAID:NewVOR("LCA", 112.80, COORDINATE:NewFromLLDD(34.87277778, 33.62500000))  -- Cyprus, Larnaca
    DCAF.NAVAID:NewVOR("LTK", 114.80, COORDINATE:NewFromLLDD(35.39666667, 35.95194444))  -- Syria, Latakia, Bassel Al-Assad
    DCAF.NAVAID:NewVOR("MUT", 112.30, COORDINATE:NewFromLLDD(36.91277778, 33.29166667))  -- Turkey, 58nm NE Gazipasa
    DCAF.NAVAID:NewVOR("PHA", 117.90, COORDINATE:NewFromLLDD(34.71166667, 32.50583333))  -- Cyprus, Paphos
    DCAF.NAVAID:NewVOR("TAN", 114.00, COORDINATE:NewFromLLDD(33.49277778, 38.71777778))  -- Syria, Tanf
    -- Syria (SYR) - TACAN/VORTAC
    DCAF.NAVAID:NewTACAN( "PHA1",         79, 'X', COORDINATE:NewFromLLDD(34.71694444, 32.48250000))  -- Cyprus, Paphos


    -- Nevada Test and Training Range (NTR) - Waypoints
    _DCAF_defaultMap = DCSMAP.NTTR
    DCAF.NAVAID:NewFix("APEX", COORDINATE:NewFromLLDD(36.35972222, -114.90527778))
    DCAF.NAVAID:NewFix("ARCOE", COORDINATE:NewFromLLDD(36.73750000, -114.91694444))
    DCAF.NAVAID:NewFix("ATALF", COORDINATE:NewFromLLDD(36.39194444, -114.87194444))
    DCAF.NAVAID:NewFix("BESSY", COORDINATE:NewFromLLDD(36.17694444, -115.34611111))
    DCAF.NAVAID:NewFix("DREAM", COORDINATE:NewFromLLDD(36.32916667, -115.21250000))
    DCAF.NAVAID:NewFix("DRYLAKE", COORDINATE:NewFromLLDD(36.46138889, -114.87000000))
    DCAF.NAVAID:NewFix("FLEX",  COORDINATE:NewFromLLDD(36.31000000, -115.03944444))
    DCAF.NAVAID:NewFix("FYTTR", COORDINATE:NewFromLLDD(36.24361111, -115.70722222))
    DCAF.NAVAID:NewFix("LSV_R270", COORDINATE:NewFromLLDD(36.24361111, -115.21250000))
    DCAF.NAVAID:NewFix("GASSPEAK", COORDINATE:NewFromLLDD(36.40222222, -115.17888889))
    DCAF.NAVAID:NewFix("HRRLY", COORDINATE:NewFromLLDD(35.98944444, -115.34694444))
    DCAF.NAVAID:NewFix("JELIR", COORDINATE:NewFromLLDD(36.29111111, -114.97194444))
    DCAF.NAVAID:NewFix("JENAR", COORDINATE:NewFromLLDD(36.33138889, -114.92833333))
    DCAF.NAVAID:NewFix("JOHKR", COORDINATE:NewFromLLDD(35.89527778, -115.93833333))
    DCAF.NAVAID:NewFix("JUNNO", COORDINATE:NewFromLLDD(36.73000000, -114.87944444))
    DCAF.NAVAID:NewFix("KRYSS", COORDINATE:NewFromLLDD(36.50611111, -114.73638889))
    DCAF.NAVAID:NewFix("KUTME", COORDINATE:NewFromLLDD(36.50472222, -114.73444444))
    DCAF.NAVAID:NewFix("KWYYN", COORDINATE:NewFromLLDD(35.86527778, -115.40666667))
    DCAF.NAVAID:NewRadial("LSV02821", COORDINATE:NewFromLLDD(36.55166667, -114.81611111)) -- LSV radial 028 21nm
    DCAF.NAVAID:NewRadial("LSV27015", COORDINATE:NewFromLLDD(36.31111111, -115.32416667)) -- LSV radial 270 15nm
    DCAF.NAVAID:NewRadial("LSV02438", COORDINATE:NewFromLLDD(36.81388889, -114.70055556)) -- LSV radial 024 38nm
    DCAF.NAVAID:NewFix("OLNIE", COORDINATE:NewFromLLDD(36.58972222, -114.94944444))
    DCAF.NAVAID:NewFix("RAWKK", COORDINATE:NewFromLLDD(35.87388889, -115.55694444))
    DCAF.NAVAID:NewFix("RONKY", COORDINATE:NewFromLLDD(36.65527778, -114.93500000))
    DCAF.NAVAID:NewFix("STRYK", COORDINATE:NewFromLLDD(36.42666667, -115.51138889))
    DCAF.NAVAID:NewFix("WISTO", COORDINATE:NewFromLLDD(36.58972222, -114.94944444))

    
    
    _DCAF_defaultMap = nil



-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                           AIRDROMES
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    -- PEG - Iran
    AIRBASE_INFO:New("OIBA", country.id.IRAN, AIRBASE.PersianGulf.Abu_Musa_Island_Airport)
    AIRBASE_INFO:New("OIBK", country.id.IRAN, AIRBASE.PersianGulf.Kish_International_Airport)
    AIRBASE_INFO:New("OIBL", country.id.IRAN, AIRBASE.PersianGulf.Bandar_Lengeh)
    AIRBASE_INFO:New("OIBV", country.id.IRAN, AIRBASE.PersianGulf.Lavan_Island_Airport)
    AIRBASE_INFO:New("OIKB", country.id.IRAN, AIRBASE.PersianGulf.Bandar_Abbas_Intl)
    AIRBASE_INFO:New("OIKJ", country.id.IRAN, AIRBASE.PersianGulf.Jiroft_Airport) 
    AIRBASE_INFO:New("OIKK", country.id.IRAN, AIRBASE.PersianGulf.Kerman_Airport) 
    AIRBASE_INFO:New("OIKP", country.id.IRAN, AIRBASE.PersianGulf.Havadarya) 
    AIRBASE_INFO:New("OIKQ", country.id.IRAN, AIRBASE.PersianGulf.Qeshm_Island)
    AIRBASE_INFO:New("OISL", country.id.IRAN, AIRBASE.PersianGulf.Lar_Airbase)
    AIRBASE_INFO:New("OISS", country.id.IRAN, AIRBASE.PersianGulf.Shiraz_International_Airport)
    AIRBASE_INFO:New("OIZJ", country.id.IRAN, AIRBASE.PersianGulf.Bandar_e_Jask_airfield)
    -- PEG - United Arab Emirates (UAE)
    AIRBASE_INFO:New("OMAA", country.id.UNITED_ARAB_EMIRATES , AIRBASE.PersianGulf.Abu_Dhabi_International_Airport) 
    AIRBASE_INFO:New("OMAM", country.id.UNITED_ARAB_EMIRATES , AIRBASE.PersianGulf.Al_Dhafra_AB)
    AIRBASE_INFO:New("OMDM", country.id.UNITED_ARAB_EMIRATES , AIRBASE.PersianGulf.Al_Minhad_AB)
    AIRBASE_INFO:New("OMDB", country.id.UNITED_ARAB_EMIRATES , AIRBASE.PersianGulf.Dubai_Intl)
    AIRBASE_INFO:New("OMLW", country.id.UNITED_ARAB_EMIRATES , AIRBASE.PersianGulf.Liwa_Airbase)
    AIRBASE_INFO:New("OMSJ", country.id.UNITED_ARAB_EMIRATES , AIRBASE.PersianGulf.Sharjah_Intl)
    -- PEG - Oman
    AIRBASE_INFO:New("OOKB", country.id.OMAN , AIRBASE.PersianGulf.Khasab)

    -- SYR - Cyprus
    AIRBASE_INFO:New("LCEN", country.id.CYPRUS, AIRBASE.Syria.Ercan)
    AIRBASE_INFO:New("LCGK", country.id.CYPRUS, AIRBASE.Syria.Gecitkale)
    AIRBASE_INFO:New("LCLK", country.id.CYPRUS, AIRBASE.Syria.Larnaca)
    AIRBASE_INFO:New("LCPH", country.id.CYPRUS, AIRBASE.Syria.Paphos)
    AIRBASE_INFO:New("LCRA", country.id.CYPRUS, AIRBASE.Syria.Akrotiri)
    -- SYR - Lebanon
    AIRBASE_INFO:New("OLBA", country.id.LEBANON, AIRBASE.Syria.Beirut_Rafic_Hariri)
    AIRBASE_INFO:New("OLKA", country.id.LEBANON, AIRBASE.Syria.Rene_Mouawad)
    -- SYR - Syria
    AIRBASE_INFO:New("OSDI", country.id.SYRIA, AIRBASE.Syria.Damascus)
    AIRBASE_INFO:New("OSAP", country.id.SYRIA, AIRBASE.Syria.Aleppo)
    AIRBASE_INFO:New("OSLK", country.id.SYRIA, AIRBASE.Syria.Bassel_Al_Assad)
    -- SYR - Turkey
    AIRBASE_INFO:New("LTAF", country.id.TURKEY, AIRBASE.Syria.Adana_Sakirpasa)
    AIRBASE_INFO:New("LTAG", country.id.TURKEY, AIRBASE.Syria.Incirlik)
    AIRBASE_INFO:New("LTAJ", country.id.TURKEY, AIRBASE.Syria.Gaziantep)
    AIRBASE_INFO:New("LTCS", country.id.TURKEY, AIRBASE.Syria.Sanliurfa)
    AIRBASE_INFO:New("LTDA", country.id.TURKEY, AIRBASE.Syria.Hatay)
    AIRBASE_INFO:New("LTFG", country.id.TURKEY, AIRBASE.Syria.Gazipasa)
    -- SYR - Israel
    AIRBASE_INFO:New("LLHA", country.id.ISRAEL, AIRBASE.Syria.Haifa)

    -- NTR - Nevada Test and Training Range
    AIRBASE_INFO:New("KLAS", country.id.USA, AIRBASE.Nevada.McCarran_International_Airport)
    AIRBASE_INFO:New("KLSV", country.id.USA, AIRBASE.Nevada.Nellis_AFB)
                :AddDepartures(
                    DCAF.AIR_ROUTE:NewDeparture("FYTTR6", { "03L", "03R" }, "KLSV JELIR/F058 LSV_R270 FYTTR/F140"),
                    DCAF.AIR_ROUTE:NewDeparture("03 DREAM4", { "03L", "03R" }, "KLSV ATALF/F160 JUNNO/F180"))
                :AddArrivals(
                    DCAF.AIR_ROUTE:NewArrival("STRYK", { "21L", "21R" }, "STRYK/F095 GASSPEAK/F085 APEX/F040 KLSV"),
                    DCAF.AIR_ROUTE:NewArrival("21 TACAN", { "21L", "21R" }, "ARCOE/F150 RONKY/F150 WISTO LSV02821 KUTME/F088 JENAR/F044 KLSV"),
                    DCAF.AIR_ROUTE:NewArrival("21 ILS", { "21L", "21R" }, "KRYSS/F089 KLSV"))




--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                     SYR - Syria map
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



-- addAIRACAerodromes(
--     AIRAC_Aerodrome:New(AIRBASE.Syria.Incirlik, 'LTAG')
--             :WithATIS( 377.50 )
--             :WithTWR({ 360.20, 129.40 })
--             :WithGND({ 360.05, 129.05 })
--             :WithDEP({ 360.60, 129.60 })
--             :WithTACAN(21)
--             :WithILS({ ["5"] = 109.3, ["23"] = 111.7 })
--             :WithVoice(ATIS.Culture.US, ATIS.Gender.Random),

--         AIRAC_Aerodrome:New(AIRBASE.Syria.Gaziantep, 'LTAJ')
--             :WithATIS( 119.275 )
--             :WithTWR({ 250.9, 121.1 })
--             :WithGND({ 250.05, 121.05 })
--             :WithDEP({ 250.60, 121.60 })
--             :WithILS({ ["5"] = 108.7 })
--             :WithVOR( 116.7 )
--             :WithVoice(ATIS.Culture.US, ATIS.Gender.Random),

--         --== SYRIA Map :: BRITISH OVERSEAS TERRITORIES ==--
--         AIRAC_Aerodrome:New(AIRBASE.Syria.Akrotiri, 'LCRA')
--             :WithATIS( 125.00 )
--             :WithTACAN(107)
--             :WithGND({ 339.05, 130.05 })
--             :WithTWR({ 339.85, 130.075 })
--             :WithDEP({ 339.60, 130.60 })
--             :WithILS({ ["28"] = 109.7} )
--             :WithVoice(ATIS.Culture.GB, ATIS.Gender.Random),
        
--         --== SYRIA Map :: REPUBLIC OF CYPRUS ==--
--         AIRAC_Aerodrome:New(AIRBASE.Syria.Paphos, 'LCPH')
--             :WithATIS( 127.325 )
--             :WithTACAN(79)
--             :WithGND({ 250.05, 127.05 })
--             :WithTWR({ 250.05, 127.80 })
--             :WithDEP({ 250.60, 127.60 })
--             :WithILS({ ["29"] = 108.9 })
--             :WithVoice(ATIS.Culture.Random, ATIS.Gender.Random),

--         --== SYRIA Map :: ISRAEL ==--
--         AIRAC_Aerodrome:New(AIRBASE.Syria.Ramat_David, 'LLRD')
--             :WithATIS( 123.225 )
--             :WithTACAN(84)
--             :WithGND({ 250.05, 118.05 })
--             :WithTWR({ 250.95, 118.60 })
--             :WithDEP({ 250.60, 118.60 })
--             :WithILS({ ["32"] = 111.1})
--             :WithVoice(ATIS.Culture.Random, ATIS.Gender.Random),

--         AIRAC_Aerodrome:New(AIRBASE.Syria.Rosh_Pina, 'LLIB')
--             :WithATIS( 128.350 )
--             :WithGND({ 251.05, 118.05 })
--             :WithTWR({ 251.40, 118.90 })
--             :WithDEP({ 251.60, 118.60 })
--             :WithVoice(ATIS.Culture.Random, ATIS.Gender.Random),

--         --== SYRIA Map :: SYRIA ==--
--          AIRAC_Aerodrome:New(AIRBASE.Syria.Damascus, 'OSDI')
--             :WithATIS( 128.225 )
--             :WithGND({ 251.05, 118.05 })
--             :WithTWR({ 251.45, 118.50 })
--             :WithDEP({ 251.60, 118.60 })
--             :WithILS({ ["23R"] = 109.9, ["05R"] = 110.1 })
--             :WithVoice(ATIS.Culture.Random, ATIS.Gender.Random)
-- )

-- function DCAF.AIRAC:StartSyriaATIS(SRSPath, SRSPort)
--     DCAF.AIRAC:ConfigureSRS(SRSPath, SRSPort)
--     for key, name in pairs(AIRBASE.Syria) do
--         local aerodrome = DCAF.AIRAC.Aerodromes[name]
--         if aerodrome then
--             aerodrome:StartATIS()
--         end
--     end
-- end

                      
----------------------------------------------------------------------------------------------

Trace("DCAF.AIRAC_2022_A.lua was loaded")