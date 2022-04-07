Enemy = Class{}


function Enemy:init(player)

    self.player = player
    self.x = self.player.x
    self.y = self.player.y
    self.dx = 0
    self.dy = 0
    
    self.width = 18
    self.height = 15

    self.xOffset = 9
    self.yOffset = 7.5

    self.speed = 200
    self.jump = 400

    self.texture = love.graphics.newImage('graphics/32x32-bat-sprite.png')
    self.frames = generateQuads(self.texture, 32, 32)

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

    self.lives = 5

end

function Enemy:death()
    self.x = map.tileWidth * 7
    self.y = map.tileHeight * 38
    self.lives = self.lives - 1
end

function Enemy:update(dt)
    self.animation:update(dt)
    self.currentFrame = self.animation:getCurrentFrame()
    self.x = self.player.x
    self.y = self.player.y

end

function Enemy:render()
    local scaleX


    if self.direction == 'right' then
        scaleX = -1
    else
        scaleX = 1
    end


    love.graphics.draw(self.texture, self.currentFrame, math.floor(VIRTUAL_WIDTH - self.player.x),
        math.floor(self.player.y), 0, scaleX, 1, self.xOffset, self.yOffset)
end


