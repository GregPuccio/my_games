WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

Class = require'class'
push = require 'push'

require 'Ball'
require 'Paddle'

function love.load()

    love.window.setTitle("Greg's Pong")

    math.randomseed(os.time())

    love.graphics.setDefaultFilter('nearest', 'nearest')
    
    smallFont = love.graphics.newFont('font.ttf', 8)
    largeFont = love.graphics.newFont('font.ttf', 16)
    scoreFont = love.graphics.newFont('font.ttf', 32)
    victoryFont = love.graphics.newFont('font.ttf', 24)
    love.graphics.setFont(smallFont)

    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['point_scored'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
    }

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = true
    })

    player1Score = 0
    player2Score = 0


    player1 = Paddle(5, 20, 5, 20)
    player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)
    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 5, 5)

    servingPlayer = math.random(2) == 1 and 1 or 2
    if servingPlayer == 1 then
        ball.dx = 100
    else
        ball.dx = -100
    end

    winner = 0

    gameState = 'start'

end

function love.resize(w, h)
    push:resize(w, h)
end

function love.update(dt)

    if ball.x < 0 then
        player2Score = player2Score + 1
        servingPlayer = 1
        ball:reset()
        ball.dx = 100
        sounds['point_scored']:play()

        if player2Score >= 5 then
            gameState = 'victory'
            winner = 2
        else
            gameState = 'serve'
        end
    end

    if ball.x > VIRTUAL_WIDTH - 4 then
        player1Score = player1Score + 1
        servingPlayer = 2
        ball:reset()
        ball.dx = -100
        sounds['point_scored']:play()
        
        if player1Score >= 5 then
            gameState = 'victory'
            winner = 1
        else
            gameState = 'serve'
        end
    end

    if ball:collides(player1) then
        ball.dx = -ball.dx * 1.03
        ball.x = player1.x + 5

        sounds['paddle_hit']:play()

        if ball.dy < 0 then
            ball.dy = -math.random(10, 150)
        else
            ball.dy = math.random(10, 150)
        end
    end
    
    if ball:collides(player2) then
        ball.dx = -ball.dx * 1.03
        ball.x = player2.x - 4

        sounds['paddle_hit']:play()

        if ball.dy < 0 then
            ball.dy = -math.random(10, 150)
        else
            ball.dy = math.random(10, 150)
        end
    end

    if ball.y <= 0 then
        ball.dy = -ball.dy
        ball.y = 0
        sounds['wall_hit']:play()
    end

    if ball.y >= VIRTUAL_HEIGHT - 4 then
        ball.dy = -ball.dy
        ball.y = VIRTUAL_HEIGHT - 4 
        sounds['wall_hit']:play()
    end


    player1:update(dt)
    player2:update(dt)
    
    if love.keyboard.isDown('w') then
        player1.dy = - PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        player1.dy = PADDLE_SPEED
    else
        player1.dy = 0
    
    end

    if gameState == 'play' then
        if ball.dx > 0 then
            if player1Score - player2Score > 2 then
                if ball.y + 2 < player2.y + (player2.height / 2) - 20 then
                    player2.dy = - PADDLE_SPEED / 1.2
                elseif ball.y + 2 > player2.y + (player2.height / 2) + 20 then
                    player2.dy = PADDLE_SPEED / 1.2
                elseif ball.y + 2 < player2.y + (player2.height / 2) - 3 then
                    player2.dy = - PADDLE_SPEED / 2.1
                elseif ball.y + 2 > player2.y + (player2.height / 2) + 3 then
                    player2.dy = PADDLE_SPEED / 2.1
                elseif ball.y + 2 < player2.y + (player2.height / 2) then
                    player2.dy = - PADDLE_SPEED / 2.5
                elseif ball.y + 2 > player2.y + (player2.height / 2) then
                    player2.dy = PADDLE_SPEED / 2.5
                else
                    player2.dy = 0
                end
            else
                if ball.y + 2 < player2.y + (player2.height / 2) - 20 then
                    player2.dy = - PADDLE_SPEED / 1.3
                elseif ball.y + 2 > player2.y + (player2.height / 2) + 20 then
                    player2.dy = PADDLE_SPEED / 1.3
                elseif ball.y + 2 < player2.y + (player2.height / 2) - 3 then
                    player2.dy = - PADDLE_SPEED / 2.3
                elseif ball.y + 2 > player2.y + (player2.height / 2) + 3 then
                    player2.dy = PADDLE_SPEED / 2.3
                elseif ball.y + 2 < player2.y + (player2.height / 2) then
                    player2.dy = - PADDLE_SPEED / 3
                elseif ball.y + 2 > player2.y + (player2.height / 2) then
                    player2.dy = PADDLE_SPEED / 3
                else
                    player2.dy = 0
                end
            end
        else
            player2.dy = 0
        end
    else
        player2.dy = 0
    end

    if gameState == 'play' then
        ball:update(dt)
    end
end


function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'victory' then
            gameState = 'start'
            player1Score = 0
            player2Score = 0
        end
    end

end

function love.draw()
    push:apply('start')

    love.graphics.clear(40 / 255, 45 / 255, 52 / 255, 255 / 255)

    love.graphics.setFont(smallFont)
    if gameState == 'start' then
        love.graphics.setFont(largeFont)
        love.graphics.printf("Welcome to Greg's Pong!", 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf("Press Enter to Play!", 0, 30, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve' then
        love.graphics.printf("Player " .. tostring(servingPlayer) .. "'s turn!", 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press Enter to Serve!", 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'victory' then
        love.graphics.setFont(victoryFont)
        love.graphics.printf("Player " .. tostring(winner) .. " wins!", 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf("Press Enter to Restart!", 0, 42, VIRTUAL_WIDTH, 'center')
    end
    
    displayScore()

    ball:render()

    player1:render()
    player2:render()

    displayFPS()

    push:apply('end')
end

function displayFPS()
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.setFont(smallFont)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 30, 15)
    love.graphics.setColor(1, 1, 1, 1)
end

function displayScore()
    love.graphics.setFont(scoreFont)
    love.graphics.print(player1Score, VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3 - 20)
    love.graphics.print(player2Score, VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3 - 20)
end