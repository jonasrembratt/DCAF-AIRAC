--[[
   **** DCAF AIR FORCE SERVICES ****
   This script provides correct behavior of services (tankers and AWACS) and ensures they are always available throughout a mission:

   .... TANKERS ....
   - The mission starts with two tanker tracks - SHELL and TEXACO
   - When SHELL-1 or TEXACO-1 reaches 40% remaining fuel it will automatically spawn a second tanker (SHELL-2 / TEXACO-2)
   - When a tanker a tanker reaches 17% remaining fuel it will RTB and spawn its replacement
   - When a tanker leaves the tanker track it deactivates its TACAN and tunes the ATC freq of its RTB aerodrome
   - Just before a new (replacement) tanker reaches its tanker track it will tune the correct frequency and activate its TACAN, as per DCAF COMMS standards
   - After a tanker has RTB and landed it will automatically despawn after a set time (see 'DespawnDelay' below)
   
   .... AWACS ....
   - The mission starts with one AWACS - MAGIC 1, almost already at the AWACS track
   - As the AWACS reaches 25% fuel it spawns its replacement (MAGIC-2). Magic-2 starts up on the ramp then taxis out and takes off and heads for the AWACS track
   - When the AWACS reaches 17% fuel it will RTB 
   - After an AWACS has RTB and landed it will automatically despawn after a set time (see 'DespawnDelay' below)

   USING THIS SCRIPT 
   The various services will automatically tune the correct radio and TACAN frequencies as they commence their service task.
   They will also cruise at a configured altitude, to create deconfliction.
   The tracks they fly will be drawn on the F10 map, for convenience

   The position, heading and length of the service's tracks is likely something you will want to change of course,
   to suit the tactical situation, avoid certain airspace and so on. The below script is quite easy to read
   and understand even if you're not a Lua ninja so changing these details is quite easy.

   ## CHANGING THE TRACKS
   Each service's track is configured from the 'SetTrack' function (see below) with, like in this example:
      :SetTrack(2, 201, NauticalMiles(40)), nil, false)

      The parameters (2, 201, ... etc.) are as follows:

      1. Waypoint number (2 in example). 
         Looking at the F10 map, this waypoint marks the start of the track. If you need the service flights
         to fly a different ingress, and adds/removes waypoints, just make sure this value is set to the waypoint where
         the service track is supposed to begin

      2. Track heading (201 in example).
         The track outgoing heading in degrees. The service will automatically be set up to fly a racetrack so only the
         outgoing heading is required.

      3. Track length (NauticalMiles(40) in example)
         Value is always given in meters. Using the NauticalMiles() function, as above, just converts 40 (miles) to the
         corresponding value in meters. Change this for a shorter/longer track

      4. Block (in 1000 feet)
         In example this value is passed as 'nil', which means the service will fly its track at a preconfigured 
         altitude. If you want more control over how the services deconflict just pass a value. Remember the value
         is stated as 1000 feet, so to have the service fly at 22000 feet, just pass 22

      5. Draw track
         This value can be passed as 'true', 'false' or as a color:
         - 'true' will draw a track on the F10 map with a preconfigured color - one for tankers and another for AWACS
         - 'false' to not draw a track at all
         - A custom color, using this format { Red, Green, Blue }. Each value is given as an integer 0-255.
           As an example; to draw a orange track pass { 207, 145, 0 }

   ## ACTIVATING THE SCRIPT 
   To activate this script, do the following in the DCS Mission Editor:
   1. Click the Triggers button to open the Triggers Editor
   2. Select the last trigger "MISSION START (DCAF Air Force")
   3. Select the action (in the right-most column, "ACTIONS")
   The action is of type "DO SCRIPT", with this script:
]]

--   dofile( [[C:\YOUR\MISSION\FOLDER\DCAF.AirForce.lua]] 

--[[
   Just replace the C:\YOUR\MISSION\FOLDER part to match the correct path to where you keep this file in your file system
]]



local function SpawnDelay()
   return 0  -- change to a positive value to delay spawning of replacement services (tankers/AWACS). Value is in seconds 
             -- Hint: you can also return a random value (eg. delay betwen 30sec and 5 minutes: return math.random(30, Minutes(5)) )
end

local DespawnDelay = Minutes(10) -- all services will despawn 10 minutes after RTB and landing, giving them time to taxi and park and stay around for a short while

----- SECOND WAVE OF TANKERS (Shell-2 and Texaco-2; please look for >>SECOND WAVE<< below)
local function launchShell2()
   DCAF.Tanker:NewFromCallsign(CALLSIGN.Tanker.Shell, 2)
      -- >>SHELL TRACK<< next line establishes the tanker track at waypoint 2, with 102 degree heading for 40nm (change as needed)
     :SetTrack(2, 305, NauticalMiles(40)) -- track begins at WP2, tracks heading 102 degrees for 40nm at block 22, and 'true' = track is drawn on F10 map
     :OnFuelState(0.17, function(tanker)  -- automatically RTB and spawn replacement when fuel reaches 17%
         tanker:RTB()
         tanker:SpawnReplacement(SpawnDelay()) -- comment this line if you do NOT want the tanker to launch replacement
      end) 
     :Start(SpawnDelay())
end

local function launchTexaco2()
   DCAF.Tanker:NewFromCallsign(CALLSIGN.Tanker.Texaco, 2)
      -- >>SHELL TRACK<< next line establishes the tanker track at waypoint 2, with 305 degree heading for 40nm (change as needed)
     :SetTrack(2, 305, NauticalMiles(40))  -- track begins at WP2, tracks heading 305 degrees for 40nm at block 22, and 'true' = track is drawn on F10 map
     :OnFuelState(0.17, function(tanker)  -- automatically RTB and spawn replacement when fuel reaches 17%
         tanker:RTB():DespawnOnLanding(DespawnDelay)
         tanker:SpawnReplacement(SpawnDelay()) -- comment this line if you do NOT want the tanker to launch replacement
      end) 
     :Start(SpawnDelay())
end

----- REPLACEMENT AWACS
local function launchMagic2()
   DCAF.AWACS:NewFromCallsign(CALLSIGN.AWACS.Magic, 2)
      -- >>AWACS TRACK<< next line establishes the AWACS track at waypoint 2, 305 degree heading for 60nm (change as needed)
      :SetTrack(2, 105, NauticalMiles(60), nil, false) 
      :OnFuelState(0.25, function(awacs) 
         awacs:SpawnReplacement(SpawnDelay()) -- comment this line if you do NOT want to launch a replacement tanker when this one reaches 40% fuel          
      end)
      :OnFuelState(0.17, function(awacs)  
         awacs:RTB():DespawnOnLanding(DespawnDelay)
      end) 
      :Start()
end


----- FIRST WAVE OF TANKERS (Shell-1 and Texaco-1)
DCAF.Tanker:NewFromCallsign(CALLSIGN.Tanker.Shell, 1)
         -- >>SHELL TRACK<< next line establishes the tanker's track at waypoint 2, with 305 degree heading for 40nm (change as needed)
         :SetTrack(2, 305, NauticalMiles(40), nil, true) -- track begins at WP2, heading 305 degrees, for 40nm, at block 22, and 'true' = track is drawn on F10 map
         :OnFuelState(0.4, function() 
            launchShell2()  -- comment this line if you do NOT want to launch 2nd tanker (SHELL-2) once SHELL-1 reaches 40% fuel
         end)
         :OnFuelState(0.17, function(tanker)    -- makes tanker RTB, to original airbase, when when fuel reaches 17%
            tanker:RTB():DespawnOnLanding(DespawnDelay)
            tanker:SpawnReplacement(SpawnDelay()) -- comment this line if you do NOT want to always have a SHELL-1 tanker working the track
         end) 
         :Start(SpawnDelay)

DCAF.Tanker:NewFromCallsign(CALLSIGN.Tanker.Texaco, 1)
           -- >>SHELL TRACK<< next line establishes the tanker's track at waypoint 2, with 305 degree heading for 40nm (change as needed)
         :SetTrack(2, 305, NauticalMiles(40), nil, true) -- track begins at WP2, heading 305 degrees, for 40nm, at block 22, and 'true' = track is drawn on F10 map
         :OnFuelState(0.40, function() 
            launchTexaco2() --  comment this line if you do NOT want to launch 2nd tanker (TEXACO-2) once TEXACO-1 reaches 40% fuel
         end)
         :OnFuelState(0.17, function(tanker)  -- makes tanker RTB, to original airbase, when when fuel reaches 17%
            tanker:RTB():DespawnOnLanding(DespawnDelay)
            tanker:SpawnReplacement(SpawnDelay)   -- comment this line if you do NOT want to always have a TEXACO-1 tanker working the track
         end) 
         :Start(SpawnDelay)

----- AWACS - MAGIC-1
DCAF.AWACS:NewFromCallsign(CALLSIGN.AWACS.Magic, 1)
         -- >>AWACS TRACK<< next line establishes the AWACS track at waypoint 1, with 243 degree heading for 60nm (change as needed)
         :SetTrack(1, 105, NauticalMiles(60), nil, true) 
         :OnFuelState(0.25, function() 
            launchMagic2() -- >>SECOND WAVE<< comment this line if you do NOT want continous AWACS coverage
         end)
         :OnFuelState(0.17, function(awacs)     -- makes tanker RTB, to orifinal airbase, when when fuel reaches 17%
            awacs:RTB(AIRBASE.PersianGulf.Al_Dhafra_AB):DespawnOnLanding(DespawnDelay)
         end) 
         :Start()

Trace("DCAF.AirForce.lua was loaded")