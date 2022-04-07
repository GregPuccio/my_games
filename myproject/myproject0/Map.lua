require 'Util'

Map = Class{}

TILE_BRICK = 1

TILE_EMPTY = 4



local SCROLL_SPEED = 62

function Map:init()

    self.objectSheet = love.graphics.newImage('graphics/spritesheet.png')
    self.objects = generateQuads(self.objectSheet, 16, 16)

    self.tileWidth = 16
    self.tileHeight = 16
    self.mapWidth = 27
    self.mapHeight = 40
    self.tiles = {}

    self.gravity = 15

    self.mapWidthPixels = self.mapWidth * self.tileWidth
    self.mapHeightPixels = self.mapHeight * self.tileHeight

    self.camX = 0
    self.camY = self.mapHeightPixels - self.tileHeight * 15.18

    self.player = Player(self)

    for y = 1, self.mapHeight do
        for x = 1, self.mapWidth do
            
            self:setTile(x, y, TILE_EMPTY)
        end
    end

    local y = 0
    while y <= self.mapHeight do

            self:setTile(self.mapWidth, y, TILE_BRICK)
            self:setTile(1, y, TILE_BRICK)
            
        if y == self.mapHeight then
            for x = 0, self.mapWidth do
                self:setTile(x, y, TILE_BRICK)
            end
        end

        if y < self.mapHeight - 2 then
            if math.random(2) == 1 then
            local platformLoc1 = math.random(self.mapWidth / 2)
                self:setTile(platformLoc1, y, TILE_BRICK)
                self:setTile(platformLoc1 + 1, y, TILE_BRICK)
                    if math.random(5) == 1 then
                        self:setTile(platformLoc1 + 2, y, TILE_BRICK)
                    end
            end
            if math.random(2) == 1 then
                local platformLoc2 = math.random(3 * self.mapWidth / 4)
                self:setTile(platformLoc2, y, TILE_BRICK)
                self:setTile(platformLoc2 + 1, y, TILE_BRICK)
                    if math.random(5) == 1 then
                        self:setTile(platformLoc2 + 2, y, TILE_BRICK)
                    end
            end
        end
        y = y + 1
    end
end

function Map:collides(tile)
    local collidables = {
        TILE_BRICK
    }

    for _, v in ipairs(collidables) do
        if tile.id == v then
            return true
        end
    end

    return false
end

function Map:update(dt)
    self.player:update(dt)
    if gameState == 'climb' then
        self.camY = math.max(self.mapHeight, math.min(self.player.y - VIRTUAL_HEIGHT / 2,
                math.min(self.mapHeightPixels - VIRTUAL_HEIGHT, self.player.y)))
    else
        self.camY = self.camY
    end
end

function Map:tileAt(x, y)
    return {
        x = math.floor(x / self.tileWidth) + 1,
        y = math.floor(y / self.tileHeight) + 1,
        id = self:getTile(math.floor(x / self.tileWidth) + 1, math.floor(y / self.tileHeight) + 1)
    }
end


function Map:getTile(x, y)
    return self.tiles[(y - 1) * self.mapWidth + x]
end

function Map:setTile(x, y, id)
    self.tiles[(y - 1) * self.mapWidth + x] = id
end

function Map:render()
    for y = 1, self.mapHeight do
        for x = 1, self.mapWidth do
            local tile = self:getTile(x, y)
            if tile ~= TILE_EMPTY then
                love.graphics.draw(self.objectSheet, self.objects[tile],
                    (x - 1) * self.tileWidth, (y - 1) * self.tileHeight)
            end
        end
    end

    self.player:render()
end