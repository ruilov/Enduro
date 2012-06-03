--[[    ------------------------------------------------------------
                           Car.lua
--]]    ------------------------------------------------------------

dayCarColors = {
    color(255, 0, 0, 255),
    color(0, 35, 255, 255),
    color(11, 255, 0, 255),
    color(255, 245, 0, 255)
}

nightCarColors = {
    color(255, 0, 0, 255),
    color(255, 0, 188, 255),
    color(255, 0, 188, 255),
    color(255, 0, 0, 255)
}

Car = class()

function Car:init(x,y,color)
    self.x = x    -- between -1 and 1
    self.y = y    -- from 0 to trackLength in meters
    self.color = color
    self.speed = regularSpeed
    self.real = true  -- unreal cars help with spawning
    self.tireState = true  -- for tire animation
    self.tireStateHelper = 0
end

function Car:updateTireState()
    self.tireStateHelper = self.tireStateHelper + self.speed / 60
    if self.tireStateHelper > 5 then
        self.tireStateHelper = 0
        self.tireState = not self.tireState
    end
end

function Car:draw(track,day)
    -- coords of the track at this y
    leftX = track:leftAt(self.y)
    rightX = track:rightAt(self.y)

    -- my coord at this y
    x = ((1+self.x)*rightX + (1-self.x)*leftX)/2

    s = metersToPixels(self.y) -- implemented in the track class
    self:drawHelper(x,s,1-s/trackHeight,self.color,self.tireState,day)
end

-- x relative to middle of the screen in pixels, y relative to the bottom of the track
-- scale relative to a car at the bottom of the screen
-- tireState is true or false, for animation
function Car:drawHelper(x,y,s,colorIdx,tireState,day)
    pushMatrix()
    pushStyle()
    resetMatrix()
    translate(WIDTH/2+x,bottomY+y)
    scale(trackWidth*s/90,trackHeight*s/108)

    if colorIdx == 0 then -- hack for my car
        thisColor = color(190,190,190,255)
    elseif modes[day.mode].rearlights then
        thisColor = nightCarColors[colorIdx]
    else
        thisColor = dayCarColors[colorIdx]
    end

    fill(thisColor)
    stroke(thisColor)
    strokeWidth(2)

    if not modes[day.mode].rearlights or colorIdx == 0 then
        -- regular car
        rect(-4,1,8,7) -- body horizontal
        rect(-2,0,4,12) -- body vertical
        rect(-6,8,12,3) -- top wing
        rect(-6,8,3,4) -- left wing
        rect(3,8,3,4) -- right wing
        for i = 0,7 do
            if tireState == (i%2==0) then startX = -8 else startX = -6 end
            rect(startX,i,3,2)
            rect(startX+11,i,3,2)
        end
    else
        -- rear lights
        rect(2,0,5,4)
        rect(-6,0,5,4)
    end
    popMatrix()
    popStyle()
end

function spawnNewCars()
    if maxPosition < 65 then -- space the cars apart
        rand1 = random()
        if rand1 < 0.7 then
            -- spawn one car
            x = (math.floor(3*random())-1)/2
            newCar = Car(x,.9*trackLength,randColor())
            table.insert(cars,newCar)
        else
            newCar = Car(0,.9*trackLength,randColor())
            newCar.real = false
            table.insert(cars,newCar)
        end
    end
end

-- used above
function randColor()
    ncolors = table.maxn(dayCarColors)
    idx = math.ceil(random()*ncolors)
    return(idx)
end
