DCAF.Debug = true

local delayInSeconds = 0 -- SET this value to delay spawning of replacement tankers/AWACS. 
                         -- Tip: you can also assign a random value (eg. delay betwen 1 and 5 minutes: delayInSeconds = math.random(60, 300) )

----- SECOND WAVE OF TANKERS (Shell-2 and Texaco-2; please look for >>SECOND WAVE<< below)
local function launchShell2()
   DCAF.Tanker:NewFromCallsign(CALLSIGN.Tanker.Shell, 2)
      -- >>SHELL TRACK<< next line establishes the tanker track at waypoint 2, with 102 degree heading for 40nm (change )
     :SetTrackFromWaypoint(2, 201, NauticalMiles(40)) -- track begins at WP2, tracks heading 102 degrees for 40nm at block 22, and 'true' = track is drawn on F10 map
     :OnFuelState(0.17, function(tanker)  -- will automatically spawn its replacement when fuel reaches 17%
         tanker:RTB()
         -- comment next line if you do NOT want the tanker to launch replacement (to always have a SHELL-2 tanker working the track)
         tanker:SpawnReplacement(delayInSeconds) -- spawns after <delay> seconds (nil/0 seconds = wpasn now)
      end) 
     :Start(delayInSeconds)
end

local function launchTexaco2()
   DCAF.Tanker:NewFromCallsign(CALLSIGN.Tanker.Texaco, 2)
      -- >>SHELL TRACK<< next line establishes the tanker track at waypoint 2, with 102 degree heading for 40nm (change )
     :SetTrackFromWaypoint(2, 21, NauticalMiles(40)) -- track begins at WP2, tracks heading 102 degrees for 40nm at block 22, and 'true' = track is drawn on F10 map
     :OnFuelState(0.17, function(tanker)  -- will automatically spawn its replacement when fuel reaches 17%
         tanker:RTB()
         -- comment next line if you do NOT want the tanker to launch replacement (to always have a TEXACO-2 tanker working the track)
         tanker:SpawnReplacement(delayInSeconds) -- spawns after <delay> seconds (nil/0 seconds = wpasn now)
      end) 
     :Start(delayInSeconds)
end


----- FIRST WAVE OF TANKERS (Shell-1 and Texaco-1)
DCAF.Tanker:NewFromCallsign(CALLSIGN.Tanker.Shell, 1)
           -- >>SHELL TRACK<< next line establishes the tanker track at waypoint 2, with 102 degree heading for 40nm (change )
           :SetTrackFromWaypoint(2, 201, NauticalMiles(40), nil, true) -- track begins at WP2, tracks heading 201 degrees for 40nm at block 22, and 'true' = track is drawn on F10 map
           :OnFuelState(0.4, function() 
               -- >>SECOND WAVE<< comment next line if you do not want to launch SHELL-2 once SHELL-1 reaches 40% fuel
               launchShell2() 
            end)
           :OnFuelState(0.17, function(tanker)  -- makes tanker RTB, to orifinal airbase, when when fuel reaches 17%
               tanker:RTB()
               -- comment next line if you do NOT want to always have a SHELL-1 tanker working the track
               tanker:SpawnReplacement(delayInSeconds)   -- spawns after <delay> seconds (nil/0 seconds = wpasn now)
            end) 
           :Start(delayInSeconds)

DCAF.Tanker:NewFromCallsign(CALLSIGN.Tanker.Texaco, 1)
           -- >>SHELL TRACK<< next line establishes the tanker track at waypoint 2, with 102 degree heading for 40nm (change )
           :SetTrackFromWaypoint(2, 21, NauticalMiles(40), nil, true) -- track begins at WP2, tracks heading 21 degrees for 40nm at block 22, and 'true' = track is drawn on F10 map
           :OnFuelState(0.40, function() 
               -- >>SECOND WAVE<< comment next line if you do NOT want to launch TEXACO-2 once TEXACO-1 reaches 40% fuel
               launchTexaco2() 
            end)
           :OnFuelState(0.17, function(tanker)  -- makes tanker RTB, to original airbase, when when fuel reaches 17%
               tanker:RTB()
               -- comment next line if you do NOT want to always have a TEXACO-1 tanker working the track
               tanker:SpawnReplacement(delayInSeconds)   -- spawns after <delay> seconds (nil/0 seconds = wpasn now)
            end) 
           :Start(delayInSeconds)


-- comment this function if you do NOT want tankers to be automatically removed 10 mins after landing
MissionEvents:OnAircraftLanded(function(event) 

   if (IsTankerCallsign(event.IniGroup, CALLSIGN.Tanker.Shell, CALLSIGN.Tanker.Texaco)) then
      Delay(600, function() event.IniGroup:Destroy() end)
   end

end)


Trace("DCAF.AirForce.lua was loaded")