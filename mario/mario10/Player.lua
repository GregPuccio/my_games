Player = Class {}

require 'Animation'

local MOVE_SPEED = 120
local JUMP_VELOCITY = 200

function Player:init(map)
    self.width = 16
    self.height = 20
    
    self.x = map.tileWidth * 4
    self.y = map.tileHeight * (map.mapHeight / 2 - 1) - self.height
    self.dx = 0
    self.dy = 0

    self.sounds = {
        ['jump'] = love.audio.newSource('sounds/jump.wav', 'static'),
        ['hit'] = love.audio.newSource('sounds/hit.wav', 'static'),
        ['coin'] = love.audio.newSource('sounds/coin.wav', 'static')
    }


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
    self.currentFrame = self.animation:getCurrentFrame()
        self.behaviors = {
        ['idle'] = function(dt)
            if love.keyboard.wasPressed('space') or love.keyboard.wasPressed('up') then
                self.dy = -JUMP_VELOCITY
                self.state = 'jumping'
                self.animation = self.animations['jumping']
                self.sounds['jump']:play()
            elseif love.keyboard.isDown('a') or love.keyboard.isDown('left') then
                self.dx = -MOVE_SPEED
                self.direction = 'left'
                self.state = 'walking'
                self.animations['walking']:restart()
                self.animation = self.animations['walking']
            elseif love.keyboard.isDown('d') or love.keyboard.isDown('right') then
                self.dx = MOVE_SPEED
                self.direction = 'right'
                self.state = 'walking'
                self.animations['walking']:restart()
                self.animation = self.animations['walking']
            else
                self.dx = 0
            end
        end,
        ['walking'] = function(dt)
            if love.keyboard.wasPressed('space') or love.keyboard.wasPressed('up') then
                self.dy = -JUMP_VELOCITY
                self.state = 'jumping'
                self.animation = self.animations['jumping']
                self.sounds['jump']:play()
            elseif love.keyboard.isDown('a') or love.keyboard.isDown('left') then
                self.dx = -MOVE_SPEED
                self.direction = 'left'
            elseif love.keyboard.isDown('d') or love.keyboard.isDown('right') then
                self.dx = MOVE_SPEED
                self.direction = 'right'
            else
                self.state = 'idle'
                self.animation = self.animations['idle']
                self.dx = 0
            end

            self:checkRightCollision()
            self:checkLeftCollision()

            if not self.map:collides(self.map:tileAt(self.x - 7, self.y + self.height)) and
                not self.map:collides(self.map:tileAt(self.x + self.width - 7, self.y + self.height)) then
                
                self.state = 'jumping'
                self.animation = self.animations['jumping']
            end
        end,
        ['jumping'] = function(dt)
            if self.y > 300 then
                self:death()
            end
            if love.keyboard.isDown('a') or love.keyboard.isDown('left') then
                self.dx = -MOVE_SPEED
                self.direction = 'left'
            elseif love.keyboard.isDown('d') or love.keyboard.isDown('right') then
                self.dx = MOVE_SPEED
                self.direction = 'right'
            else
                self.dx = 0
            end

            self.dy = self.dy + self.map.gravity

            if self.map:collides(self.map:tileAt(self.x - 7, self.y + self.height)) or
                self.map:collides(self.map:tileAt(self.x + self.width - 7, self.y + self.height)) then
                
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

lives = 5
function Player:death()
    self.x = map.tileWidth * 4
    self.y = map.tileHeight * (map.mapHeight / 2 - 1) - self.height
    self.dx = 0
    self.dy = 0
    lives = lives - 1
end


function Player:livesLeft()
    return lives
end
coin = 0
function Player:update(dt)
    if gameState == 'play' then
        self.behaviors[self.state](dt)
    else
        self.dx = 0
        self.dy = 0
    end
    self.animation:update(dt)
    self.currentFrame = self.animation:getCurrentFrame()
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt

    if self.dy < 0 then
        if self.map:tileAt(self.x - 7, self.y).id == JUMP_BLOCK or 
            self.map:tileAt(self.x - 7, self.y).id == JUMP_BLOCK_HIT or
            self.map:tileAt(self.x + self.width - 7, self.y).id == JUMP_BLOCK or 
            self.map:tileAt(self.x + self.width - 7, self.y).id == JUMP_BLOCK_HIT then
            self.dy = 0

            if self.map:tileAt(self.x - 7, self.y).id == JUMP_BLOCK then
                self.map:setTile(math.floor((self.x - 7) / self.map.tileWidth) + 1,
                    math.floor(self.y / self.map.tileHeight) + 1, JUMP_BLOCK_HIT)
                self.sounds['coin']:play()
                coin = coin + 1
            elseif self.map:tileAt(self.x - 7, self.y).id == JUMP_BLOCK_HIT then
                self.map:setTile(math.floor((self.x - 7) / self.map.tileWidth) + 1,
                    math.floor(self.y / self.map.tileHeight) + 1, TILE_EMPTY)
                self.sounds['hit']:play()
            end
            if self.map:tileAt(self.x + self.width - 7, self.y).id == JUMP_BLOCK then
                self.map:setTile(math.floor((self.x + self.width - 7) / self.map.tileWidth) + 1,
                    math.floor(self.y / self.map.tileHeight) + 1, JUMP_BLOCK_HIT)
                self.sounds['coin']:play()
                coin = coin + 1
            elseif self.map:tileAt(self.x + self.width - 7, self.y).id == JUMP_BLOCK_HIT then
                self.map:setTile(math.floor((self.x + self.width - 7) / self.map.tileWidth) + 1,
                    math.floor(self.y / self.map.tileHeight) + 1, TILE_EMPTY)
                self.sounds['hit']:play()
            end
        end
    end
    self.y = self.y + self.dy * dt
end

function Player:checkLeftCollision()
    if self.dx < 0 then
        if self.map:collides(self.map:tileAt(self.x - 17, self.y)) or
            self.map:collides(self.map:tileAt(self.x - 17, self.y + self.height - 1)) then
            
            self.dx = 0
            self.x = math.floor(self.map:tileAt(self.x - 1, self.y).x * self.map.tileWidth)
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

function Player:getCoins()
    return coin
end

function Player:render()
    
    local scaleX

    if self.direction == 'right' then
        scaleX = 1
    else  
        scaleX = -1
    end

    love.graphics.draw(self.texture, self.animation:getCurrentFrame(),
        math.floor(self.x), math.floor(self.y), 0, scaleX, 1, self.width / 2, 0)

end

