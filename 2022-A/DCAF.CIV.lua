CIV = {}

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
    return civOp:Schedule(nInterval, nDelay, nIntervalRndFactor)
end

local function destroyOnLastTurnpoint(group, waypoint)
    -- destroy group if last WP is en-route (retain if landing at airport)
if waypoint == nil then
    error("nisse!") end    -- nisse 


    if waypoint.type ~= "Turning Point" then
        return end

    local coordWP = COORDINATE_FromWaypoint(waypoint)
    local coordGP = group:GetCoordinate()
    local distance = coordGP:Get2DDistance(coordWP)
    local speed = waypoint.speed
    local time = distance / speed;
    Delay(time, function()
        group:Destroy()
    end)
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
      route:Fly(group)
           :OnArrival(function(group, waypoint)             
                destroyOnLastTurnpoint(group, waypoint)
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
    local function randomGroup()
        return listRandomItem(self.Groups)
    end

    for _, route in ipairs(self.Routes) do
        local options = DCAF.AIR_ROUTE_OPTIONS:New()
        options:OnArrival(function(group, waypoint) 
            destroyOnLastTurnpoint(group, waypoint)
        end)
        route:Populate(nSeparation, randomGroup, options)
    end
    return self
end
