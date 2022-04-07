require 'Util'

Map = Class{}

TILE_BRICK = 1

TILE_EMPTY = 4

GOAL = 5



local SCROLL_SPEED = 62

function Map:init()

    self.objectSheet = love.graphics.newImage('graphics/spritesheet.png')
    self.objects = generateQuads(self.objectSheet, 16, 16)
    self.music = love.audio.newSource('sounds/Happy Birthday.mp3', 'static')
    

    self.tileWidth = 16
    self.tileHeight = 16
    self.mapWidth = 27
    if playerLevel % 5 ~= 0 then
        self.mapHeight = 25
    else
        self.mapHeight = 16
    end
    self.tiles = {}

    self.gravity = 15

    self.mapWidthPixels = self.mapWidth * self.tileWidth
    self.mapHeightPixels = self.mapHeight * self.tileHeight

    self.camX = 0
    self.camY = self.mapHeightPixels - self.tileHeight * 15.18

    self.player = Player(self)
    self.enemy = Enemy(self)

    if playerLevel % 5 ~= 0 then
        self:buildLevel()
    else
        self:bossLevel()
    end

end

function Map:buildLevel()
    self.music:stop()

    for y = 1, self.mapHeight do
        for x = 1, self.mapWidth do
            
            self:setTile(x, y, TILE_EMPTY)
        end
    end 

    local y = 0
    while y <= self.mapHeight do

        self:setTile(self.mapWidth, y, TILE_BRICK)
        self:setTile(1, y, TILE_BRICK)
            
        for x = 0, self.mapWidth do
            self:setTile(x, self.mapHeight, TILE_BRICK)
            self:setTile(x, 1, GOAL)
        end

        for x = self.mapWidth - 17, self.mapWidth - 10 do
            self:setTile(x, self.mapHeight - 3, TILE_BRICK)
            self:setTile(x, 4, TILE_BRICK)
        end

        if y < self.mapHeight - 4 and y > 4 then
            local platformLoc1 = math.random(self.mapWidth)
            if math.random(2) == 1 then
            
                self:setTile(platformLoc1, y, TILE_BRICK)
                self:setTile(platformLoc1 + 1, y, TILE_BRICK)
            elseif math.random(2) == 1 then
                self:setTile(platformLoc1 + 2, y, TILE_BRICK)
            end
            
        end
        y = y + 1
    end

end

function Map:bossLevel()
    gameState = 'party'

    for y = 1, self.mapHeight do
        for x = 1, self.mapWidth do
            
            self:setTile(x, y, TILE_EMPTY)
        end
    end 

    local y = 0
    while y <= self.mapHeight do

            self:setTile(self.mapWidth, y, TILE_BRICK)
            self:setTile(1, y, TILE_BRICK)

            for x = 0, self.mapWidth do
                self:setTile(x, self.mapHeight, TILE_BRICK)
                self:setTile(x, 1, TILE_BRICK)
            end

            for x = self.mapWidth - 17, self.mapWidth - 10 do
                self:setTile(x, self.mapHeight - 3, TILE_BRICK)
                self:setTile(x, 4, TILE_BRICK)
            end

            for x = self.mapWidth - 5, self.mapWidth - 3 do
                self:setTile(x, 9, TILE_BRICK)
            end

            for x = 4, 6 do
                self:setTile(x, 9, TILE_BRICK)
            end


        y = y + 1
    end
    if playerLevel ~= 0 then
        self.music:setLooping(false)
        self.music:setVolume(0.25)
        self.music:play()
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
        self.camY = math.max(0, math.min(self.player.y - VIRTUAL_HEIGHT / 2,
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