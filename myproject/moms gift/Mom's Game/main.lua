WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

Class = require'class'
push = require 'push'

require 'Animation'
require 'Map'
require 'Player'
require 'Enemy'
require 'Util'



function love.load()


    love.window.setTitle("Mom's Gift")

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
    enemy = Enemy(map)

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
    elseif gameState == 'party' and (key == 'enter' or key == 'return') then
        playerLevel = 0
        map:init()
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
        love.graphics.print("Welcome to Your Gift!", 40, map.mapHeightPixels - map.tileHeight * 11)
        love.graphics.setFont(smallFont)
        love.graphics.print("Press enter to get started!", 150, map.mapHeightPixels - map.tileHeight * 8)
        love.graphics.print("<- Use your arrowkeys to move ->", 136, map.mapHeightPixels - map.tileHeight * 7)
        love.graphics.print("Use your spacebar or arrow up to jump!", 125, map.mapHeightPixels - map.tileHeight * 6)
    elseif gameState == 'climb' then
        love.graphics.setFont(statsFont)
        love.graphics.print("Level: " .. tostring(Player:getLevel()), map.tileWidth + 2, math.floor(map.camY + 215))
    elseif gameState == 'party' then
        love.graphics.setFont(statsFont)
        love.graphics.print("Great job, Mom! You won!", 100, map.mapHeightPixels - map.tileHeight * 12)
        love.graphics.setFont(titleFont)
        love.graphics.print("Happy Birthday to you!", 20, map.mapHeightPixels - map.tileHeight * 10)
        love.graphics.setFont(statsFont)
        love.graphics.print("Love: Alyssa, Brian, Greg and Dad!", 75, map.mapHeightPixels - map.tileHeight * 6)
        love.graphics.setFont(smallFont)
        love.graphics.print("( Hit Enter to play again! <3 )", 150, map.mapHeightPixels - map.tileHeight * 2)
    end

    push:apply('end')
end