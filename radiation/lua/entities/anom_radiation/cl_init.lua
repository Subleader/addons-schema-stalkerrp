ENT.Spawnable			= true
ENT.AdminSpawnable		= true

include('shared.lua')

language.Add( "radiation_damage_haute", "Anomaly" )
language.Add( "point_hurt", "Anomaly" )

local Heatwave = Material("effects/strider_bulge_dudv")

function ENT:Think()
	local mypos = self:GetPos()
	local dist = LocalPlayer():GetPos():Distance(mypos)
	
	if(dist < 1000) then
		LocalPlayer():SetNWBool("disable_bleu", true)
	else
		LocalPlayer():SetNWBool("disable_bleu", false)	
	end
	
	hook.Add("HUDPaint", "HUD_Bleu",function ()
	if (LocalPlayer():GetNWBool("disable_bleu") == true) then
    local tablegod = {}
	tablegod[ "$pp_colour_addr" ] = 0
	tablegod[ "$pp_colour_addg" ] = 0
	tablegod[ "$pp_colour_addb" ] = 0
	tablegod[ "$pp_colour_brightness" ] = -0.05
	tablegod[ "$pp_colour_contrast" ] = 0.95
	tablegod[ "$pp_colour_colour" ] = 0.3
	tablegod[ "$pp_colour_mulr" ] = 0.1
	tablegod[ "$pp_colour_mulg" ] = 0.1
    tablegod[ "$pp_colour_mulb" ] = 0.1
 
    DrawColorModify(tablegod)
			
			
		surface.SetDrawColor(255,255,255,255)
		surface.SetMaterial(Material("hud/rad.png"))
		surface.DrawTexturedRect( ScrW()/1.05, ScrH()/1.25,  33, 35) --Icone clignement	
		
		if (dist < 300) then
		
		surface.SetDrawColor(255,255,255,255)
		surface.SetMaterial(Material("hud/rad4.png"))
		surface.DrawTexturedRect( ScrW()/1.05, ScrH()/1.25,  33, 35) --Icone clignement	
		
		
		elseif (dist < 500) then
		
		surface.SetDrawColor(255,255,255,255)
		surface.SetMaterial(Material("hud/rad3.png"))
		surface.DrawTexturedRect( ScrW()/1.05, ScrH()/1.25,  33, 35) --Icone clignement		
		
		elseif (dist < 700) then
		
		surface.SetDrawColor(255,255,255,255)
		surface.SetMaterial(Material("hud/rad2.png"))
		surface.DrawTexturedRect( ScrW()/1.05, ScrH()/1.25,  33, 35) --Icone clignement	
		
		end

		end
	end )
end

function ENT:OnRemove()
	LocalPlayer():SetNWBool("disable_bleu", false)
end