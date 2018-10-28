AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

local Damage = {}
Damage.Radius = ENT.BaseScale*2
Damage.BaseDamage = 10
Damage.DamageType = 0
Damage.Delay = 3
Damage.RadInt = 0.2
Damage.RadInc = 1
Damage.NextRad = 0

local Warning = {}
Warning.Sound = {"zavod_yantar/geiger_1.wav","zavod_yantar/geiger_2.wav","zavod_yantar/geiger_3.wav","zavod_yantar/geiger_4.wav","zavod_yantar/geiger_5.wav","zavod_yantar/geiger_6.wav","zavod_yantar/geiger_7.wav","zavod_yantar/geiger_8.wav"}
Warning.NextTick = 0
Warning.TickDelay = 0.05
Warning.Radius = ENT.BaseScale*4

function ENT:Initialize()

	self.model = "models/Gibs/HGIBS_spine.mdl"
	self.Entity:SetModel( "models/Gibs/HGIBS_spine.mdl" ) 
 	
	//self.Entity:PhysicsInit( SOLID_NONE )
	self.Entity:SetMoveType( MOVETYPE_NONE )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:SetColor ( Color (255,255,255,0) )
	
	local phys = self.Entity:GetPhysicsObject()

	if (phys:IsValid()) then
		phys:Wake()
		phys:SetMass(10000)
	end
	
	self.Entity:DrawShadow(true)
	self:CreatePointHurt()
	self:CreateSprite("220 0 0",0.5,200)
end  

function ENT:CreateSprite(color,size,alpha)
	local pos = self.Entity:GetPos()
	
	local sprite = ents.Create("env_sprite")
	sprite:SetPos(pos)
	local kv = {
		model="",
		scale=size,
		rendermode=5,
		renderamt=alpha,
		rendercolor=color,
	}
	sprite:KeyValueTable(kv);
	sprite:Spawn()
	sprite:Activate()
	sprite:SetParent(self.Entity)
	
end

local eMeta = FindMetaTable("Entity")
function eMeta:KeyValueTable(tbl)
	for k,v in pairs(tbl) do
		self:SetKeyValue(k,v)
	end
end


function ENT:CreatePointHurt()
	local hurt = ents.Create("point_hurt")
	hurt:SetPos(self.Entity:GetPos())
	local kvs = {
		DamageRadius = Damage.Radius,
		Damage = Damage.BaseDamage,
		DamageDelay = Damage.Delay,
		DamageType = DMG_RADIATION
	}
		hurt:KeyValueTable(kvs)
		hurt:Spawn()
		hurt:SetParent(self.Entity)
end

function ENT:Think()
	local all = player.GetAll()
	local ePos = self.Entity:GetPos()
	for k,user in pairs(all) do
		local uPos = user:GetPos()
		local dist = (ePos-uPos):Length()
		if dist < Warning.Radius then
			if CurTime() > Warning.NextTick then
				local ran = math.random(1,table.getn(Warning.Sound))
				user:EmitSound(Warning.Sound[ran])
				Warning.NextTick = CurTime()+Warning.TickDelay
			end	
		end
	end
	if CurTime() > Damage.NextRad then
		Damage.NextRad = CurTime()+Damage.RadInt
		for k,user in pairs(all) do
			local uPos = user:GetPos()
			local dist = (ePos-uPos):Length()
		end
	end
end

function ENT:KeyValue(key,value)
	self[key] = tonumber(value) or value
end

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	local ent = ents.Create( self.ClassName )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	return ent
end