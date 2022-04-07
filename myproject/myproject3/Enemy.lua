Enemy = Class{}

require 'Player'


function Enemy:init(player)
    self.player = player
    bossLives = 2 + playerLevel / 10

    self.x = 325
    self.y = 175
    self.dx = 0
    self.dy = 0
    
    self.width = 16
    self.height = 16

    self.xOffset = self.width / 2
    self.yOffset = self.height / 2

    self.speed = 50

    self.texture = love.graphics.newImage('graphics/32x32-bat-sprite.png')
    self.frames = generateQuads(self.texture, 32, 32)

    self.deathsound = love.audio.newSource('sounds/kill2.wav', 'static')
    self.playerdeathsound = love.audio.newSource('sounds/death.wav', 'static')

    self.state = 'idle'

    self.direction = 'right'

    self.animations = {
        ['idle'] = Animation({
            texture = self.texture,
            frames = {
                self.frames[2],
                self.frames[3],
                self.frames[4]
            },
            inverval = 1
        })
    }

    self.animation = self.animations['idle']

    self.currentFrame = self.animation:getCurrentFrame()

end

function Enemy:getLives()
    return bossLives
end

function Enemy:update(dt)
    self.animation:update(dt)
    self.currentFrame = self.animation:getCurrentFrame()
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
    if gameState == 'fight' then
        if self.x < self.player.x then
            self.direction = 'right'
            self.dx = self.speed + self.speed * playerLevel / 20
        elseif self.x > self.player.x then
            self.direction = 'left'
            self.dx = -self.speed - self.speed * playerLevel /20
        else
            self.dx = 0
        end

        if self.y < self.player.y then
            self.dy = self.speed * playerLevel / 10
        elseif self.y > self.player.y then
            self.dy = -self.speed * playerLevel /10
        else
            self.dy = 0
        end

        if self.direction == 'right' and self.x >= self.player.x and self.y + 8 > self.player.y and self.y + 8 < self.player.y + self.player.height then
            self.player:death()
            self.playerdeathsound:play()
            self.x = 325
            self.y = 175
            self.dx = 0
            self.dy = 0
        elseif self.direction == 'left' and self.x <= self.player.x + self.player.width and self.y + 8 > self.player.y and self.y + 8 < self.player.y + self.player.height then
            self.player:death()
            self.playerdeathsound:play()
            self.x = 325
            self.y = 175
            self.dx = 0
            self.dy = 0
        elseif self.x <= self.player.x + self.player.width and self.x + self.width >= self.player.x and self.y <= self.player.y + self.player.height + 10 and self.y >= self.player.y then
            if self:getLives() > 1 then
                self:death()
                self.deathsound:play()
                self.player:reset()
                self.x = 325
                self.y = 175
                self.dx = 0
                self.dy = 0
            else
                gameState = 'climb'
                self.player:nextLevel()                
            end
        end
    end

end

function Enemy:death()
    self.x = 325
    self.y = 175
    self.dx = 0
    self.dy = 0
    bossLives = bossLives - 1
end

function Enemy:render()
    local scaleX


    if self.direction == 'right' then
        scaleX = -1
    else
        scaleX = 1
    end
    
    love.graphics.draw(self.texture, self.currentFrame, self.x,
        self.y, 0, 1, 1, self.xOffset, self.yOffset)
end