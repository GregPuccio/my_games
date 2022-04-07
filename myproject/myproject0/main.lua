WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

Class = require'class'
push = require 'push'

require 'Animation'
require 'Map'
require 'Player'
require 'Util'



function love.load()


    love.window.setTitle("The Climb")

    math.randomseed(os.time())

    love.graphics.setDefaultFilter('nearest', 'nearest')

    smallFont = love.graphics.newFont('font.ttf', 8)
    largeFont = love.graphics.newFont('font.ttf', 16)
    scoreFont = love.graphics.newFont('font.ttf', 32)
    victoryFont = love.graphics.newFont('font.ttf', 24)
    love.graphics.setFont(smallFont)

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })
    

    map = Map()
    player = Player(map)

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
    elseif key == 'enter' or key == 'return' then
        gameState = 'climb'
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
    if gameState == 'start' then
        love.graphics.print("Welcome to The Climb!", 160, map.mapHeightPixels - map.tileHeight * 3)
        love.graphics.print("Press enter to get started!", 150, map.mapHeightPixels - map.tileHeight * 2)
    end


    map:render()

    
    push:apply('end')
end