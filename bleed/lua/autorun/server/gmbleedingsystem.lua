local BleedingEnableG = GetConVar("g_bleeding_enable")
local BleedingChanceBasicG = GetConVar("g_bleeding_basechance")
local BleedingChanceIntG = GetConVar("g_bleeding_chance")
local BleedingEnableBandagesG = GetConVar("g_bleeding_enablebandages")
local BleedingMaxBandagesG = GetConVar("g_bleeding_maxbandages")
local BleedingMinDamageG = GetConVar("g_bleeding_mindamage")
local BleedingMaxDamageG = GetConVar("g_bleeding_maxdamage")
local BleedingTimesG = GetConVar("g_bleeding_howmuchtimes")
local BleedingDurationG = GetConVar("g_bleeding_duration")
local BleedingDisorientEnableG = GetConVar("g_bleeding_disorientenable")
local BleedingDisorientDurationG = GetConVar("g_bleeding_disorientduration")
local BleedingEnableHudIconG = GetConVar("g_bleeding_enablehudicon")
local BleedingEnableScreenFlashG = GetConVar("g_bleeding_enablescreenflash")
local BleedingMessageG = GetConVar("g_bleeding_message")

local function BleedingChanceVars(BleedingChance)
        for i=1,BleedingChanceIntG:GetInt() do
		if BleedingChance == i then return BleedingChance end
		end
end

local function BleedingDmgType(dmginfo)
		if dmginfo:IsDamageType(DMG_BULLET) then
		return dmginfo
		elseif dmginfo:IsDamageType(DMG_SLASH) then
		return dmginfo
		elseif dmginfo:IsDamageType(DMG_BLAST) then
		return dmginfo
		elseif dmginfo:IsDamageType(DMG_CLUB) then
		return dmginfo
		elseif dmginfo:IsDamageType(DMG_ENERGYBEAM) then
		return dmginfo
		elseif dmginfo:IsDamageType(DMG_PARALYZE) then
		return dmginfo
		elseif dmginfo:IsDamageType(DMG_POISON) then
		return dmginfo
        elseif dmginfo:IsDamageType(DMG_AIRBOAT) then
		return dmginfo
		elseif dmginfo:IsDamageType(DMG_BUCKSHOT) then
		return dmginfo
		elseif dmginfo:IsDamageType(DMG_PLASMA) then 
		return dmginfo end
end

function GlobalBleeding(ply)
    plypos = ply:GetPos()
	bleeding = nil
	timer.Create("GlobalBleedingspawn",0.01,0,function()
	if !IsValid(bleeding) then
	bleeding = ents.Create("global_bleeding")
	bleeding:SetPos(plypos)
	bleeding:SetAngles(Angle(0,0,0))
	bleeding:Spawn()
	end
	end)
end
hook.Add( "PlayerInitialSpawn", "GlobalBleeding", GlobalBleeding )

function BandageSet(ply)
ply:SetNWInt("bandage_count",0)
ply:SetNetworkedFloat("NextBandageuse", 0 + CurTime())
ply:SetNetworkedFloat("NextBandageGive", 0 + CurTime())
end
hook.Add( "PlayerSpawn", "BandageSet", BandageSet )

local function BleedingBloodColor(bleedingentity)
		if (bleedingentity:GetBloodColor() == BLOOD_COLOR_ANTLION
		or bleedingentity:GetBloodColor() == BLOOD_COLOR_ANTLION_WORKER
		or bleedingentity:GetBloodColor() == BLOOD_COLOR_GREEN
		or bleedingentity:GetBloodColor() == BLOOD_COLOR_YELLOW
		or bleedingentity:GetBloodColor() == BLOOD_COLOR_ZOMBIE) then 
		return bleedingentity end
end

function StartBleeding(target, dmginfo)
if !(BleedingEnableG:GetBool()) then return end
 local BleedingChance = math.random(1,BleedingChanceBasicG:GetInt())
 if (string.find(target:GetClass(), "npc_strider")
 or  string.find(target:GetClass(), "npc_helicopter")
 or  string.find(target:GetClass(), "npc_combinegunship")
 or  string.find(target:GetClass(), "npc_combinedropship")
 or  string.find(target:GetClass(), "npc_turret_floor")
 or  string.find(target:GetClass(), "npc_turret_ceiling") 
 or  string.find(target:GetClass(), "npc_turret_ground") 
 or  string.find(target:GetClass(), "npc_clawscanner") 
 or  string.find(target:GetClass(), "npc_cscanner")
 or  string.find(target:GetClass(), "npc_manhack")
 or  string.find(target:GetClass(), "npc_rollermine")) then
 else
 if (target:IsNPC() or target:IsPlayer()) and IsValid(target) and !(target:GetNetworkedBool("Bleeding")==true) and BleedingChanceVars(BleedingChance) and BleedingDmgType(dmginfo) then
 local bleedingentity = target
 local timerw = "Bleeding" .. bleedingentity:EntIndex()
 local dmgattacker = dmginfo:GetAttacker()
 local dmgpos = dmginfo:GetDamagePosition()
 local dmgtype = dmginfo:GetDamageType()
 timer.Simple(BleedingDurationG:GetFloat(),function()
 if IsValid(bleedingentity) and bleedingentity:IsPlayer() and !bleedingentity:IsBot() and bleedingentity:Alive() then
 bleedingentity:SetNetworkedFloat("Disorienttime", BleedingDisorientDurationG:GetFloat() + CurTime())
 end
 end)
 local bleedingpos = ents.Create("info_target")
 bleedingpos:Spawn()
 bleedingpos:SetPos(dmgpos)
 bleedingpos:Activate()
 bleedingpos:SetNWBool("Posbleeding",true)
 bleedingpos:SetParent( bleedingentity )
 bleedingentity:SetNetworkedBool("Bleeding",true)
 timer.Create(timerw,BleedingDurationG:GetFloat(),BleedingTimesG:GetFloat(),function()
 if IsValid(bleedingentity) and bleedingentity:GetNetworkedBool("Bleeding")==true then
 if !(IsValid(bleedingpos)) then return end
 local bleed = DamageInfo()
 bleed:SetDamage( math.random(BleedingMinDamageG:GetInt(),BleedingMaxDamageG:GetInt()) )
 if (dmgtype == DMG_BLAST ) then
 bleed:SetDamageType( DMG_SLASH )
 else
 bleed:SetDamageType( DMG_CLUB )
 end
 if IsValid(dmgattacker) then
 bleed:SetAttacker( dmgattacker )
 else
 bleed:SetAttacker( bleeding )
 end
 bleed:SetInflictor( bleeding )
 bleedingentity:TakeDamageInfo( bleed )
 if BleedingEnableScreenFlashG:GetBool() and bleedingentity:IsPlayer() and !bleedingentity:IsBot() then
 bleedingentity:ScreenFade(bit.bor(SCREENFADE.OUT,SCREENFADE.PURGE),Color(127,0,0,120),0.3,1)
 end
 if BleedingBloodColor(bleedingentity) then
 if !(dmgtype == DMG_BLAST ) then
 ParticleEffect( "blood_impact_yellow_01", bleedingpos:GetPos(), Angle(0,0,0))
 end
 local traceworld = {}
 if (dmgtype == DMG_BLAST) then
 traceworld.start = bleedingentity:GetPos()
 traceworld.fliter = bleedingentity
 else
 traceworld.start = bleedingpos:GetPos()
 traceworld.fliter = bleedingpos
 end
 traceworld.endpos = traceworld.start - (Vector(math.Rand(-1,1),math.Rand(-1,1),1)*1000) 
 local trw = util.TraceLine(traceworld)
 local worldpos1 = trw.HitPos + trw.HitNormal
 local worldpos2 = trw.HitPos - trw.HitNormal
 util.Decal("YellowBlood",worldpos1,worldpos2)
 elseif bleedingentity:GetBloodColor() == BLOOD_COLOR_RED  then
 if !(dmgtype == DMG_BLAST ) then
 local effectdata = EffectData()
 effectdata:SetAngles( bleedingentity:GetAngles() ) 
 effectdata:SetOrigin( bleedingpos:GetPos() )
 effectdata:SetEntity( bleedingentity )
 effectdata:SetAttachment( 1 )
 effectdata:SetScale( 1 )
 util.Effect( "BloodImpact", effectdata )
 end
 local traceworld = {}
 if (dmgtype == DMG_BLAST) then
 traceworld.start = bleedingentity:GetPos()
 traceworld.fliter = bleedingentity
 else
 traceworld.start = bleedingpos:GetPos()
 traceworld.fliter = bleedingpos
 end
 traceworld.endpos = traceworld.start - (Vector(math.Rand(-1,1),math.Rand(-1,1),1)*1000) 
 local trw = util.TraceLine(traceworld)
 local worldpos1 = trw.HitPos + trw.HitNormal
 local worldpos2 = trw.HitPos - trw.HitNormal
 util.Decal("Blood",worldpos1,worldpos2)
 elseif bleedingentity:GetBloodColor() == BLOOD_COLOR_MECH  then
 if !(dmgtype == DMG_BLAST ) then
 ParticleEffect( "blood_impact_synth_01", bleedingpos:GetPos(), Angle(0,0,0) )
 end
 elseif string.find(bleedingentity:GetClass(), "npc_hunter") then
 if !(dmgtype == DMG_BLAST ) then
 ParticleEffect( "blood_impact_synth_01", bleedingpos:GetPos(), Angle(0,0,0) )
 end
 else
 if !(dmgtype == DMG_BLAST ) then
 local effectdata = EffectData()
 effectdata:SetAngles( bleedingentity:GetAngles() ) 
 effectdata:SetOrigin( bleedingpos:GetPos() )
 effectdata:SetEntity( bleedingentity )
 effectdata:SetAttachment( 1 )
 effectdata:SetScale( 1 )
 util.Effect( "BloodImpact", effectdata )
 end
 local traceworld = {}
 if (dmgtype == DMG_BLAST) then
 traceworld.start = bleedingentity:GetPos()
 traceworld.fliter = bleedingentity
 else
 traceworld.start = bleedingpos:GetPos()
 traceworld.fliter = bleedingpos
 end
 traceworld.endpos = traceworld.start - (Vector(math.Rand(-1,1),math.Rand(-1,1),1)*1000) 
 local trw = util.TraceLine(traceworld)
 local worldpos1 = trw.HitPos + trw.HitNormal
 local worldpos2 = trw.HitPos - trw.HitNormal
 util.Decal("Blood",worldpos1,worldpos2)
 end
 end
 end)
 timer.Simple(300.1,function() if IsValid(bleedingpos) then bleedingpos:Remove() end if IsValid(bleedingentity) and bleedingentity:GetNetworkedBool("Bleeding")==true then bleedingentity:SetNetworkedBool("Bleeding",false) end end)
 end
 end
 end
hook.Add("EntityTakeDamage" , "StartBleeding" , StartBleeding)

function BleedingStop( player, command, arguments )
if !(BleedingEnableBandagesG:GetBool()) then return end
if player:GetNWInt("bandage_count")>0 and player:Alive() and player:GetNetworkedBool("Bleeding")==true and (player:GetNetworkedFloat("NextBandageuse") < CurTime()) then
player:SetNWBool("Bleeding",false)
player:EmitSound(Sound("bleeding/bandage.wav"))
player:SetNWInt("bandage_count",player:GetNWInt("bandage_count") - 1)
player:SetNetworkedFloat("NextBandageuse",2 + CurTime())
if BleedingMessageG:GetBool() then
player:PrintMessage( HUD_PRINTTALK, "You have " .. player:GetNWInt("bandage_count") .. " bandages.\n"  )
end
timer.Simple(1.01,function()
if IsValid(player) and player:IsPlayer() and player:Alive() and player:GetNetworkedFloat("Disorienttime") > CurTime() then
player:SetNetworkedFloat("Disorienttime", 0 + CurTime())
end
end)
end
end
concommand.Add( "use_bandage", BleedingStop )

function UnTarget()
for k,v in pairs(ents.GetAll()) do
if v:GetClass()=="info_target" and IsValid(v) and v:GetNetworkedBool("Posbleeding")==true and (v:GetParent()==NULL) then
v:Remove()
end
end
end
hook.Add( "Think", "UnTarget", UnTarget )

function UnBleedingOnDeath(victim)
if victim:GetNetworkedBool("Bleeding")==true then
victim:SetNetworkedBool("Bleeding",false)
end
if victim:GetNetworkedFloat("Disorienttime") > CurTime() then
victim:SetNetworkedFloat("Disorienttime", 0 + CurTime())
end
timer.Simple(0.1,function()
if IsValid(victim) and victim:GetNetworkedBool("Bleeding")==true then
victim:SetNetworkedBool("Bleeding",false)
end
if IsValid(victim) and victim:GetNetworkedFloat("Disorienttime") > CurTime() then
victim:SetNetworkedFloat("Disorienttime", 0 + CurTime())
end
end)
end
hook.Add( "PlayerDeath", "UnBleedingOnDeath", UnBleedingOnDeath )

// Written by Hds46.
--2015--