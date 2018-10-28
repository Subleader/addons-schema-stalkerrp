killicon.Add( "global_bleeding" , "bleeding/Bleeding", Color( 255, 255, 255, 255 ))
language.Add( "global_bleeding", "Bleeding" )

local BleedingDisorientEnableG = CreateClientConVar("g_bleeding_disorientenable","1",true,false)
local BleedingEnableHudIconG = CreateClientConVar("g_bleeding_enablehudicon","1",true,false)

local function DisorentPlayers()
    if BleedingDisorientEnableG:GetBool() then
	if LocalPlayer():GetNetworkedFloat("Disorienttime") > CurTime() then
			DrawMotionBlur(0.4, 0.8, 0.6)
    end
	end
end
hook.Add("RenderScreenspaceEffects", "DisorentPlayers", DisorentPlayers)

function HUDPaintBleeding()
if BleedingEnableHudIconG:GetBool() and LocalPlayer():GetNetworkedBool("Bleeding")==true then
	surface.SetDrawColor(255,255,255,255)
	surface.SetMaterial(Material("hud/bleed4.png"))
	surface.DrawTexturedRect( ScrW()/1.05, ScrH()/1.45,  33, 35) --Icone clignement	
end
end 
hook.Add("HUDPaint", "HUDPaintBleeding", HUDPaintBleeding )