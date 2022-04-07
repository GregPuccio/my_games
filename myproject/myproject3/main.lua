WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

Class = require 'class'
push = require 'push'

require 'Animation'
require 'Map'
require 'Player'
require 'Enemy'
require 'Util'



function love.load()


    love.window.setTitle("The Climb")

    math.randomseed(os.time())

    love.graphics.setDefaultFilter('nearest', 'nearest')

    smallFont = love.graphics.newFont('font.ttf', 8)
    statsFont = love.graphics.newFont('font.ttf', 16)
    titleFont = love.graphics.newFont('font.ttf', 32)
    victoryFont = love.graphics.newFont('font.ttf', 24)
    love.graphics.setFont(smallFont)

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })
    

    map = Map()
    player = Player(map)
    enemy = Enemy(player)

    gameState = 'start'

    love.keyboard.keysPressed = {}
    love.keyboard.keysReleased = {}

end

function love.resize(w, h)
    push:resize(w, h)
end

function love.keyboard.wasPressed(key)
    if (love.keyboard.keysPressed[key]) then
        return true
    else
        return false
    end
end

function love.keyboard.wasReleased(key)
    if (love.keyboard.keysReleased[key]) then
        return true
    else
        return false
    end
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif gameState == 'start' and (key == 'enter' or key == 'return') then
        gameState = 'climb'
        playerLevel = playerLevel + 1
        map:init()
    elseif gameState == 'boss' and (key == 'enter' or key == 'return') then
        gameState = 'fight'
    elseif gameState == 'gameover' and (key == 'enter' or key == 'return') then
        playerLevel = 0
        lives = 5
        gameState = 'start'
    end

    love.keyboard.keysPressed[key] = true
end

function love.keyreleased(key)
    love.keyboard.keysReleased[key] = true
end

function love.update(dt)
    
    map:update(dt)
    
    love.keyboard.keysPressed = {}
    love.keyboard.keysReleased = {}

end

function love.draw()
    push:apply('start')

    love.graphics.clear(108/255, 140/255, 150/255, 255/255)
    love.graphics.translate(math.floor(-map.camX + 0.5), math.floor(-map.camY + 0.5))

    map:render()    
    
    if gameState == 'start' then
        love.graphics.setFont(titleFont)
        love.graphics.printf("Welcome to The Climb!", 0, map.mapHeightPixels - map.tileHeight * 11, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(statsFont)
        love.graphics.printf("Use the spacebar to jump!", 0, map.mapHeightPixels - map.tileHeight * 6, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("<- Use the arrowkeys to move ->", 0, map.mapHeightPixels - map.tileHeight * 7, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf("Press enter to get started!", 0, map.mapHeightPixels - map.tileHeight * 4.5, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Created by Greg Puccio", -16, map.mapHeightPixels - map.tileHeight * 1.5, VIRTUAL_WIDTH, 'right')
    elseif gameState == 'climb' then
        love.graphics.setFont(statsFont)
        love.graphics.print("Level: " .. tostring(Player:getLevel()), map.tileWidth + 2, math.floor(map.camY + 215))
        love.graphics.print("Lives: " .. tostring(Player:getLives()), map.tileWidth * 22, math.floor(map.camY + 215))
    elseif gameState == 'boss' then
        love.graphics.setFont(smallFont)
        love.graphics.printf("Press enter to fight!", 0, map.mapHeightPixels - map.tileHeight * 8, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(statsFont)
        love.graphics.print("Level: " .. tostring(Player:getLevel()), map.tileWidth + 2, math.floor(map.camY + 215))
        love.graphics.print("Lives: " .. tostring(Player:getLives()), map.tileWidth + 2, math.floor(map.camY + 200))
        love.graphics.print("Boss Lives: " .. tostring(Enemy:getLives()), map.tileWidth * 19, math.floor(map.camY + 215))
    elseif gameState == 'fight' then
        love.graphics.setFont(statsFont)
        love.graphics.print("Level: " .. tostring(Player:getLevel()), map.tileWidth + 2, math.floor(map.camY + 215))
        love.graphics.print("Lives: " .. tostring(Player:getLives()), map.tileWidth + 2, math.floor(map.camY + 200))
        love.graphics.print("Boss Lives: " .. tostring(Enemy:getLives()), map.tileWidth * 19, math.floor(map.camY + 215))
    elseif gameState == 'gameover' then
        love.graphics.setFont(titleFont)
        love.graphics.printf("Game Over!", 0, map.mapHeightPixels - map.tileHeight * 11, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(statsFont)
        love.graphics.printf("You passed " .. tostring(Player:getLevel()) .. " levels!", 0, map.mapHeightPixels - map.tileHeight * 8, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("You defeated " .. tostring(Player:getLevel() / 10 - 1) .. " enemies!", 0, map.mapHeightPixels - map.tileHeight * 7, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf("Press enter to play again", 0, map.mapHeightPixels - map.tileHeight * 5, VIRTUAL_WIDTH, 'center')
    end

    push:apply('end')
end