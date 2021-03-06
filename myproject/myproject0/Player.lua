Player = Class{}

MOVE_SPEED = 150
JUMP_VELOCITY = 300

function Player:init(map)
    self.x = 0
    self.y = 0
    self.width = 16
    self.height = 16

    self.dy = 0
    self.dx = 0
    self.yOffset = 8
    self.xOffset = 8

    playerLevel = 1

    self.map = map
    self.texture = love.graphics.newImage('graphics/main-character-4.png')
    self.frames = generateQuads(self.texture, 16, 16)

    self.currentFrame = nil

    self.state = 'idle'

    self.direction = 'right'

    self.x = map.tileWidth * 4
    self.y = map.tileHeight * 38

    self.animations = {
        ['idle'] = Animation({
            texture = self.texture,
            frames = {
                self.frames[1]
            },
            inverval = 1
        }),
        ['walking'] = Animation({
            texture = self.texture,
            frames = {
                self.frames[7],
                self.frames[8]
            },
            interval = 0.25
        }),
        ['jumping'] = Animation({
            texture = self.texture,
            frames = {
                self.frames[8]
            },
            interval = 1
        }),
        ['crouching'] = Animation({
            texture = self.texture,
            frames = {
                self.frames[13]
            }
        }),
        interval = 1
    }

    self.animation = self.animations['idle']
    self.currentFrame = self.animation:getCurrentFrame()

    self.behaviors = {
        ['idle'] = function(dt)
            
            if love.keyboard.wasPressed('space') or love.keyboard.wasPressed('up') then
                self.dy = -JUMP_VELOCITY
                self.state = 'jumping'
                self.animation = self.animations['jumping']
            elseif love.keyboard.isDown('left') or love.keyboard.isDown('a') then
                self.direction = 'left'
                self.dx = -MOVE_SPEED
                self.state = 'walking'
                self.animations['walking']:restart()
                self.animation = self.animations['walking']
            elseif love.keyboard.isDown('right') or love.keyboard.isDown('d') then
                self.direction = 'right'
                self.dx = MOVE_SPEED
                self.state = 'walking'
                self.animations['walking']:restart()
                self.animation = self.animations['walking']
            elseif love.keyboard.isDown('down') or love.keyboard.isDown('s') then
                self.dy = JUMP_VELOCITY
                self.state = 'jumping'
                self.animation = self.animations['crouching']
            else
                self.dx = 0
            end
        end,
        ['walking'] = function(dt)
            
            if love.keyboard.wasPressed('space') or love.keyboard.wasPressed('up') then
                self.dy = -JUMP_VELOCITY - 50
                self.state = 'jumping'
                self.animation = self.animations['jumping']
            elseif love.keyboard.isDown('left') or love.keyboard.isDown('a') then
                self.direction = 'left'
                self.dx = -MOVE_SPEED
            elseif love.keyboard.isDown('right') or love.keyboard.isDown('d') then
                self.direction = 'right'
                self.dx = MOVE_SPEED
            elseif love.keyboard.isDown('down') or love.keyboard.isDown('s') then
                self.dy = JUMP_VELOCITY + 50
                self.state = 'jumping'
                self.animation = self.animations['crouching']
            else
                self.dx = 0
                self.state = 'idle'
                self.animation = self.animations['idle']
            end

            self:checkRightCollision()
            self:checkLeftCollision()

            if not self.map:collides(self.map:tileAt(self.x, self.y + self.height)) and
                not self.map:collides(self.map:tileAt(self.x + self.width - 1, self.y + self.height)) then
                
                self.state = 'jumping'
                self.animation = self.animations['jumping']
            end
        end,
        ['jumping'] = function(dt)

            if love.keyboard.isDown('left') or love.keyboard.isDown('a') then
                self.direction = 'left'
                self.dx = -MOVE_SPEED
            elseif love.keyboard.isDown('right')or love.keyboard.isDown('d') then
                self.direction = 'right'
                self.dx = MOVE_SPEED
            elseif love.keyboard.isDown('down') or love.keyboard.isDown('s') then
                self.dy = JUMP_VELOCITY
                self.state = 'jumping'
                self.animation = self.animations['crouching']
            end

            self.dy = self.dy + self.map.gravity

            if self.map:collides(self.map:tileAt(self.x, self.y + self.height)) or
                self.map:collides(self.map:tileAt(self.x + self.width - 1, self.y + self.height)) then
                
                self.dy = 0
                self.state = 'idle'
                self.animation = self.animations['idle']
                self.y = (self.map:tileAt(self.x, self.y + self.height).y - 1) * self.map.tileHeight - self.height
            end

            self:checkRightCollision()
            self:checkLeftCollision()
        end
    }
end


function Player:update(dt)
    self.behaviors[self.state](dt)
    self.animation:update(dt)
    self.currentFrame = self.animation:getCurrentFrame()
    self.x = self.x + self.dx * dt

    self:calculateJumps()

    self.y = self.y + self.dy * dt

end

function Player:calculateJumps()
    if self.dy < 0 then
        if self.map:tileAt(self.x, self.y).id ~= TILE_EMPTY or
            self.map:tileAt(self.x + self.width - 1, self.y).id ~= TILE_EMPTY then

            self.dy = 0
        end
    end
end

function Player:checkLeftCollision()
    if self.dx < 0 then
        if self.map:collides(self.map:tileAt(self.x - 1, self.y)) or
            self.map:collides(self.map:tileAt(self.x - 1, self.y + self.height - 1)) then
            
            self.dx = 0
            self.x = self.map:tileAt(math.floor(self.x - 1), self.y).x * self.map.tileWidth
        end
    end
end

function Player:checkRightCollision()
    if self.dx > 0 then
        if self.map:collides(self.map:tileAt(self.x + self.width, self.y)) or
            self.map:collides(self.map:tileAt(self.x + self.width, self.y + self.height - 1)) then
            
            self.dx = 0
            self.x = (self.map:tileAt(self.x + self.width, self.y).x - 1) * self.map.tileWidth - self.width
        end
    end
end

function Player:render()
    local scaleX

    if self.direction == 'right' then
        scaleX = 1
    else
        scaleX = -1
    end


    love.graphics.draw(self.texture, self.currentFrame, math.floor(self.x + self.xOffset),
        math.floor(self.y + self.yOffset), 0, scaleX, 1, self.xOffset, self.yOffset)
    --[[ love.graphics.draw(self.texture, self.currentFrame,
    math.floor(self.x), math.floor(self.y), 0, scaleX, 1, , 0) ]]
end