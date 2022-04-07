Enemy = Class{}


function Enemy:init(map)

    self.map = map

    self.x = 0
    self.y = 0
    self.dx = 0
    self.dy = 0
    
    self.width = 18
    self.height = 15

    self.xOffset = 9
    self.yOffset = 7.5

    self.speed = 200

    self.texture = love.graphics.newImage('graphics/32x32-bat-sprite.png')
    self.frames = generateQuads(self.texture, 32, 32)

    self.state = 'idle'

    self.direction = 'right'

    self.x = self.map.tileWidth * 7
    self.y = self.map.mapHeightPixels - self.height * 2

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

    self.behaviors = {
        ['idle'] = function(dt)
            if love.keyboard.isDown('left') or love.keyboard.isDown('a') then
                self.direction = 'left'
                self.dx = -self.speed
            elseif love.keyboard.isDown('right') or love.keyboard.isDown('d') then
                self.direction = 'right'
                self.dx = self.speed
            else
                self.dx = 0
            end
        end
    }

    self.lives = 5

end

function Enemy:death()
    self.x = map.tileWidth * 7
    self.y = map.tileHeight * 38
    self.lives = self.lives - 1
end

function Enemy:update(dt)
    self.behaviors[self.state](dt)
    self.animation:update(dt)
    self.currentFrame = self.animation:getCurrentFrame()
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt

end

function Enemy:render()
    local scaleX


    if self.direction == 'right' then
        scaleX = -1
    else
        scaleX = 1
    end


    love.graphics.draw(self.texture, self.currentFrame, math.floor(self.x + self.xOffset),
        math.floor(self.y + self.yOffset), 0, scaleX, 1, self.xOffset, self.yOffset)
end


