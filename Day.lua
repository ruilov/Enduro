--[[    ------------------------------------------------------------
                           Day.lua
--]]    ------------------------------------------------------------

Day = class()

function Day:init()
    self.mode = 1         -- day, night, snow, etc
    self.lastModeT = 0    -- last time we changed modes
    self.clouds = {}
    self.won = false      -- whether we passed all cars for this day
    self.fogEnd = .5      -- for fog animation
    self:makeClouds()
end

function Day:makeClouds()
    for i = 0, 5 do
        minY = horizonY + HEIGHT / 15
        maxY = HEIGHT - HEIGHT / 20
        y = minY + random()*(maxY-minY)
        cloud = Cloud(random()*WIDTH,y)
        table.insert(self.clouds,cloud)
    end
end

function Day:inSnow()
    return(modes[self.mode].snow)
end

-- moves the day mode forward
function Day:updateMode(gameTime)
    if gameTime - self.lastModeT > modes[self.mode].length then -- time to change mode
        self.mode = self.mode%numModes+1
        self.lastModeT = gameTime
        if self.mode == 1 then   -- end of the day
            if carsToPass > 0 then
                print("GAME OVER")
                gameOver = true -- global variable
            else
                carsToPass = carsToPassInit + 30 * days
                maxSpeed = 140 + days*10
                days = days + 1
                self.won = false
            end
        end
    end
end

-- moves the clounds around
function Day:moveX(dx)
    for i,cloud in ipairs(self.clouds) do
        cloud:moveX(dx)
        -- handle a clound disappearing at the edges
        if cloud.position.x < -200 or cloud.position.x > WIDTH + 200 then
            table.remove(self.clouds,i)
            -- make a new one
            minY = horizonY + HEIGHT / 15
            maxY = HEIGHT - HEIGHT / 20
            y = minY + random()*(maxY-minY)
            x = random()*WIDTH/8
            if dx>0 then x = -x else x = x + WIDTH end  -- start it a little of screen
            cloud = Cloud(x,y)
            table.insert(self.clouds,cloud)
        end
    end
end

-- needs track because we need to draw track in between the field and the sky
function Day:draw(track)
    -- green field
    strokeWidth(0)
    fill(modes[self.mode].field)
    rect(-5, bottomY, WIDTH+10, horizonY)

    -- track
    track:draw()

    -- sky
    strokeWidth(0)
    fill(modes[self.mode].sky)
    rect(-5, horizonY, WIDTH+10, HEIGHT)

    -- sunset
    sunsetW = (HEIGHT-horizonY)*.02
    if modes[self.mode].sunseta ~= nil then
        fill(modes[self.mode].sunseta)
        rect(-5,horizonY,WIDTH+10,sunsetW+1)
    end
    if modes[self.mode].sunsetb ~= nil then
        fill(modes[self.mode].sunsetb)
        rect(-5,horizonY+sunsetW,WIDTH+10,sunsetW+1)
    end
    if modes[self.mode].sunsetc ~= nil then
        fill(modes[self.mode].sunsetc)
        rect(-5,horizonY+sunsetW*2,WIDTH+10,sunsetW+1)
    end

    -- clouds
    for i,cloud in ipairs(self.clouds) do
        cloud:draw(modes[self.mode].cloud1,modes[self.mode].cloud2)
    end
end

function Day:updateFogEnd(speed)
    self.fogEnd = self.fogEnd - speed/20000
    if self.fogEnd < .5 then self.fogEnd = .6 end
end

function Day:drawFog()
    strokeWidth(0)
    if modes[self.mode].fog then
        fill(74,74,74,255)
        rect(-5,bottomY+(horizonY-bottomY)*self.fogEnd,WIDTH+10,HEIGHT)
    end
end
