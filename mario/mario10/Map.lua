Map = Class{}

TILE_BRICK = 1
TILE_EMPTY = 4

CLOUD_LEFT = 7
CLOUD_RIGHT = 6

BUSH_LEFT = 2
BUSH_RIGHT = 3

MUSHROOM_TOP = 10
MUSHROOM_BOTTOM = 11

JUMP_BLOCK = 5
JUMP_BLOCK_HIT = 9

FLAG_TOP = 8
FLAG_MIDDLE = 12
FLAG_BOTTOM = 16
FLAG_DOWN = 15
FLAG_UP = 13

HEIGHT = 8

local SCROLL_SPEED = 62
h = 1
function Map:init()
    self.spritesheet = love.graphics.newImage('graphics/spritesheet.png')
    self.music = love.audio.newSource('sounds/music.wav', 'static')

    self.tileWidth = 16
    self.tileHeight = 16
    self.mapWidth = 40 + h * 30
    self.mapHeight = 28
    self.tiles = {}

    self.gravity = 12
    self.level = 1
    self.height = HEIGHT

    self.player = Player(self)

    self.camX = 0
    self.camY = -3

    self.tileSprites = generateQuads(self.spritesheet, self.tileWidth, self.tileHeight)

    self.mapWidthPixels = self.mapWidth * self.tileWidth
    self.mapHeightPixels = self.mapHeight * self.tileHeight

    for y = 1, self.mapHeight do
        for x = 1, self.mapWidth do
            self:setTile(x, y, TILE_EMPTY)
        end
    end

    local x = 1
    local r = 0
    local l = 0
    while x < self.mapWidth do
        if x > 4 then
            if math.random(6) == 1 then
                local cloudStart = math.random(self.mapHeight / 2 - 6) 

                self:setTile(x + 1, cloudStart, CLOUD_LEFT)
                self:setTile(x, cloudStart, CLOUD_RIGHT)
            end
        end
        while x > 6 and x < self.mapWidth - 20 do
            if math.random(10) == 1 then
                    self:setTile(x, self.mapHeight / 2 - 2, MUSHROOM_TOP)
                    self:setTile(x, self.mapHeight / 2 - 1, MUSHROOM_BOTTOM)


                for y = self.mapHeight / 2, self.mapHeight do
                    self:setTile(x, y, TILE_BRICK)
                end
                x = x + 1
            
            elseif math.random(10) == 1 and x < self.mapWidth - 3 then
                local bushLevel = self.mapHeight / 2 - 1

                self:setTile(x, bushLevel, BUSH_LEFT)
                for y = self.mapHeight / 2, self.mapHeight do
                    self:setTile(x, y, TILE_BRICK)
                end
                x = x + 1

                self:setTile(x, bushLevel, BUSH_RIGHT)
                for y = self.mapHeight / 2, self.mapHeight do
                    self:setTile(x, y, TILE_BRICK)
                end
                x = x + 1

            elseif math.random(math.floor(10 - h)) ~= 1 then
                if l ~= 2 then
                    for y = self.mapHeight / 2, self.mapHeight do
                        self:setTile(x, y, TILE_BRICK)
                        r = 0
                        l = l + 1
                    end
                
                    if math.random(15) == 1 then
                            self:setTile(x, self.mapHeight / 2 - 4, JUMP_BLOCK)
                    end
                end
                x = x + 1
            elseif r == 2 then
                for y = self.mapHeight / 2, self.mapHeight do
                    self:setTile(x, y, TILE_BRICK)
                end
            else
                x = x + 2
                r = r + 1
                l = 0
            end
        end

        for x = self.mapWidth - 10 - self.height, self.mapWidth - 2 - self.height do
            for y = self.mapHeight / 2 - (x - self.mapWidth + 10 + self.height), self.mapHeight / 2 do
                self:setTile(x, y, TILE_BRICK)
            end
        end
        for y = self.mapHeight / 2, self.mapHeight do
            self:setTile(x, y, TILE_BRICK)
        end
        x = x + 1
        if x == self.mapWidth - 4 then
            for y = self.mapHeight / 2 - 11, self.mapHeight / 2 - 11 do
                self:setTile(x, y, FLAG_TOP)
                self:setTile(x + 1, y, FLAG_UP)
            end
            for y = self.mapHeight / 2 - 10, self.mapHeight / 2 - 2 do
                self:setTile(x, y, FLAG_MIDDLE)
            end
            for y = self.mapHeight / 2 - 1 , self.mapHeight / 2 do
                self:setTile(x, y, FLAG_BOTTOM)
            end
        end
    end

    self.music:setLooping(true)
    self.music:setVolume(0.25)
    self.music:play()

end

function Map:level()
    return h
end

function Map:collides(tile)
    local collidables = {
        TILE_BRICK, JUMP_BLOCK, JUMP_BLOCK_HIT,
        MUSHROOM_TOP, MUSHROOM_BOTTOM, 
        FLAG_BOTTOM, FLAG_MIDDLE, FLAG_TOP
        }

    for _, v in ipairs(collidables) do
        if tile.id == v then
            return true
        end
    end

    return false
end

function Map:update(dt)
    self.camX = math.max(0,
        math.min(self.player.x - VIRTUAL_WIDTH / 2,
        math.min(self.mapWidthPixels - VIRTUAL_WIDTH, self.player.x)))
    
    self.player:update(dt)
    if self.player.x > self.mapWidthPixels - 100 then
        self.music:stop()
        h = h + 1
        map:init()
    end
    if lives < 1 then
        gameState = 'loss'
    end
end

function Map:tileAt(x, y)
    return {
        x = math.floor(x / self.tileWidth) + 1,
        y = math.floor(y / self.tileHeight) + 1,
        id = self:getTile(math.floor(x / self.tileWidth) + 1, math.floor(y / self.tileHeight) + 1)
    }
end

function Map:setTile(x, y, id)
    self.tiles[(y - 1) * self.mapWidth + x] = id
end

function Map:getTile(x, y)
    return self.tiles[(y - 1) * self.mapWidth + x]
end

function Map:render()
    for y = 1, self.mapHeight do
        for x = 1, self.mapWidth do
            local tile = self:getTile(x, y)
            if tile ~= TILE_EMPTY then
                love.graphics.draw(self.spritesheet, self.tileSprites[tile],
                    (x - 1) * self.tileWidth, (y - 1) * self.tileHeight)
            end
        end
    end

    self.player:render()

end