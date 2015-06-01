SteeringTable = require 'steering'
vector = require 'vector'

function love.load()
  love.graphics.setBackgroundColor(255,255,255)
  v1 = SteeringTable:createVehicle(200,300,0)
  v2 = SteeringTable:createVehicle(300,200,1)
  v3 = SteeringTable:createVehicle(250,250,2)
  v1.vel = vector(50,-30)
  v1.maxSpeed = 350
  v2.vel = vector(10,50)
  v2.maxSpeed = 200
  v3.vel = vector(50,-25)
  v3.maxSpeed = 270
end

function love.update(dt)
  v1.vel = v1.steeringBehaviors:flee(v2.pos)
  v2.vel = v2.steeringBehaviors:seek(v3.pos)
  v3.vel = v3.steeringBehaviors:pursuit(v1)
  v1:update(dt)
  v2:update(dt)
  v3:update(dt)
end

function love.draw()
  love.graphics.setColor(100,200,100)
  
  love.graphics.circle('fill', v1.pos.x, v1.pos.y, 10, 100)
  
  love.graphics.setColor(0,200,200)
  love.graphics.circle('fill', v2.pos.x, v2.pos.y, 10, 100)
  
  love.graphics.setColor(0,100,100)
  love.graphics.circle('fill',v3.pos.x,v3.pos.y,10,100)
end
  
  
  
