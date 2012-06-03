--[[    ------------------------------------------------------------
                           Cloud.lua
--]]    ------------------------------------------------------------
Cloud = class()

function Cloud:init(x,y)
    -- you can accept and set parameters here
    self.shapes = {}
    self.position = vec2(x,y)

    -- Generate random cloud
    numCircles = 4
    spacing = 20

    for i = 1,numCircles do
        x = i * spacing - ((numCircles/2)*spacing)
        y = (random() - 0.5) * 20
        rad = spacing*random()+spacing
        table.insert(self.shapes, {x=x, y=y, r=rad})
    end

    self.width = numCircles * spacing + spacing
end

function Cloud:moveX(dx)
    self.position.x = self.position.x + dx
end

function Cloud:draw(c1,c2)
    pushStyle()
    pushMatrix()

    translate(self.position.x, self.position.y)

    -- noStroke()
    strokeWidth(-1)
    fill(c2)

    for i,s in ipairs(self.shapes) do
        ellipse(s.x, s.y - 5, s.r)
    end

    fill(c1)

    for i,s in ipairs(self.shapes) do
        ellipse(s.x, s.y + 5, s.r)
    end

    popMatrix()
    popStyle()
end
