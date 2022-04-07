Player = Class {}

local MOVE_SPEED = 80

function Player:init(map)
    self.width = 16
    self.height = 20
    
    self.x = map.tileWidth * 10
    self.y = map.tileHeight * (map.mapHeight / 2 - 1) - self.height

    self.texture = love.graphics.newImage('graphics/blue_alien.png')
    self.frames = generateQuads(self.texture, 16, 20)
end

function Player:update(dt)
    -- if love.keyboard.isDown('w') or love.keyboard.isDown('up') then
        -- self.camY = math.max(0, self.camY - SCROLL_SPEED * dt)
    if love.keyboard.isDown('a') or love.keyboard.isDown('left') then
        self.x = self.x - MOVE_SPEED * dt
    -- elseif love.keyboard.isDown('s') or love.keyboard.isDown('down') then
        -- self.camY = math.min(self.mapHeightPixels - VIRTUAL_HEIGHT, self.camY + SCROLL_SPEED * dt)
    elseif love.keyboard.isDown('d') or love.keyboard.isDown('right') then
        self.x = self.x + MOVE_SPEED * dt
    end
end

function Player:render()
    love.graphics.draw(self.texture, self.frames[1], self.x, self.y)

end

