WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243


Class = require 'class'
push = require 'push'

require 'Util'
require 'Player'
require 'Map'
require 'Animation'



function love.load()

    love.window.setTitle("Oni's Adventure")

    math.randomseed(os.time())
    smallFont = love.graphics.newFont('font.ttf', 8)
    statsFont = love.graphics.newFont('font.ttf', 16)
    titleFont = love.graphics.newFont('font.ttf', 32)
    victoryFont = love.graphics.newFont('font.ttf', 24)
    
    map = Map()

    love.graphics.setDefaultFilter('nearest', 'nearest')

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })

    love.keyboard.keysPressed = {}
    h = 1
    lives = 5
    coins = 0
    gameState = 'start'
    

end

function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end
    if gameState == 'start' and key == 'return' then
        gameState = 'play'
    end
    if gameState == 'loss' and key == 'return' then
        h = 1
        lives = 5
        coin = 0
        map:init()
        gameState = 'start'
    end

    love.keyboard.keysPressed[key] = true
end


function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]
end

function love.update(dt)
    map:update(dt)
    love.draw(dt)
    love.keyboard.keysPressed = {}
end


function love.draw()
    push:apply('start')
    love.graphics.translate(math.floor(-map.camX), math.floor(-map.camY))
    love.graphics.clear(108/255, 140/255, 255/255, 1)
    if gameState == 'start' then
        love.graphics.setFont(titleFont)
        love.graphics.printf("Welcome to Oni's Adventure", 0, 15, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(statsFont)
        love.graphics.printf("Press Enter to play!", 0, 100, VIRTUAL_WIDTH, 'center')    
    elseif gameState == 'play' then
        love.graphics.printf("Lives: " .. tostring(Player:livesLeft()), map.camX + 20, 15, VIRTUAL_WIDTH)
        love.graphics.printf("Level: " .. tostring(Map:level()), map.camX + 20, 30, VIRTUAL_WIDTH)
        love.graphics.printf("Coins: " .. tostring(Player:getCoins()), map.camX + 20, 45, VIRTUAL_WIDTH)
    elseif gameState == 'loss' then
        love.graphics.setFont(titleFont)
        love.graphics.printf("Game Over", 0, 15, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(statsFont)
        love.graphics.printf("You made it to Level " .. tostring(Map:level() .. "!"), 0, 60, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("You collected " .. tostring(Player:getCoins() .. " coins!"), 0, 80, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf("Press Enter to play again!", 0, 120, VIRTUAL_WIDTH, 'center') 
    end
    map:render()
    push:apply('end')
end