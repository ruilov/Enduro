--[[    ------------------------------------------------------------
                           Main.lua
--]]    ------------------------------------------------------------

-- global screen size constants
bottomY = HEIGHT *.21
trackWidth = WIDTH * .9 -- width of the track at the bottom
horizonY = trackWidth * .55 + bottomY
trackHeight = horizonY - bottomY
trackLength = 100  -- in meters

-- main objects
myCar = nil
cars = {}
day = nil
track = nil

-- various global variables
speed = 0                 -- for showing to the user
location = 0              -- my location
maxPosition = -1000       -- the location relative to me where the front-most car is
lastCollisionT = -1000    -- last time i collided, for the penalty
gameTime = 0              -- for reporting to the user
startTime = 0             -- the time at which the game started
accAngle = 0              -- gravity.z threshold for accelerating vs breaking
days = 1                  -- which day we're on
carsToPassInit = 150          -- on day 1 we need this many
carsToPass = carsToPassInit   -- how many cars to advance to the next day
gameOver = false
gameStarted = false           -- whether the user has started the game
gamePaused = false
maxSpeed = 150
regularSpeed = 85

function setup()
    track = Track()
    day = Day()
    myCar = Car(0,0,0)
    myCar.speed = 120
    
    watch("carsToPass")
    watch("days")
    watch("speed")
    watch("location")
    
    print("Instructions:")
    print("Angle fwd to accelerate")
    print("Angle back to break")
    print("Keep still to maintain speed")
    print("Arrows to steer")
    print("Touch the screen to start")
end

function draw()
    rectMode(CORNER)
    ellipseMode(RADIUS)
    speed = myCar.speed
    
    
    ------------- UPDATE GAME STATE ----------------
    if not gameOver then
        if not gameStarted or gamePaused then
            stoppedUserInputs()
        else
            accelerating = runningUserInputs()     -- start, left, right, brake, etc
            
            -- move track around
            turnTrack(gameTime,track)
                
            -- move the day forward in time
            day:updateMode(gameTime)
        
            if gameStarted then
                gameTime = ElapsedTime - startTime
                location = location + DeltaTime*myCar.speed/100
                spawnNewCars()
                myCar:updateTireState()
                day:updateFogEnd(myCar.speed)
            end
        
            -- if we're turning then apply the centrifugal force
            centrifugal = track:centrifugal()
            centrifugal = centrifugal * myCar.speed / 150
            myCar.x = myCar.x + centrifugal/100
            day:moveX(centrifugal*7)
        
            collided = checkForCollisions()
            moveCars()
        end
    end

    --------------- DRAW ---------------
    -- field, tracks, sky, controls, etc
    drawBackground()
    
    --draw all cars
    myCar:draw(track,day)
    for i,c in ipairs(cars) do
        if c.y > 0 and c.y <= .9*trackLength and c.real then
            c:draw(track,day)
        end
    end
    
    day:drawFog()    -- has to be drawn last
    
    drawPauseButton()
    drawUserFeedback(accelerating,collided)  -- userfedback at the bottom of the screen
end

function moveCars()
    maxPosition = -1000
    for i,c in ipairs(cars) do
        change = -DeltaTime*(myCar.speed-c.speed)/1.3
        beforeY = c.y
        c.y = c.y + change

        -- count carsPassed
        if c.real then
            if c.y<0 and beforeY>0 and not day.won then carsToPass = carsToPass - 1 end
            if c.y>0 and beforeY<0 and not day.won then carsToPass = carsToPass + 1 end
        end

        if carsToPass == 0 and not day.won then
            day.won = true
            print("Achievement unlocked: Day", days)
        end

        -- remove cars
        -- avoid collisions from the back by removing cars
        if c.y>0 and beforeY<0 and collidesWithMyCar(c) then
            table.remove(cars,i)
        -- remove cars that are too far
        elseif c.y < -5 * trackLength or c.y > 2 * trackLength then
            table.remove(cars,i)
        else c:updateTireState() end

        maxPosition = math.max(maxPosition,c.y)
    end
end

-- user inputs while the game is stopped
function stoppedUserInputs()
    if (CurrentTouch.state == BEGAN or CurrentTouch.state == MOVING ) then
        if not gameStarted then
            -- start game
            gameStarted = true
            startTime = ElapsedTime
            accAngle = Gravity.z + .002
        elseif gamePaused and pausePressed(CurrentTouch.x,CurrentTouch.y) then
            gamePaused = false
            accAngle = Gravity.z + .002
        end
    end
end

-- user inputs while the game is running
function runningUserInputs()
    -- handle steering
    if (CurrentTouch.state == BEGAN or CurrentTouch.state == MOVING ) then
        if CurrentTouch.y < bottomY then
            dx = .05
            if day:inSnow() then dx = dx / 2 end
            if CurrentTouch.x > .64 * WIDTH and CurrentTouch.x < .84 *WIDTH then
                -- go left
                myCar.x = myCar.x - dx
            elseif CurrentTouch.x > .84 * WIDTH then
                -- go right
                myCar.x = myCar.x + dx
            end
        end
        
        if pausePressed(CurrentTouch.x,CurrentTouch.y) then gamePaused = true end
    end

    -- handle acceleration
    dz = Gravity.z - accAngle
    if dz < -.03 then
        myCar.speed = math.min(maxSpeed,myCar.speed+1)
        return(1)
    elseif dz > .08 then
        myCar.speed = math.max(0,myCar.speed-3)
        return(2)
    end
    return(3)
end

lastPauseT = 0
function pausePressed(x,y)
    if ElapsedTime - lastPauseT < .1 then return(false) end
    if x > WIDTH*.9 and y>HEIGHT*.9 then
        lastPauseT = ElapsedTime
        return(true)
    else return(false) end
end

-- turns the track left and right every now and then
lastTurnT = 0
function turnTrack(gameTime,track)
    track:moveToTargetX()
    if gameTime - lastTurnT > 5 then
        track:newTargetX()
        lastTurnT = gameTime
    end
end

function checkForCollisions()
    -- with the walls
    maxX = .75
    if myCar.x > maxX or myCar.x < -maxX then
        if myCar.x < 0 then
            myCar.x = -maxX/1.2
        else
            myCar.x = maxX/1.2
        end
        myCar.speed = math.max(0,myCar.speed-maxSpeed/5)
    end

    -- with other cars
    for i, car in ipairs(cars) do
        if collidesWithMyCar(car) then
            lastCollisionT = ElapsedTime
            break
        end
    end

    -- penalty for colliding for .5 seconds
    if ElapsedTime - lastCollisionT < 1 then
        myCar.speed = regularSpeed / 2
        return(true)
    else
        return(false)
    end
end

-- check if this car collides with my car
function collidesWithMyCar(car)
    if not car.real then return(false) end
    dx = math.abs(myCar.x - car.x)
    dy = car.y - myCar.y
    return(dx < 0.35 and dy > 0 and dy < 4)  -- based on car dimensions
end

function drawBackground()
    background(0, 0, 0, 255)

    -- field, track, sky, clouds
    day:draw(track)

    -- botton
    fill(0, 0, 0, 255)
    rect(-5,0,WIDTH+10,bottomY)

    -- the left/right controls
    fill(255, 255, 255, 255)
    stroke(255, 255, 255, 255)
    drawArrow(vec2(WIDTH*.82,bottomY*.5),180,WIDTH/750)
    drawArrow(vec2(WIDTH*0.86,bottomY*.5),0,WIDTH/750)  
end

function drawArrow(pos,orient,s)
    pushMatrix()
    resetMatrix()
    pushStyle()
    translate(pos.x,pos.y)
    scale(s)
    strokeWidth(13)
    lineCapMode(PROJECT)
    rotate(orient)
    line(0, 0, 70,0)
    line(73, 0, 50, 25)
    line(73, 0,  50, -25)
    popStyle()
    popMatrix()
end

function drawPauseButton()
    pushMatrix()
    translate(WIDTH*.93,HEIGHT*.93)
    lineCapMode(PROJECT)
    stroke(214, 214, 214, 255)
    strokeWidth(10)
    line(0,0,0,20)
    line(12,0,12,20)
    popMatrix()
end

function drawUserFeedback(accelerating,collided)
    if gameStarted and not gameOver then
        if accelerating == 1 then
            -- show green arrow forward
            stroke(0, 255, 0, 255)
            drawArrow(vec2(WIDTH*.1,bottomY*.25),90,WIDTH/750)
        elseif accelerating == 2 then
            -- show red arrow back
            stroke(255,0,0,255)
            drawArrow(vec2(WIDTH*.1,bottomY*.75),270,WIDTH/750)
        end
    end

    if collided then
        strokeWidth(0)
        fill(255, 243, 0, 255)
        ellipse(WIDTH/2,bottomY*.5,bottomY*.25,bottomY*.25)
    end
end

-- why? because I was trying to get around the bug
-- with sounds vs random and in the end I just didn't
-- use sound
function random()
    return(math.random())
end
