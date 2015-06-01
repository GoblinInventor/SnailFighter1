--Steering.lua
vector = require 'vector'
config = require 'config'
local SteeringTable = {}
--x pos, y pos, id for vehicle
function SteeringTable:createVehicle(x,y,i)
  local Vehicle = {}
  Vehicle.id = i
  Vehicle.heading = vector(10.0,2.0)
  Vehicle.vel = vector(0.0,0.0)
  Vehicle.speed = Vehicle.vel:len()
  Vehicle.pos = vector(x,y)
  Vehicle.side = Vehicle.heading:perpendicular()
  --Vehicle.side = vector(0.0,0.0)
  Vehicle.mass = 10
  Vehicle.maxSpeed = 100.0
  Vehicle.maxForce = 10.0
  Vehicle.steeringForce = vector(10.0,11.0)
  Vehicle.accel = vector(0.0,0.0)
  Vehicle.panicRadius = 100
  Vehicle.seekRadius = 100

  -- in Buckland there is also a
  -- Vehicle.MaxTurnRate
  -- but given the nature of a platformer that
  -- shouldn't come into play
  
  -- all steering behaviors should be accessible for any vehicle through this table
    Vehicle.steeringBehaviors = {}
    -- target and deceleration
    function Vehicle.steeringBehaviors:pursuit(evader)
      local toEvader = vector(0.0,0.0)
      Vehicle.steeringForce = vector(10.0,10.0)
      toEvader = evader.pos - Vehicle.pos
      local relativeHeading = Vehicle.heading.x*evader.heading.x + Vehicle.heading.y*evader.heading.y
      local dotToEvaderSelf = Vehicle.heading.x*toEvader.x+Vehicle.heading.y*toEvader.y
      if dotToEvaderSelf > 0 and relativeHeading < -0.95 then
        return Vehicle.steeringBehaviors:seek(evader.pos)
      end
      local lookAheadTime = toEvader:len() / (Vehicle.maxSpeed + evader.speed)
      return Vehicle.steeringBehaviors:seek(evader.pos + evader.vel*lookAheadTime);
    end
    
    
      
        
      
      
    function Vehicle.steeringBehaviors:arrive(target, decel)
      local toTarget = target - Vehicle.pos
      local dist = toTarget:len()
      if (dist > 0) then
        local decelTweak = 0.3
        local speed = dist / (decel*decelTweak)
        speed = math.min(speed,Vehicle.maxSpeed)
        local desiredVelocity = toTarget * speed / dist
        return desiredVelocity
      else
         return vector(0.0,0.0)
      end
    end
    function Vehicle.steeringBehaviors:seek(target)
      local desiredVel = vector(0.0,0.0)
      local velCheck = vector(0.0,0.0)
      velCheck = target - Vehicle.pos
      if velCheck:len2() > Vehicle.seekRadius*Vehicle.seekRadius then
      return desiredVel
    else
      local desiredVelPos = vector(0,0)
      desiredVelPos = target - Vehicle.pos
      desiredVel = desiredVelPos:normalized() * Vehicle.maxSpeed
      return desiredVel
      end
    end
    
    function Vehicle.steeringBehaviors:flee(target)
      local desiredVel = vector(0.0,0.0)
      
      if (Vehicle.pos - target):len2() > Vehicle.panicRadius*Vehicle.panicRadius then
      return desiredVel
      else
      desiredVel = (Vehicle.pos - target):normalized()*Vehicle.maxSpeed
      return desiredVel
      end
    end
      
    function Vehicle:calculateSteering()
      Vehicle.accel = Vehicle.steeringForce * 1/Vehicle.mass
    end
    
    
    function Vehicle:update(dt)
      self.acceleration = self.steeringForce * 1/self.mass
      --self.steeringForce = self:calculateSteeringForce
      self.vel = self.vel + self.accel*dt
      if self.vel:len() >  self.maxSpeed then
        self.vel = self.vel:normalized()*self.maxSpeed
      end
      if (self.vel:len2() > 0.000001) then
        self.heading = self.vel:normalized()
        self.side = self.heading:perpendicular()
      end
      self.speed = self.vel:len()
      self.pos = self.pos + self.vel*dt
      if self.pos.x > config.screenWidth then
        self.pos.x = 0
      elseif self.pos.x < 0 then
        self.pos.x = config.screenWidth
      end
      if self.pos.y > config.screenHeight then
        self.pos.y = 0
      elseif self.pos.y < 0 then
        self.pos.y = screenHeight
      end
    end
    
  return Vehicle
end

return SteeringTable


  
  