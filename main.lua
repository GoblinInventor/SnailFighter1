HC = require "hardoncollider"
vector = require "vector"
anim8 = require 'anim8'
camera = require 'camera'
world = require 'world'
--local loader = require "AdvTiledLoader/Loader"
--loader.path = "maps/"

--[[
The jumping and platform elements are based on 
http://www.headchant.com/2012/01/06/tutorial-creating-a-platformer-with-love-part-1/
and use the hardoncollider

The anim8 tutorial on github
(https://github.com/kikito/anim8)
is what I have based my sprite sheet use on

The hardoncollider code is heavily influenced by the
tutorial the original coder wrote at
http://vrld.github.io/HardonCollider/tutorial.html

--]]


    

function on_collide(dt,shape_a,shape_b)
  local other
  Hero:collide(dt,shape_a,shape_b)
  for i, v in pairs(Snails) do
    v:collide(dt,shape_a,shape_b)
    if (v.dead == true) then
      table.remove(Snails,i)
    end
  end
  
  for i, v in pairs(uncleTeds) do

  v:collide(dt,shape_a,shape_b)
  if v.dead == true then
    table.remove(uncleTeds,i)
  end
end
end

function love.load()
  level = {}
  level.maxX = 20000
  level.maxY = love.window.getHeight()
  screenheight = 1280
  screenwidth = 960
  blockHeight = 20
  success = love.window.setMode(screenheight,screenwidth)
  numSnails = 10 
  debug = 1
  numTeds = 3
  Snails = {}
  uncleTeds = {}
  snailBoxes = {}
  gravityoff = 0
  Entities = {} 
  screenWidth = love.graphics.getWidth()
  screenHeight = love.graphics.getHeight()
 
    Collider = HC(100,on_collide)
     Hero = createHero()
     uncleTed = createUncleTed()
  heroBox = Collider:addRectangle(Hero.pos.x, Hero.pos.y, 30,38)
  playercam = camera.new()
  playercam.pos = vector(Hero.pos.x, Hero.pos.y - 400)
  --[[backgroundcam = camera.new()
  backgroundcam.zoom = 0.5
  backgroundcam2 = camera.new()
  backgroundcam2.zoom = 0.9*0.5--]]
  
  for i = 1, numSnails do
  xp = math.random(200)
  yp = math.random(200)
  Snails[i] = createSnail(xp*50,yp*50,i)
  Snails[i].box = Collider:addRectangle(Snails[i].pos.x,Snails[i].pos.y,32,32)
 end
 for i = 1, numTeds do
   xp = math.random(numTeds)
   yp = math.random(numTeds)
   uncleTeds[i] = createUncleTed(xp*50,yp*50,i)
  end
  gravity = vector(0,200)
  
  Platforms = {}
  wallCreator = createWallCreator()
  wallCreator:addWall(100,500,100)
  wallCreator:addWall(200,300,100)
  wallCreator:addWall(0,level.maxY,level.maxX) 
  wallCreator:createSteps(100,500,100,5,1)
  wallCreator:createSteps(800,10,100,5,-1)
  wallCreator:createSteps(1000,10,100,10,1)
  for i = 1,100 do
    wallCreator:addWall(200*i,300,100)
    
  end
  wallLeft = Collider:addRectangle(-50,0,50,1280)
  wallRight = Collider:addRectangle(level.maxX,0,50,level.maxY)
  
  
  
  
 
  
  
  
  

  
end

function createUncleTed(xp,yp,i)
  local uncleTed = {}
  uncleTed.pos = vector(xp,yp)
  uncleTed.vel = vector(100.0,0.0)
  uncleTed.currentState = "wander"
  uncleTed.animations = {}
  uncleTed.images = {}
  uncleTed.health = 100
  uncleTed.dead = false
  uncleTed.box = true
  uncleTed.id = i
  
    local uncleTedWanderImage = love.graphics.newImage('anim/uncleTedWanderImage.png')
    local uncleTedWanderGrid = anim8.newGrid(64,64,uncleTedWanderImage:getWidth(),uncleTedWanderImage:getHeight())
    local uncleTedWanderAnimation = anim8.newAnimation(uncleTedWanderGrid('1-3',1),0.1)
    
    local uncleTedDeadImage = love.graphics.newImage('anim/uncleTedDeadImage.png')
    local uncleTedDeadGrid = anim8.newGrid(64,64,uncleTedDeadImage:getWidth(),uncleTedDeadImage:getHeight())
    local uncleTedDeadAnimation = anim8.newAnimation(uncleTedDeadGrid('1-16',1),0.1)
    
    uncleTed.animations["wander"] = uncleTedWanderAnimation
    uncleTed.images["wander"] = uncleTedWanderImage
    uncleTed.box = Collider:addRectangle(uncleTed.pos.x+32, uncleTed.pos.y+32,64,64)
    function uncleTed:update(dt)
      if (uncleTed.dead) then
        
      end
      self.animations[self.currentState]:update(dt)
          local onPlatform = checkPlatformCollision(uncleTed.box)

        if (onPlatform == 0) then
      self.vel = self.vel+gravity*10*dt
    else 
      self.vel.y = 0
  end
    
      self.pos = self.pos + self.vel*dt
      self.box:moveTo(self.pos.x+32,self.pos.y+32)
    end
    function uncleTed:draw()
          self.animations[self.currentState]:draw(self.images[self.currentState],self.pos.x, self.pos.y)
          self.box:draw('line')
    end
    function uncleTed:collide(dt,shape_a,shape_b)
  local other
  if shape_a == self.box then
    other = shape_b
  elseif shape_b == self.box then
    other = shape_a
  else
    return
  end
    
    if (other == wallLeft) then
      self.vel.x = -1*self.vel.x
      self.animations[self.currentState]:flipH()
    end
    if (other == wallRight) then
      self.vel.x = -1*self.vel.x
      self.animations[self.currentState]:flipH()
    end
    for i, v in pairs(Snails) do
      if (other == v.box) then
        self.health = self.health - 50
        self.vel = -1*self.vel
        table.remove(Snails,i)
        if (self.health <= 0) then
          self.dead = true
        end
      end
    end
    end
      
      
      
    --[[
    for i = 1,numSnails do
    if (other == Snails[i].box) then
      if (not self.catchSnail) then
      Snails[i]:changeState("runaway")
      else if (self.caughtSnail == 0) then
        Snails[i]:changeState("caught")
        Snails[i].caught = true
        self.caughtSnail = Snails[i].id
        break
      end
    end
    end
    --]]
      
    return uncleTed

    
  end



function createWallCreator()
  local wallCreator = {}
  height = 20
  wallCreator.walls = {}
  function wallCreator:addWall(x,y,width)
      local wall = Collider:addRectangle(x,y,width,height)
      self.walls[#self.walls+1] = wall
  end
  function wallCreator:createSteps(x,y,width,numSteps,dir)
    newx = x
    newy = y
    if dir == 1 then
    for i=1,numSteps do
        local wall = Collider:addRectangle(newx, newy, width, height)
        self.walls[#self.walls+1] = wall
        newx = newx + 1.5*width
        newy = newy - 2*height
    end
    elseif dir == -1 then
    for i=1,numSteps do
      local wall = Collider:addRectangle(newx-width,newy,width,height)
      newx = newx - 1.5*width
      newy = newy - 2*height
    end
  end
  end

  function wallCreator:draw()
    for i, v in ipairs(self.walls) do
      v:draw('line')
    end
  end
    
return wallCreator
end
--[[ from 4849/Code/Love/camdemo/main.lua --]]
function draw()

	-- draw playfield
	love.graphics.setColor ( 255,255,255 )
	love.graphics.line ( 0, level.maxY, level.maxX, level.maxY)

	-- draw obstacles
	love.graphics.setColor ( 255,0,0 )

	-- draw player
	love.graphics.setColor ( 0,255, 0 )
	--love.graphics.circle("fill", player.pos.x, player.pos.y-player.radius, player.radius )
end
--[[ end from --]]
function love.draw()
  
  --[[ from camdemo/main.lua --]]
  playercam:attach()
     wallCreator:draw()
    wallLeft:draw('line')
    wallRight:draw('line')

  love.graphics.print(tostring(Hero.health),100,100)
        heroBox:draw('line')
Hero:draw()
  for i, v in pairs(uncleTeds) do
   v:draw()
  end
    for i, v in pairs(Snails) do
    v:draw()
    v.box:draw('line')
    --playercam:detach()
  end
    playercam:detach()
        
  end
  --[[
    wallCreator:draw()
    wallLeft:draw('line')
    wallRight:draw('line')
    --]]
    
    


function love.update(dt)
  Hero:update(dt)
  for i, v in pairs(uncleTeds) do
  v:update(dt)
  end
  for i,v in pairs(Snails) do
  v:update(dt)
  end
 
 
 
 --[[
 from 4849\Code\Love\camdemo\main.lua
 --]]
 	--[[local t = love.timer.getTime()
	love.graphics.setBackgroundColor ( 	127 + 64 * (math.sin(t)+1),
										127 + 64 * (math.sin(1.6*t)+1),
										127 + 64 * (math.sin(3.14159*t)+1)) 
  --[[
  end of code from 4849\Love\camdemo\main.lua
  --]]
 --]]
 Collider:update(dt)

end

--[[ from 4849\Code\Love\camdemo\main.lua --]]
function drawBackground(seed)
	-- draw background
	love.math.setRandomSeed ( seed )
	for i=1,300 do
		love.graphics.setColor ( love.math.random(100,255),
								love.math.random(100,255),
								love.math.random(100,255))
		love.graphics.circle ( "fill", love.math.random(-300,level.maxX),
										love.math.random(-love.window.getHeight(),love.window.getHeight()*2),
										200 )
	end
end
--[[ end from 4849\Code\Love\camdemo\main.lua --]]



function checkPlatformCollision(entitybox)
    local onPlatform = 0
      for i,v in ipairs(wallCreator.walls) do
        local x,y = v:center()
        local ex, ey = entitybox:center()
        if entitybox:collidesWith(v) and y > ey then
          onPlatform = i
          break
        end
      end
 
    return onPlatform
end
function createHero()
  local Hero = {}
  Hero.images = {}
  Hero.animations = {}
  Hero.health = 100
  Hero.currentState = "wander"
  Hero.vel = vector(0,0)
  Hero.pos = vector(love.window.getWidth()/2, level.maxY-100)
  Hero.caughtSnail = 0
  Hero.jumpImpulse = -1500
  Hero.movementMagnitude = 50
  Hero.left = vector(-1,0)
  Hero.right = vector(1,0)
  Hero.acc = vector(0.0,0.0)
  Hero.maxacc = 10
  Hero.velMax = 600
  Hero.catchSnail = false
  Hero.throwSnail = false
  local heroWanderImage = love.graphics.newImage('anim/heroWanderImage.png')
  local heroWanderGrid = anim8.newGrid(30,38,heroWanderImage:getWidth(),heroWanderImage:getHeight())
  local heroWanderAnimation = anim8.newAnimation(heroWanderGrid('1-6',1),0.1)
  Hero.animations["wander"] = heroWanderAnimation
  Hero.images["wander"] = heroWanderImage
  function Hero:collide(dt,shape_a,shape_b)
  local other
  if shape_a == heroBox then
    other = shape_b
  elseif shape_b == heroBox then
    other = shape_a
  else
    return
  end
   
    if (other == wallLeft) then
      Hero.vel.x = -1*Hero.vel.x
      self.animations[self.currentState]:flipH()
    end
    if (other == wallRight) then
      Hero.vel.x = -1*Hero.vel.x
      self.animations[self.currentState]:flipH()
    end
    for i, v in pairs(uncleTeds) do
      if other == v.box then
        Hero.vel.x = v.vel.x*10
      Hero.health = Hero.health - 10
    end
  end
    for i, v in pairs(Snails) do
    
    if (other == v.box) then
      if (not self.catchSnail) then
      v:changeState("runaway")
      else if (self.caughtSnail == 0) then
        v:changeState("caught")
        v.caught = true
        self.caughtSnail = v.id
        break
      end
    end
  end
  
      
    
    
    for i, v in ipairs(wallCreator.walls) do
      if (other == v) then
        
        Hero.vel.y = 0
      end
    end
  end
  end
  function Hero:update(dt)
    if self.caughtSnail == 0 then
    self.catchSnail = false
    end
    self.throwSnail = false
    self.animations[self.currentState]:update(dt)  
    if (love.keyboard.isDown(" ")) then
        self:jump()
    end
    if (love.keyboard.isDown('lctrl') and (not self.throwSnail) and self.caughtSnail == 0) then
      self.catchSnail = true
    end
    if (love.keyboard.isDown('rctrl') and self.catchSnail) then
      self.throwSnail = true
      self.catchSnail = false
    end
    if love.keyboard.isDown("a") then 
      if (self.vel:len() < self.velMax) then
        self.vel.x = self.vel.x-400*dt
      else
        self.vel = self.vel:normalized()*self.velMax*.9
      end
    elseif love.keyboard.isDown("d") then
      if (self.vel:len() < self.velMax) then
        self.vel.x = self.vel.x+400*dt
      else
        self.vel = self.vel:normalized()*self.velMax*.9
      
      end
    else 
      self.vel = self.vel*.9
    end
    
 
 if (love.keyboard.isDown('right') and self.catchSnail and self.caughtSnail ~= 0) then
    Snails[self.caughtSnail].theta = Snails[self.caughtSnail].theta+math.pi/2*dt
    Snails[self.caughtSnail].addToCaught = vector(-32*math.sin(Snails[self.caughtSnail].theta), 32*math.cos(Snails[self.caughtSnail].theta))
  
  
elseif (love.keyboard.isDown('left') and self.catchSnail and self.caughtSnail ~= 0) then
    Snails[self.caughtSnail].theta = Snails[self.caughtSnail].theta-math.pi/2*dt
    Snails[self.caughtSnail].addToCaught = vector(-32*math.sin(Snails[self.caughtSnail].theta), 32*math.cos(Snails[self.caughtSnail].theta))
  
 end
  
    local onPlatform = checkPlatformCollision(heroBox)
 
  
  if (onPlatform == 0) then
      self.vel = self.vel+gravity*10*dt
  end
    
    
    self.pos = self.pos + self.vel*dt
    heroBox:move(self.vel.x*dt,self.vel.y*dt)
    --playercam.pos = self.pos
  --  playercam:move(dt*5, dt*5)
    --playercam:lookAt(self.pos.x,self.pos.y)
    playercam:move(self.vel.x*dt,self.vel.y*dt)
  --backgroundcam.pos.x = Hero.pos.x
  --backgroundcam2.pos.x = Hero.pos.x
      

  end
  function Hero:jump()
    if self.vel.y == 0 then
      self.vel.y = self.jumpImpulse
    end
  end
  
  function Hero:draw()
    self.animations[self.currentState]:draw(self.images[self.currentState],Hero.pos.x, Hero.pos.y)
    --playercam:draw(draw)
 --    backgroundcam:draw(function() drawBackground(57) end)
 -- backgroundcam2:draw(function() drawBackground(99) end)
  --playercam:draw(draw)
  end
  
  return Hero
end



function createSnail(x,y,i)
  local Snail = {}
  Snail.box = true
  Snail.id = i
  Snail.addToCaught = vector(0.0,0.0)
  Snail.pos = vector(x,y)
  Snail.vel = vector(100,0.0)

  Snail.theta = -1/2*math.pi
  Snail.images = {}
  Snail.animations = {}
  Snail.currentState = "wander"
  Snail.caught = false
 Snail.thrown = false
  local snailRunawayImage = love.graphics.newImage('anim/snailRunawayImage.png')
  local snailRunawayGrid = anim8.newGrid(32,32,snailRunawayImage:getWidth(),snailRunawayImage:getHeight())
  local snailRunawayAnimation = anim8.newAnimation(snailRunawayGrid('1-18',1),0.1)
  Snail.images["runaway"] = snailRunawayImage
  Snail.animations["runaway"] = snailRunawayAnimation
  
  local snailCaughtImage = love.graphics.newImage('anim/snailCaughtImage.png')
  local snailCaughtGrid = anim8.newGrid(32,32,snailCaughtImage:getWidth(),snailCaughtImage:getHeight())
  local snailCaughtAnimation = anim8.newAnimation(snailCaughtGrid('1-9',1),0.1)
  Snail.images["caught"] = snailCaughtImage
  Snail.animations["caught"] = snailCaughtAnimation
  
  local snailThrownImage = love.graphics.newImage('anim/snailThrownImage.png')
  local snailThrownGrid = anim8.newGrid(32,32,snailThrownImage:getWidth(),snailThrownImage:getWidth())
  local snailThrownAnimation = anim8.newAnimation(snailThrownGrid('1-12',1),0.1)
  Snail.images["thrown"] = snailThrownImage
  Snail.animations["thrown"] = snailThrownAnimation
  
  
  Snail.images["dying"] = snailDyingImage
  Snail.animations["dying"] = snailDyingAnimation
  snailWanderImage = love.graphics.newImage('anim/snailWanderImage.png')
  Snail.images["wander"] = snailWanderImage
  local snailWanderGrid = anim8.newGrid(32,32,snailWanderImage:getWidth(),snailWanderImage:getHeight())
  local snailWanderAnimation = anim8.newAnimation(snailWanderGrid('1-12',1),0.1)
  snailWanderAnimation:flipH()
  Snail.animations["wander"] = snailWanderAnimation


  snailPanicImage = love.graphics.newImage('anim/snailPanicImage.png')
  local snailPanicGrid = anim8.newGrid(32,32,snailPanicImage:getWidth(),snailPanicImage:getHeight())
  snailPanicAnimation = anim8.newAnimation(snailPanicGrid('1-12',1),0.1)
  Snail.images["panic"] = snailPanicImage
  Snail.animations["panic"] = snailPanicAnimation
  function Snail:collide(dt,shape_a,shape_b)
  local other

  if shape_a == self.box then
    other = shape_b
  elseif shape_b == self.box then
    other = shape_a
  else
    return
  end
    for i,v in pairs(uncleTeds) do
    if other == v.box and self.thrown then
      --uncleTed.health = uncleTed.health - 50 -- uncleTed should have 100 health
      if v.health <= 0 then
        table.remove(uncleTeds,i)
        
      end
      self.thrown = false
    end
    end 
    for i, v in pairs(Snails) do
    
      
    if other == v.box and i ~= v.id then
    end
    end
    if (other == wallLeft) then
      
      self.vel.x = -1*self.vel.x
      self.animations[self.currentState]:flipH()
    end
    if (other == wallRight) then
      self.vel.x = -1*self.vel.x
     self.animations[self.currentState]:flipH()
    end
    if (other == heroBox) then
      if (not self.caught) then
        
        self.vel.x = self.vel.x*-1
        self.animations[self.currentState]:flipH()
      end
    end
       for i, v in ipairs(wallCreator.walls) do
      if (other == v and not (self.thrown)) then
        
        self.vel.y = 0
      elseif (other == v and (self.thrown)) then
        self.vel = self.vel*-1

      end
    end
  end
  --function Snail:panic()
    
  function Snail:update(dt)
    if (Hero.throwSnail and Hero.caughtSnail == self.id) then
      self.vel.x = -400*math.sin(self.theta) 
      self.vel.y = 400*math.cos(self.theta) 
      self.caught = false
      Hero.throwSnail = false
      self.thrown = true
      Hero.caughtSnail = 0
      
    end
    
      
      self.animations[self.currentState]:update(dt)
     
if self.caught then
  self.pos.y = Hero.pos.y+self.addToCaught.y
  self.pos.x = Hero.pos.x+self.addToCaught.x
  self.box:moveTo(self.pos.x,self.pos.y)
  
  else
      local onPlatform = checkPlatformCollision(self.box)
     if (onPlatform == 0 and (not self.thrown)) then
       self.vel = self.vel+gravity*10*dt
    elseif (onPlatform ~= 0 and not(self.thrown)) then
      self.vel.y = 0
    
    elseif (self.thrown and onPlatform == 0) then
      
    
    elseif (self.thrown and onPlatform ~= 0) then
      self.vel = self.vel*-1
    end
  end
      self.pos = self.pos + self.vel*dt 
      self.box:move(self.vel.x*dt,self.vel.y*dt)
      
  end
  
  function Snail:changeState(state)
    self.currentState = state
  end
  function Snail:draw()
    self.animations[self.currentState]:draw(self.images[self.currentState],self.pos.x, self.pos.y)
  end
  return Snail
end