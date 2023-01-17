# DCAF AIRAC 2022-A

This DCAF AIRAC is the first cycle contains the following:

- Airodrome plates for eight bases we can be expected to operate from when operating on the Syria map
- A mission template for Syria and the Persian Gulf

## More about the AIRAC project
An AIRAC is a collective package of charts and mission templates that support a common set of frequencies and state. All charts included in an AIRAC cycle presents the correct frequencies used for the aerodrome/region it covers. DCAF supports a common "master data" for frequencies, and aerodrome related details, and this is always the source for all such details.

An AIRAC cycle is published as a single .zip file, named using this format: `DCAF AIRAC <year>-<cycle>[-<version>].zip`

All cycles are tied to the year of their release and is given a cycle letter (A through Z), meaning there can be no more than  24 cycles per year (hopefully there will be zero or less). A new AIRAC cycle needs to be published when one or more frequencies in DCAFs database changes. A cycle can also be published in two or more versions. This might happen if an issue has been identified and corrected. 

The AIRAC ***letter*** cycle (the letter) only increases because of changes to frequencies or other aerodrome related details. The sub AIRAC cycle ***version*** only increase to add more features or tofor resolved technical issues.

## Aerodrome plates
The aerodrome plates can be found in the contained .PDF files (eg. DCAF_SYR_2022-A.pdf). Most plates was created from CombatWombat's excellent collection but has been edited to ensure all printed frequencies comply with DCAF's AIRAC database. The plates also include the correct windsock loaction (see [Mission Template](#mission-template) below).

## Mission Template

To make it easy for our mission authors to include AIRAC compatible features the plan is to also include mission templates with each AIRAC cycle. As of this first cycle only Syria (SYR) and Persian Gulf (PEG) are supported so there are just two mission templates, one for each map. Future AIRAC versions and cycles will include more maps.

A mission template is designed to improve the experience for virtual pilots while releiving mission authors from menial details (such as setting correct frequencies, TACAN etc for air tankers and carriers) and instead allow them to focus on the exciting stuff; creating interesting and fun tactical problems for DCAF's members.

Mission templates (.miz files) are located under separate sub folders, abbrevtaited per map (./SYR, ./PEG etc)

The template include these main features:

- Windsocks at most AIRAC aerodromes, making life a bit easier for our virtual pilots
- ATIS (Automated Terminal Information Service) at most aerodromes covered by AIRAC
- Airborne services (tankers and AWACS) that behave correctly and remain available throughout a mission (even very long ones)
- Navy services, such as launching recovery tankers etc.

Let's walk through these features to shed some more light on what they mean...

### Windsocks
Most aerodromes, even small ones, usually have one or more windsocks located where pilots need them, to quickly assess the wind condition before departures or landings. Typically the windsocks are located near the extremes of each runway but they can also often be found near the parking ramp or along taxiways. When creating the mission template we used what reference material could be found, such as Jeppesen 10-9 plates. Where no reliable material could be found windsocks where simply placed where it made sense. The aerodrome charts included in the AIRAC cycle do depict the correct windsock location on each aerodrome.

### ATIS
Most aerodromes covered by the AIRAC offers **Automated Terminal Information Service** (ATIS) at a certain frequency. Any virtual pilot tuning that frequency will receive ATIS that reflects the current weather and status of the aerodrome. 

The system is based on SRS and [MOOSE][moose], meaning you need to have an SRS client connected to an SR server. Also, the system uses on text-to-speech synthetization technology and relies on an executable found in the default SRS installation folder - `C:\Program Files\DCS-SimpleRadio-Standalone`. If you, as mission author, do not have SRS installed locally on your machine you will not hear any ATIS transmissions during testing, but they should work once you deploy your mission to a DCAF server.

If you do have SRS installed but in a different folder, and want to hear the transmissions, you need to extract the 'DCAF.AIRAC.lua' script file from the mission .miz file (that file is just a renamed .zip file), which can be found in the `I10n/DEFAULT` sub folder. In that file you will find these lines:

```lua
DCAF.AIRAC = {
    SRS_PATH = [[C:\Program Files\DCS-SimpleRadio-Standalone]],  --<<--change to reflect local SRS path
    SRS_PORT = nil -- default = 5002 (leave as-is unless you're running a different SR server port)
}
```

Please note that DCAF servers do have SRS installed in the preconfigured (default) folder so if you change it during mission editing/testing you need to restore the path before deploying your mission on our servers for ATIS to work.

### Airborne Services
The mission templates aims to relieve the mission author from the boring work of setting up working tanker and AWACS flight, with correct frequencies and behavior. The template contains four tankers (SHELL-1, SHELL-2, TEXACO-1 and TEXACO-2) but as mission author you will most likely want to position the tanker tracks somewhere else and rotate it to suite your plans. 

To do this, find the *DCAF.AirForce.lua* file, open it and follow the instructions. The process is quite simple:
1. In the mission editor, move tankers and AWACS waypoints to where you want them
2. Make sure there is at least one waypoint per service flight (other than the spawn/takeoff waypoint)
3. In the 'DCAF.AirForce.lua' file update the '`SetTrack( ... )`' functions to inform the script what waypoint is the start of the tanker track, set a heading and (optionally) length for the track.

The *DCAF.AirForce.lua* script is set up so that once the tankers (SHELL-1 and TEXACO-1) reaches their tanker track start waypoint they will automatically tune the correct radio and TACAN frequencies. Then, as they work the track and eventually reaches a fuel state of 40% a second tanker (SHELL-2 or TEXACO-2, rspectively) will spawn and head for its track. Later, when a tanker reaches 17% fuel state it will RTB, deactivating its TACAN and de-tuning th radio (tuning its initial frequency, typically for the AI airbase ATC) and head home. At the same time a replacement tanker (SHELL-1 or TEXACO-1) spawns and heads out to replace the one going home. This means there will always be a tanker available at the tanker tracks and, at most times, two tankers.

Finally, to conserve memory and avoid cluttering airbases with parked tankers, after the tanker aircraft has landed it will taxi to the ramp, park, and sit there for a while before it automatically despawns. The current setting (again; check *DCAF.AirForce.lua*) is 10 minutes after touchdown. If you use a very large aerodrome and see that there is not enough time to taxi and park you can increase this value. Look for this line in the script: 

```lua
local DespawnDelay = Minutes(10)
```

The AWACS flights mimic the same behavior, ensuring there is always an AWACS up.

### Navy services
The mission template support the "special needs" of naval aviators, such as launching a rescue helicopter, recovery tankers and reactivating the carrier's TILS and TACAN, if needed. This can be done from the custom F10 COMMS menu and the miz template ensures only naval airframes (Tomcats, Hornets and Harriers) have these options. (Viper, Apache or Eagle drivers, for example, will not be able to do these things)

[moose]: https://flightcontrol-master.github.io/MOOSE_DOCS/ "MOOSE"