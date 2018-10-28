ITEM.Name = 'Bandage'
ITEM.Price = 300
ITEM.Model = 'models/Items/bandage.mdl'
ITEM.SingleUse = true
ITEM.NoPreview = true
ITEM.Except = false

function ITEM:OnBuy(ply)
local pAng = ply:GetAngles()
pAng.pitch = 0
pAng.roll = pAng.roll + 90
pAng.yaw = pAng.yaw
local ent = ents.Create("item_bandage")
ent:SetModel(self.Model)
ent:SetPos(ply:GetEyeTrace().HitPos)
ent:SetAngles(pAng)
ent:Spawn()
end