-- DCAF AIRAC 2022-A
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                    SUPPORTED MAPS
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


        --== SYRIA Map ==--

function DCAF.AIRAC:StartSyriaATIS(SRSPath, SRSPort)
    DCAF.AIRAC:ConfigureSRS(SRSPath, SRSPort)
    for key, name in pairs(AIRBASE.Syria) do
        local aerodrome = DCAF.AIRAC.Aerodromes[name]
        if aerodrome then
            aerodrome:StartATIS()
        end
    end
end

        --== PERSIAN GULF Map ==--

function DCAF.AIRAC:StartPersianGulfATIS(SRSPath, SRSPort)
    DCAF.AIRAC:ConfigureSRS(SRSPath, SRSPort)
    for key, name in pairs(AIRBASE.PersianGulf) do
        local aerodrome = DCAF.AIRAC.Aerodromes[name]
        if aerodrome then
            aerodrome:StartATIS()
        end
    end
end

      
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                                                      AIRAC 2022-A
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

DCAF.AIRAC.Version = "2022-A"
DCAF.AIRAC.Aerodromes = {

        --== SYRIA Map :: TURKEY ==--

        [AIRBASE.Syria.Incirlik] = AIRAC_Aerodrome:New(AIRBASE.Syria.Incirlik, 'LTAG')
            :WithATIS( 377.50 )
            :WithTWR({ 360.20, 129.40 })
            :WithGND({ 360.05, 129.05 })
            :WithDEP({ 360.60, 129.60 })
            :WithTACAN(21)
            :WithILS({ ["5"] = 109.3, ["23"] = 111.7 })
            :WithVoice(ATIS.Culture.US, ATIS.Gender.Random),

        [AIRBASE.Syria.Gaziantep] = AIRAC_Aerodrome:New(AIRBASE.Syria.Gaziantep, 'LTAJ')
            :WithATIS( 119.275 )
            :WithTWR({ 250.9, 121.1 })
            :WithGND({ 250.05, 121.05 })
            :WithDEP({ 250.60, 121.60 })
            :WithILS({ ["5"] = 108.7 })
            :WithVOR( 116.7 )
            :WithVoice(ATIS.Culture.US, ATIS.Gender.Random),

        --== SYRIA Map :: BRITISH OVERSEAS TERRITORIES ==--
        [AIRBASE.Syria.Akrotiri] = AIRAC_Aerodrome:New(AIRBASE.Syria.Akrotiri, 'LCRA')
            :WithATIS( 125.00 )
            :WithTACAN(107)
            :WithGND({ 339.05, 130.05 })
            :WithTWR({ 339.85, 130.075 })
            :WithDEP({ 339.60, 130.60 })
            :WithILS({ ["28"] = 109.7} )
            :WithVoice(ATIS.Culture.GB, ATIS.Gender.Random),
        
        --== SYRIA Map :: REPUBLIC OF CYPRUS ==--
        [AIRBASE.Syria.Paphos] = AIRAC_Aerodrome:New(AIRBASE.Syria.Paphos, 'LCPH')
            :WithATIS( 127.325 )
            :WithTACAN(79)
            :WithGND({ 250.05, 127.05 })
            :WithTWR({ 250.05, 127.80 })
            :WithDEP({ 250.60, 127.60 })
            :WithILS({ ["29"] = 108.9 })
            :WithVoice(ATIS.Culture.Random, ATIS.Gender.Random),

        --== SYRIA Map :: ISRAEL ==--
        [AIRBASE.Syria.Ramat_David] = AIRAC_Aerodrome:New(AIRBASE.Syria.Ramat_David, 'LLRD')
            :WithATIS( 123.225 )
            :WithTACAN(84)
            :WithGND({ 250.05, 118.05 })
            :WithTWR({ 250.95, 118.60 })
            :WithDEP({ 250.60, 118.60 })
            :WithILS({ ["32"] = 111.1})
            :WithVoice(ATIS.Culture.Random, ATIS.Gender.Random),

        [AIRBASE.Syria.Rosh_Pina] = AIRAC_Aerodrome:New(AIRBASE.Syria.Rosh_Pina, 'LLIB')
            :WithATIS( 128.350 )
            :WithGND({ 251.05, 118.05 })
            :WithTWR({ 251.40, 118.90 })
            :WithDEP({ 251.60, 118.60 })
            :WithVoice(ATIS.Culture.Random, ATIS.Gender.Random),

        --== SYRIA Map :: SYRIA ==--
        [AIRBASE.Syria.Damascus] = AIRAC_Aerodrome:New(AIRBASE.Syria.Damascus, 'OSDI')
            :WithATIS( 128.225 )
            :WithGND({ 251.05, 118.05 })
            :WithTWR({ 251.45, 118.50 })
            :WithDEP({ 251.60, 118.60 })
            :WithILS({ ["23R"] = 109.9, ["05R"] = 110.1 })
            :WithVoice(ATIS.Culture.Random, ATIS.Gender.Random),
    



        --== PERSIAN GULF Map :: IRAN ==--
        -- [AIRBASE.PersianGulf.Bandar_Abbas_Intl] = AIRAC_Aerodrome:New(AIRBASE.PersianGulf.Bandar_Abbas_Intl, '')

}