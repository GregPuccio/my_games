Player = Class {}

require 'Animation'

local MOVE_SPEED = 80
local JUMP_VELOCITY = 400
local GRAVITY = 40

function Player:init(map)
    self.width = 16
    self.height = 20
    
    self.x = map.tileWidth * 10
    self.y = map.tileHeight * (map.mapHeight / 2 - 1) - self.height
    self.dx = 0
    self.dy = 0

    self.texture = love.graphics.newImage('graphics/blue_alien.png')
    self.frames = generateQuads(self.texture, 16, 20)
    self.map = map

    self.state = 'idle'
    self.direction = 'right'

    self.animations = {
        ['idle'] = Animation {
            texture = self.texture,
            frames = {
                self.frames[1]
            },
            interval = 1
        },
        ['walking'] = Animation {
            texture = self.texture,
            frames = {
                self.frames[9], self.frames[10], self.frames[11]
            },
            interval = 0.15
        },
        ['jumping'] = Animation {
            texture = self.texture,
            frames = {
                self.frames[3]
            },
            interval = 1
        }
    }

    self.animation = self.animations['idle']

    self.behaviors = {
        ['idle'] = function(dt)
            if love.keyboard.wasPressed('space') or love.keyboard.wasPressed('up') then
                self.dy = -JUMP_VELOCITY
                self.state = 'jumping'
                self.animation = self.animations['jumping']
            elseif love.keyboard.isDown('a') or love.keyboard.isDown('left') then
                self.dx = -MOVE_SPEED
                self.animation = self.animations['walking']
                self.direction = 'left'
            elseif love.keyboard.isDown('d') or love.keyboard.isDown('right') then
                self.dx = MOVE_SPEED
                self.animation = self.animations['walking']
                self.direction = 'right'
            else
                self.animation = self.animations['idle']
                self.dx = 0
            end
        end,
        ['walking'] = function(dt)
            if love.keyboard.wasPressed('space') or love.keyboard.wasPressed('up') then
                self.dy = -JUMP_VELOCITY
                self.state = 'jumping'
                self.animation = self.animations['jumping']
            elseif love.keyboard.isDown('a') or love.keyboard.isDown('left') then
                self.dx = -MOVE_SPEED
                self.animation = self.animations['walking']
                self.direction = 'left'
            elseif love.keyboard.isDown('d') or love.keyboard.isDown('right') then
                self.dx = MOVE_SPEED
                self.animation = self.animations['walking']
                self.direction = 'right'
            else
                self.animation = self.animations['idle']
                self.dx = 0
            end
        end,
        ['jumping'] = function(dt)
            if love.keyboard.isDown('a') or love.keyboard.isDown('left') then
                self.dx = -MOVE_SPEED
                self.animation = self.animations['jumping']
                self.direction = 'left'
            elseif love.keyboard.isDown('d') or love.keyboard.isDown('right') then
                self.dx = MOVE_SPEED
                self.animation = self.animations['jumping']
                self.direction = 'right'
            else
                self.animation = self.animations['idle']
            end

            self.dy = self.dy + GRAVITY
            if self.y >= map.tileHeight * (map.mapHeight / 2 - 1) - self.height then
                self.y = map.tileHeight * (map.mapHeight / 2 - 1) - self.height
                self.dy = 0
                self.state = 'idle'
                self.animation = self.animations[self.state]
            end
        end
    }
end

function Player:update(dt)
    self.behaviors[self.state](dt)
    self.animation:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt

    if self.dy < 0 then
        if self.map:tileAt(self.x, self.y) ~= TILE_EMPTY or
            self.map:tileAt(self.x + self.width - 1, self.y) ~= TILE_EMPTY then
            self.dy = 0
            
            if self.map:tileAt(self.x, self.y) == JUMP_BLOCK then
                self.map:setTile(math.floor(self.x / self.map.tileWidth) + 1,
                    math.floor(self.y /self.map.tileHeight) + 1, JUMP_BLOCK_HIT)
            end
            if self.map:tileAt(self.x + self.width - 1, self.y) == JUMP_BLOCK then
                self.map:setTile(math.floor((self.x + self.width -1) / self.map.tileWidth) + 1,
                    math.floor(self.y /self.map.tileHeight) + 1, JUMP_BLOCK_HIT)
            end
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

    love.graphics.draw(self.texture, self.animation:getCurrentFrame(),
        math.floor(self.x), math.floor(self.y),
        0, scaleX, 1,
        self.width / 2, 0)

end

