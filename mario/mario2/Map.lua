Map = Class{}

TILE_BRICK = 1
TILE_EMPTY = 4

local SCROLL_SPEED = 62


function Map:init()
    self.spritesheet = love.graphics.newImage('graphics/spritesheet.png')
    self.tileWidth = 16
    self.tileHeight = 16
    self.mapWidth = 30
    self.mapHeight = 28
    self.tiles = {}

    self.camX = 0
    self.camY = 0

    self.tileSprites = generateQuads(self.spritesheet, self.tileWidth, self.tileHeight)

    self.mapWidthPixels = self.mapWidth * self.tileWidth
    self.mapHeightPixels = self.mapHeight * self.tileHeight

    for y = 1, self.mapHeight do
        for x = 1, self.mapWidth do
            self:setTile(x, y, TILE_EMPTY)
        end
    end

    for y = self.mapHeight / 2, self.mapHeight do
        for x = 1, self.mapWidth do
            self:setTile(x, y, TILE_BRICK)
        end
    end
end

function Map:update(dt)
    if love.keyboard.isDown('w') or love.keyboard.isDown('up') then
        self.camY = math.max(0, self.camY - SCROLL_SPEED * dt)
    elseif love.keyboard.isDown('a') or love.keyboard.isDown('left') then
        self.camX = math.max(0, self.camX - SCROLL_SPEED * dt)
    elseif love.keyboard.isDown('s') or love.keyboard.isDown('down') then
        self.camY = math.min(self.mapHeightPixels - VIRTUAL_HEIGHT, self.camY + SCROLL_SPEED * dt)
    elseif love.keyboard.isDown('d') or love.keyboard.isDown('right') then
        self.camX = math.min(self.mapWidthPixels - VIRTUAL_WIDTH, self.camX + SCROLL_SPEED * dt)
    end
    
end

function Map:setTile(x, y, tile)
    self.tiles[(y - 1) * self.mapWidth + x] = tile
end

function Map:getTile(x, y)
    return self.tiles[(y - 1) * self.mapWidth + x]
end

function Map:render()
    for y = 1, self.mapHeight do
        for x = 1, self.mapWidth do
            love.graphics.draw(self.spritesheet, self.tileSprites[self:getTile(x, y)],
                (x - 1) * self.tileWidth, (y - 1) * self.tileHeight)
        end
    end
end