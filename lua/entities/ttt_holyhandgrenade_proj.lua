
if SERVER then
   AddCSLuaFile("ttt_holyhandgrenade_proj.lua")
end

ENT.Icon = "VGUI/ttt/icon_holyhandgrenade.png"
ENT.Type = "anim"
ENT.Base = "ttt_basegrenade_proj"
ENT.Model = Model("models/weapons/ent_model/holyhandgrenade.mdl")

local ttt_allow_jump = CreateConVar("ttt_allow_discomb_jump", "0")
AccessorFunc( ENT, "radius", "Radius", FORCE_NUMBER )
AccessorFunc( ENT, "dmg", "Dmg", FORCE_NUMBER )

function ENT:Initialize()
   if not self:GetRadius() then self:SetRadius(512) end
   if not self:GetDmg() then self:SetDmg(150) end

   return self.BaseClass.Initialize(self)
end

local function PushPullRadius(pos, pusher)
   local radius = 400
   local phys_force = 1500
   local push_force = 256

   
   for k, target in pairs(ents.FindInSphere(pos, radius)) do
      if IsValid(target) then
         local tpos = target:LocalToWorld(target:OBBCenter())
         local dir = (tpos - pos):GetNormal()
         local phys = target:GetPhysicsObject()

         if target:IsPlayer() and (not target:IsFrozen()) and ((not target.was_pushed) or target.was_pushed.t != CurTime()) then
        
            dir.z = math.abs(dir.z) + 1

            local push = dir * push_force

            local vel = target:GetVelocity() + push
            vel.z = math.min(vel.z, push_force)

            if pusher == target and (not ttt_allow_jump:GetBool()) then
               vel = VectorRand() * vel:Length()
               vel.z = math.abs(vel.z)
            end

            target:SetVelocity(vel)

            target.was_pushed = {att=pusher, t=CurTime()}

         elseif IsValid(phys) then
            phys:ApplyForceCenter(dir * -1 * phys_force)
         end
      end
   end
end

ENT.called = false
function ENT:Explode(tr)
	if SERVER then
		if self.called then return end
         self.Entity:EmitSound("holyhandgrenade.wav", 511)

         local phys = self.Entity:GetPhysicsObject()
         if ( IsValid( phys ) ) then -- Always check with IsValid! The ent might not have physics!
	            phys:EnableMotion( false )
         else
	         return
         end
		timer.Simple(1.5, function()
			self.Entity:SetNoDraw(true)
			self.Entity:SetSolid(SOLID_NONE)

			if tr.Fraction != 1.0 then
				self.Entity:SetPos(tr.HitPos + tr.HitNormal * 0.6)
			end

			local pos = self.Entity:GetPos()
				  
			local effect = EffectData()
			effect:SetStart(pos)
			effect:SetOrigin(pos)
			effect:SetScale(self:GetRadius() * 0.3)
			effect:SetRadius(self:GetRadius())
			effect:SetMagnitude(self.dmg)

			if tr.Fraction != 1.0 then
				effect:SetNormal(tr.HitNormal)
			end

			util.Effect("Explosion", effect, true, true)
			util.BlastDamage(self, self:GetThrower(), pos, self:GetRadius(), self:GetDmg())
			StartFires(pos, tr, 25, 15, false, self:GetThrower())
								  
			PushPullRadius(pos, self:GetThrower())
         
         local num
		   if game.SinglePlayer() then
		      num = 64
		   else
		      num = 62
		   end
         
         local effectdata = EffectData()
         effectdata:SetOrigin(self:GetPos())
         util.Effect("hhg_explosion",effectdata)

         for i=1,num do
            local effectdata2 = EffectData()
            effectdata2:SetOrigin(self:GetPos() + Vector(0,0,70))
            util.Effect("hhg_cloud",effectdata2)
         end

         local effectdata3 = EffectData()
         effectdata3:SetOrigin(self:GetPos() + Vector(0,0,10))
         if hitnormal != nil then
            effectdata3:SetNormal(hitnormal)
         end

         util.Effect("hhg_rings",effectdata3)
         self:Remove()
    
		end)
		self.called = true
	end
end



if CLIENT then
   local EFFECT={}
       
   function EFFECT:Init( data )
           self.Origin = data:GetOrigin()
    
   
           self:SetModel("models/XQM/Rails/gumball_1.mdl")
         self:SetMaterial("lights/White002")
         self.LifeTime = CurTime() + 2
         self.Size = 4	
   end
      
   function EFFECT:Think( )
       if !(self.LifeTime < CurTime()) then
         if self.Size == 25 then 
          self.Size = -1
          self.Emitter = ParticleEmitter( self.Origin )
         for i=1,4 do
            
            local circle = self.Emitter:Add("particle/particle_ring_wave_additive", self.Origin)
            
            if (circle) then
            
               circle:SetColor(203, 150, 3)
               circle:SetVelocity(VectorRand():GetNormal()*math.random(10, 30))
               circle:SetRoll(math.Rand(0, 360))
               circle:SetDieTime(0.4)
               circle:SetLifeTime(0)
               circle:SetStartSize(600 - (i*40))
               circle:SetStartAlpha(255)
               circle:SetEndSize(200)
               circle:SetEndAlpha(200)
               circle:SetGravity(Vector(0,0,0))		
               
            end
         
         end
          end
      return true 
      end
      return false 
   end
      
   function EFFECT:Render() 
   self:SetPos(self.Origin)
   if  self.Size > -1 then
   self.Size = math.Clamp(self.Size + FrameTime()*75,4,25)
   self:SetModelScale( self.Size, 0 )
   end
   if self.Size != 25 and self.Size != -1  then
   self:DrawModel()
   end
   render.SetShadowColor( 255, 255, 255 )
   end
      
   effects.Register(EFFECT,"hhg_explosion")
   
   local EFFECT2={}
   
   
   function EFFECT2:Init(data)
       self.Origin = data:GetOrigin()
       self:SetModel("models/hunter/misc/sphere025x025.mdl")
       self:SetMaterial("lights/White002")
      local vec = VectorRand():GetNormal() * math.Rand(170,240)
       self:SetPos(self.Origin + vec)
       self:PhysicsInit(SOLID_VPHYSICS)
       self:SetCollisionGroup(COLLISION_GROUP_WORLD)
       self:SetCollisionBounds(Vector(-100,-100,-100), Vector(100,100,100))
       self:CreateShadow()
       self:DrawShadow(true)
       self.Size = math.random(4,8)
       self:SetModelScale(self.Size)
       if IsValid(self:GetPhysicsObject()) then
           self:GetPhysicsObject():Wake()
         self:GetPhysicsObject():EnableGravity( false )
           self:GetPhysicsObject():SetVelocity(vec)
       end
       self.LifeTime = CurTime() + 2
      
   end
   
   
   function EFFECT2:Think()
       if !(self.LifeTime < CurTime()) then   
      if !IsValid(self:GetPhysicsObject()) then
           self:PhysicsInit(SOLID_VPHYSICS)
       end
      return true 
      end
   
       return false
   end
   
   function EFFECT2:Render()
   self:DrawModel()
   self.Size = math.Clamp(self.Size - FrameTime()*4,0,8)
   self:SetModelScale( self.Size, 0 )
   end
   
   
   effects.Register(EFFECT2,"hhg_cloud")
   
   local EFFECT3={}
   
   
   function EFFECT3:Init(data)
       self.Origin = data:GetOrigin()
      self.Normal = data:GetNormal() or Vector(0,0,0)
      self.Size = 100
       self.LifeTime = CurTime() + 0.8
   end
   
   
   function EFFECT3:Think()
       if !(self.LifeTime < CurTime()) then   
      if self.Size == 1200 then
      self.Size = -1
      end
      return true 
      end
   
       return false
   end
   
   function EFFECT3:Render()
   if self.Size != -1 then
   self.Size = math.Clamp(self.Size + FrameTime()*2000,100,1200)
   end
   render.SetMaterial(Material("particle/particle_ring_wave_additive"))
   render.DrawQuadEasy(self.Origin,self.Normal,self.Size,self.Size,Color(127,159,255,255),0)
   render.DrawQuadEasy(self.Origin,self.Normal*-1,self.Size,self.Size,Color(98,32,168,255),0)
   end
   effects.Register(EFFECT3,"hhg_rings")
   end
   
   local function ActivateCLPropPhysics()
       if CLIENT then return end
      local sphereprop = ents.Create("prop_physics")
      sphereprop:SetPos(Vector(-99999,-99999,-99999))
      sphereprop:SetModel("models/hunter/misc/sphere025x025.mdl")
      sphereprop:SetAngles(Angle(0,0,0))
      sphereprop:Spawn()
      sphereprop:Fire("kill",0,1)
   end
   
   local clprop_checked
   if clprop_checked then return end
   clprop_checked = true
   ActivateCLPropPhysics()
   clprop_checked = false

function ENT:PhysicsCollide(data, physobj)
	if (data.Speed > 80 and data.DeltaTime > 0.2) then
		self.Entity:EmitSound("weapons/hhg/Holy Water Bounce.wav",math.random(55,70))
   end
end