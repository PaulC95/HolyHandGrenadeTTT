SWEP.detonate_timer        = 3   /*This number is seconds from when the grenade is thrown to when the 
                                    sound plays, actual time from grenade activation to detonation is 
                                    this timer + 1.5 seconds */
if SERVER then
   AddCSLuaFile( "weapon_ttt_holyhandgrenade.lua" )
   resource.AddFile("materials/vgui/ttt/icon_holyhandgrenade.png")
   resource.AddFile("sound/holyhandgrenade.wav")
end

SWEP.HoldType = "grenade"


if CLIENT then
   SWEP.PrintName = "Holy Hand Grenade"
   SWEP.Slot = 6
   SWEP.SlotPos	= 0

   SWEP.EquipMenuData = {
      type="Weapon",
      model="models/weapons/w_models/HolyHandGrenade.mdl",
      name="Holy Hand Grenade",
      desc="I think we all know what this does!\nNEW MODEL"
   };

   SWEP.Icon = "vgui/ttt/icon_holyhandgrenade.png"
end

SWEP.Base				= "weapon_tttbasegrenade"

SWEP.WeaponID = AMMO_HOLY
SWEP.CanBuy = {ROLE_TRAITOR}
SWEP.LimitedStock = false
SWEP.Kind = WEAPON_EQUIP

SWEP.Spawnable = true
SWEP.AdminSpawnable = true


SWEP.AutoSpawnable      = true

SWEP.UseHands			= true
SWEP.ViewModelFlip		= false
SWEP.ViewModelFOV		= 54
SWEP.ViewModel			= "models/weapons/c_models/c_HolyHandGrenade.mdl"
SWEP.WorldModel			= "models/weapons/w_models/HolyHandGrenade.mdl"
SWEP.Weight			= 5


function SWEP:GetGrenadeName()
   return "ttt_holyhandgrenade_proj"
end

