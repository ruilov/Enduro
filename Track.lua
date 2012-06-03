--[[    ------------------------------------------------------------
                           Track.lua

       Represents the track. Knows which way the horizon is pointing,
       and how to draw tracks (both straight and curved)

       Note on coordinates in this class: x is in pixels relative
       to the middle of the screen and y is in pixels in absolute
       terms (from the bottom of the screen)
--]]    ------------------------------------------------------------

Track = class()

DIRTH = 2 -- threshold at which tracks become straight, a couple of pixels from Width/2

function Track:init()
    self.horizonX = 0                     -- which it's pointing now
    self.horizonTargetX = self.horizonX   -- where eventually it will point

    -- the coordinates of the track at the bottom
    bottomXR = trackWidth/2
    bottomXL = -bottomXR
    self.bottomL = vec2(bottomXL,bottomY)
    self.bottomR = vec2(bottomXR,bottomY)

    -- these are calculated based on horizonX  when updated
    self.horizonL = nil    -- coords of the track at the horizon
    self.horizonR = nil
    self.centerL = nil     -- center of curvature of the tracks
    self.centerR = nil
    self.rL = 0            -- radius of curvature of the tracks
    self.rR = 0
    
    self:setHorizon(self.horizonTargetX)
end

-- UPDATING FUNCTIONS

-- call this function to change the targetX to a new random position
function Track:newTargetX()
    self.horizonTargetX = math.floor(3*random()-1) * trackWidth/2
end

-- call this function to move the horizonX closer to the target
function Track:moveToTargetX()
    dH = math.min(10,math.abs(self.horizonX-self.horizonTargetX))

    if self.horizonTargetX < self.horizonX then
        self:setHorizon(self.horizonX-dH)
    elseif self.horizonTargetX > self.horizonX then
        self:setHorizon(self.horizonX+dH)
    end
end

-- x in pixels relative to the middle of the screen. negative is to the left
function Track:setHorizon(x)
    self.horizonX = x

    if self.horizonX < -DIRTH then
        -- we're turning left

        -- left track
        self.rL = .275 * trackWidth^2 / math.abs(self.horizonX)
        self.horizonL = vec2(self.horizonX,horizonY)
        self.centerL = circleCenter(self.bottomL,self.horizonL,self.rL,1,-1)

        -- right track
        self.rR = 8 * self.rL
        adj = -self.horizonX * WIDTH/trackWidth*.009 -- due to numerical error?
        self.horizonR = vec2(self.horizonX,horizonY+adj)
        self.centerR = circleCenter(self.bottomR,self.horizonR,self.rR,-1,-1)
    elseif self.horizonX > DIRTH then
        -- we're turning right

        -- right track
        self.rR = .275 * trackWidth^2 / math.abs(self.horizonX)
        self.horizonR = vec2(self.horizonX,horizonY)
        self.centerR = circleCenter(self.bottomR,self.horizonR,self.rR,1,1)

        -- left track
        self.rL = 8 * self.rR
        adj = self.horizonX * WIDTH/trackWidth*.009  -- due to numerical error?
        self.horizonL = vec2(self.horizonX,horizonY+adj)
        self.centerL = circleCenter(self.bottomL,self.horizonL,self.rL,-1,1)
    end
end

-- calculates the center of a circle that passes through bottom and horizon
-- both of which are vec2s and of radius r, returns a vec2
-- ugly math ahead
function circleCenter(bottom,horizon,r,mult1,mult2)
    m = -(bottom.x-horizon.x)/(bottom.y-horizon.y)
    b = (bottom.y+horizon.y-m*(bottom.x+horizon.x))/2
    c1 = (1+m^2)
    c2 = -(bottom.x+horizon.x)*c1
    c3 = horizon.x^2 + (b-horizon.y)^2 - r^2
    centerX = (-c2 + mult2 * math.sqrt(c2^2-4*c1*c3))/(2*c1)
    centerY = mult1*math.sqrt(r^2-(centerX-bottom.x)^2)+bottom.y
    return(vec2(centerX,centerY))
end

-- GETTER FUNCTIONS

-- the centrifugal force on my car and clouds
function Track:centrifugal()
    return (-self.horizonX / (trackWidth/2))
end

-- x coord of left track in pixels relative to Width/2
-- y in metters
function Track:leftAt(y)
    return(self:atHelper(y,self.rL,self.centerL,-1))
end

-- x coord of right track in pixels relative to Width/2
-- y in metters
function Track:rightAt(y)
    return(self:atHelper(y,self.rR,self.centerR,1))
end

function Track:atHelper(y,r,center,mult)
    s = metersToPixels(y)
    ys = s + bottomY
    
    if self.horizonX < -DIRTH then
        -- turning left
        xs = math.sqrt(r^2 - (ys - center.y)^2) + center.x
        xs = xs - (9+mult*5)*s/trackHeight  -- numerical adjustment
    elseif self.horizonX > DIRTH then
        -- turning right
        xs = -math.sqrt(r^2 - (ys - center.y)^2) + center.x
        xs = xs + (9-mult*5)*s/trackHeight  -- numerical adjustment
    else
        -- going straight
        xs = mult*(1-s/trackHeight) * trackWidth/2
    end
    return(xs)
end

-- tracks y in meter (0,trackLength) and returns y in pixels relative to the bottom
-- note that it's not a linear relationship due to perpective
function metersToPixels(y)
    s=y/trackLength
    s = (1-s)^2.5
    return((1-s)*trackHeight)
end

function Track:draw()
    pushStyle()
    pushMatrix()
    resetMatrix()

    lineCapMode(PROJECT)
    translate(WIDTH/2,0)
    stroke(183, 183, 183, 255)

    if math.abs(self.horizonX) <= DIRTH then
        -- we're going straight
        strokeWidth(5)
        line(self.bottomL.x,self.bottomL.y,self.horizonX,horizonY)
        line(self.bottomR.x,self.bottomR.y,self.horizonX,horizonY)
    else
        -- we're turning
        strokeWidth(3)
        noFill()
        ellipse(self.centerL.x,self.centerL.y,self.rL,self.rL)
        ellipse(self.centerR.x,self.centerR.y,self.rR,self.rR)
    end

    popStyle()
    popMatrix()
end
