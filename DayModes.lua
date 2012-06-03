--[[    ------------------------------------------------------------
                           DayModes.lua
--]]    ------------------------------------------------------------

modes = {
    {     -- morning
        length = 14,
        field = color(0,68,0,255),
        sky = color(24,26,167,255),
        sunseta = nil,
        sunsetb = nil,
        sunsetc = nil,
        cloud1 = color(255,255,255,255),
        cloud2 = color(167,190,221,255),
        rearlights = false,
        snow = false,
        fog = false
    },

    {     -- day1
        length = 17,
        field = color(0,68,0,255),
        sky = color(35,38,170,255),
        sunseta = nil,
        sunsetb = nil,
        sunsetc = nil,
        cloud1 = color(255, 255, 255, 255),
        cloud2 = color(167,190,221,255),
        rearlights = false,
        snow = false,
        fog = false
    },

    {     -- day2
        length = 17,
        field = color(0,68,0,255),
        sky = color(45,50,184,255),
        sunseta = nil,
        sunsetb = nil,
        sunsetc = nil,
        cloud1 = color(255,255,255,255),
        cloud2 = color(167,190,221,255),
        rearlights = false,
        snow = false,
        fog = false
    },
    
    {     -- snow
        length = 34,
        field = color(255,255,255,255),
        sky = color(45,50,184,255),
        sunseta = nil,
        sunsetb = nil,
        sunsetc = nil,
        cloud1 = color(255,255,255,255),
        cloud2 = color(167,190,221,255),
        rearlights = false,
        snow = true,
        fog = false
    },
    
    {     -- afternoon
        length = 4,
        field = color(20,60,0,255),
        sky = color(24,26,167,255),
        sunseta = nil,
        sunsetb = nil,
        sunsetc = nil,
        cloud1 = color(255,255,255,255),
        cloud2 = color(167,190,221,255),
        rearlights = false,
        snow = false,
        fog = false
    },

    {     -- sunset1
        length = 4,
        field = color(20,60,0,255),
        sky = color(24,26,167,255),
        sunseta = color(104,25,154,255),
        sunsetb = color(51,26,163,255),
        cloud1 = color(255,255,255,255),
        cloud2 = color(167,190,221,255),
        sunsetc = nil,
        rearlights = false,
        snow = false,
        fog = false
    },

    {     -- sunset2
        length = 4,
        field = color(20,60,0,255),
        sky = color(51,26,163,255),
        sunseta = color(151,25,122,255),
        sunsetb = color(104,25,154,255),
        sunsetc = nil,
        cloud1 = color(255, 255, 255, 255),
        cloud2 = color(226, 220, 199, 255),
        rearlights = false,
        snow = false,
        fog = false
    },

    {     -- sunset3
        length = 4,
        field = color(20,60,0,255),
        sky = color(51,26,163,255),
        sunseta = color(167,26,26,255),
        sunsetb = color(151,25,122,255),
        sunsetc = color(104,25,154,255),
        cloud1 = color(255,255,255,255),
        cloud2 = color(212, 202, 169, 255),
        rearlights = false,
        snow = false,
        fog = false
    },

    {     -- sunset4
        length = 4,
        field = color(48,56,0,255),
        sky = color(104,25,154,255),
        sunseta = color(163,57,21,255),
        sunsetb = color(167,26,26,255),
        sunsetc = color(151,25,122,255),
        cloud1 = color(230, 230, 230, 255),
        cloud2 = color(193, 168, 107, 255),
        rearlights = false,
        snow = false,
        fog = false
    },

    {     -- sunset5
        length = 4,
        field = color(48,56,0,255),
        sky = color(151,25,122,255),
        sunseta = color(181,83,40,255),
        sunsetb = color(163,57,21,255),
        sunsetc = color(167,26,26,255),
        cloud1 = color(204, 204, 204, 255),
        cloud2 = color(251,228,187,255),
        rearlights = false,
        snow = false,
        fog = false
    },

    {     -- sunset6
        length = 4,
        field = color(48,56,0,255),
        sky = color(167,26,26,255),
        sunseta = color(162,98,33,255),
        sunsetb = color(181,83,40,255),
        sunsetc = color(163,57,21,255),
        cloud1 = color(179, 179, 179, 255),
        cloud2 = color(255,194,104,255),
        rearlights = false,
        snow = false,
        fog = false
    },

    {     -- sunset7
        length = 4,
        field = color(48,56,0,255),
        sky = color(163,57,21,255),
        sunseta = color(134,134,29,255),
        sunsetb = color(162,98,33,255),
        sunsetc = color(181,83,40,255),
        cloud1 = color(156, 156, 156, 255),
        cloud2 = color(254,157,133,255),
        rearlights = false,
        snow = false,
        fog = false
    },

    {     -- night1
        length = 34,
        field = color(0,0,0,255),
        sky = color(74,74,74,255),
        sunseta = nil,
        sunsetb = nil,
        sunsetc = nil,
        cloud1 = color(127, 127, 127, 255),
        cloud2 = color(207, 207, 207, 255),
        rearlights = true,
        snow = false,
        fog = false
    },

    {     -- fog
        length = 34,
        field = color(74,74,74,255),
        sky = color(74,74,74,255),
        sunseta = nil,
        sunsetb = nil,
        sunsetc = nil,
        cloud1 = color(255,255,255,255),
        cloud2 = color(167,190,221,255),
        rearlights = true,
        snow = false,
        fog = true
    },

    {     -- night2
        length = 17,
        field = color(0,0,0,255),
        sky = color(74,74,74,255),
        sunseta = nil,
        sunsetb = nil,
        sunsetc = nil,
        cloud1 = color(127,127,127,255),
        cloud2 = color(207,207,207,255),
        rearlights = true,
        snow = false,
        fog = false
    },

    {     -- sunrise
        length = 17,
        field = color(0,0,0,255),
        sky = color(111,111,111,255),
        sunseta = nil,
        sunsetb = nil,
        sunsetc = nil,
        cloud1 = color(159, 159, 159, 255),
        cloud2 = color(200, 200, 200, 255),
        rearlights = false,
        snow = false,
        fog = false
    }
}

numModes = table.maxn(modes)
