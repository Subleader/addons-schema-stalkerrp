AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

local BleedingEnableBandagesG = GetConVar("g_bleeding_enablebandages")
local BleedingMaxBandagesG = GetConVar("g_bleeding_maxbandages")
local BleedingMessageG = GetConVar("g_bleeding_message")

function ENT:SpawnFunction( ply, tr, ClassName )
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 18
    pAngle = ply:GetAngles()
	pAngle.pitch = 0
	pAngle.roll = pAngle.roll + 90
	pAngle.yaw = pAngle.yaw
	local ent = ents.Create( ClassName )       
	ent:SetPos( SpawnPos - Vector(0,0,5) )
	ent:SetAngles( pAngle )
	ent:Spawn()
	ent:Activate()
	return ent	
end

function ENT:Initialize()
	self.Entity:SetModel("models/Items/bandage.mdl")
 
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )

	local phys = self.Entity:GetPhysicsObject()
	if phys:IsValid() then
	phys:Wake()
        phys:AddGameFlag( FVPHYSICS_NO_IMPACT_DMG )
        phys:AddGameFlag( FVPHYSICS_NO_NPC_IMPACT_DMG )
	end
	


end

function ENT:OnTakeDamage( dmginfo )
self:TakePhysicsDamage( dmginfo ) 
end

function ENT:Use( activator )
if BleedingEnableBandagesG:GetBool() and activator:GetNWInt("bandage_count")<BleedingMaxBandagesG:GetInt() and IsValid(self) and (activator:GetNetworkedFloat("NextBandageGive") < CurTime()) then
self:Remove()
activator:SetNWInt("bandage_count",activator:GetNWInt("bandage_count") + 1)
activator:SetNetworkedFloat("NextBandageGive", 2 + CurTime())
if BleedingMessageG:GetBool() then
activator:PrintMessage( HUD_PRINTTALK, "You have " .. activator:GetNWInt("bandage_count") .. " bandages.\n"  )
end
activator:EmitSound(Sound("Default.ImpactSoft"))
end
end

function ENT:Think() 
	for k,v in pairs (ents.FindInSphere( self:GetPos(), 30)) do
	if BleedingEnableBandagesG:GetBool() and  IsValid(v) and IsValid(self) and v:IsPlayer() and v:Alive() and v:GetNetworkedBool("Bleeding")==true and (v:GetNetworkedFloat("NextBandageuse") < CurTime()) then
	timer.Simple(0.1,function()
	if BleedingEnableBandagesG:GetBool() and IsValid(v) and IsValid(self) and v:IsPlayer() and v:Alive() and v:GetNetworkedBool("Bleeding")==true then
	v:SetNWBool("Bleeding",false)
	v:SetNetworkedFloat("NextBandageuse", 2 + CurTime())
	v:EmitSound(Sound("bleeding/bandage.wav"))
	self:Remove()
	end
	end)
	end
	timer.Simple(1.01,function()
	if BleedingEnableBandagesG:GetBool() and IsValid(v) and v:IsPlayer() and v:Alive() and v:GetNetworkedFloat("Disorienttime") > CurTime() then
	v:SetNetworkedFloat("Disorienttime", 0 + CurTime())
	end
	end)
	end
	for k,v in pairs (ents.FindInSphere( self:GetPos(), 30)) do
	if BleedingEnableBandagesG:GetBool() and IsValid(v) and v:IsNPC() and v:GetNetworkedBool("Bleeding")==true then
	timer.Simple(0.1,function()
	if BleedingEnableBandagesG:GetBool() and IsValid(v) and v:IsNPC() and v:GetNetworkedBool("Bleeding")==true then
	v:SetNWBool("Bleeding",false)
	v:EmitSound(Sound("bleeding/bandage.wav"))
	self:Remove()
	end
	end)
	end
	end
    self:NextThink(CurTime())
    return true
end
