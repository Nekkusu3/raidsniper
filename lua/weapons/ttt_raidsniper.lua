AddCSLuaFile()
if SERVER then
   util.AddNetworkString("clientpopupopen")
   resource.AddFile("sound/raidsniper1.wav")
   resource.AddFile("sound/raidsniper2.wav")
   resource.AddFile("sound/raidsniper3.wav")
   resource.AddFile("sound/raidsniper4.wav")
   resource.AddFile("sound/raidsniper5.wav")
   resource.AddFile("sound/raidsniper6.wav")
   resource.AddFile("materials/vgui/ttt/raidimage/raid1.png")
   resource.AddFile("materials/vgui/ttt/raidimage/raid2.png")
   resource.AddFile("materials/vgui/ttt/raidimage/raid3.png")
   resource.AddFile("materials/vgui/ttt/icon_raidsniper.vtf")
end
 
 
SWEP.HoldType              = "ar2"
 
if CLIENT then
   SWEP.PrintName          = "Raid Shadow Legends Sniper"
   SWEP.Slot               = 7
 
   SWEP.ViewModelFlip      = false
   SWEP.ViewModelFOV       = 54
 
   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = "Raid Shadow Legends Sniper"
   };
 
   SWEP.Icon               = "VGUI/ttt/icon_raidsniper.vtf"
   SWEP.IconLetter         = "q"
end
 
SWEP.Base                  = "weapon_tttbase"
 
SWEP.Kind                  = WEAPON_EQUIP
SWEP.WeaponID              = AMMO_STUN
SWEP.CanBuy                = {ROLE_TRAITOR, ROLE_DETECTIVE, ROLE_JACKAL, ROLE_SURVIVALIST}
SWEP.LimitedStock          = true
SWEP.AmmoEnt               = "AirboatGun"
 
SWEP.Primary.Damage        = 40
SWEP.Primary.Delay         = 0.5
SWEP.Primary.Cone          = 0
SWEP.Primary.ClipSize      = 10
SWEP.Primary.ClipMax       = 20
SWEP.Primary.DefaultClip   = 20
SWEP.Primary.Automatic     = true
SWEP.Primary.Ammo          = "AirboatGun"
SWEP.Primary.Recoil        = 0.4
SWEP.Primary.Sound         = PrimarySoundRandom

SWEP.Secondary.Delay = 0.3
SWEP.Secondary.Sound = Sound("Default.Zoom")
 
 
SWEP.UseHands              = true
SWEP.ViewModel             = "models/weapons/cstrike/c_snip_g3sg1.mdl"
SWEP.WorldModel            = "models/weapons/w_snip_g3sg1.mdl"
 
SWEP.IronSightsPos         = Vector(-8.735, -10, 4.039)
SWEP.IronSightsAng         = Vector(-1.201, -0.201, -2)
 
SWEP.HeadshotMultiplier    = 2
 
function SWEP:SecondaryAttack()
	if (self.IronSightsPos and self:GetNextSecondaryFire() <= CurTime()) then
		-- set the delay for left and right click
		self:SetNextPrimaryFire(CurTime() + self.Secondary.Delay)
		self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)

		local bIronsights = not self:GetIronsights()
		self:SetIronsights(bIronsights)
		if SERVER then
			self:SetZoom(bIronsights)
		else
			self:EmitSound(self.Secondary.Sound)
		end
	end
end

function SWEP:SetZoom(state)
	if (SERVER and IsValid(self:GetOwner()) and self:GetOwner():IsPlayer()) then
		if (state) then
			self:GetOwner():SetFOV(20, 0.3)
		else
			self:GetOwner():SetFOV(0, 0.2)
		end
	end
end

function SWEP:ResetIronSights()
	self:SetIronsights(false)
	self:SetZoom(false)
end

function SWEP:PreDrop()
	self:ResetIronSights()
	return self.BaseClass.PreDrop(self)
end

function SWEP:Holster()
	self:ResetIronSights()
	return true
end

function SWEP:Reload()
	if ( self:Clip1() == self.Primary.ClipSize or self.Owner:GetAmmoCount( self.Primary.Ammo ) <= 0 ) then return end
    self:DefaultReload( ACT_VM_RELOAD )
    self:SetIronsights( false )
    self:SetZoom( false )
end

-- draw the scope on the HUD
if CLIENT then
	local scope = surface.GetTextureID("sprites/scope")
	function SWEP:DrawHUD()
		if self:GetIronsights() then
			surface.SetDrawColor(0, 0, 0, 255)

			local x = ScrW() / 2.0
			local y = ScrH() / 2.0
			local scope_size = ScrH()

			-- crosshair
			local gap = 80
			local length = scope_size
			surface.DrawLine(x - length, y, x - gap, y)
			surface.DrawLine(x + length, y, x + gap, y)
			surface.DrawLine(x, y - length, x, y - gap)
			surface.DrawLine(x, y + length, x, y + gap)

			gap = 0
			length = 50
			surface.DrawLine(x - length, y, x - gap, y)
			surface.DrawLine(x + length, y, x + gap, y)
			surface.DrawLine(x, y - length, x, y - gap)
			surface.DrawLine(x, y + length, x, y + gap)

			-- cover edges
			local sh = scope_size / 2
			local w = (x - sh) + 2
			surface.DrawRect(0, 0, w, scope_size)
			surface.DrawRect(x + sh - 2, 0, w, scope_size)
			surface.SetDrawColor(255, 0, 0, 255)
			surface.DrawLine(x, y, x + 1, y + 1)

			-- scope
			surface.SetTexture(scope)
			surface.SetDrawColor(255, 255, 255, 255)
			surface.DrawTexturedRectRotated(x, y, scope_size, scope_size, 0)
		else
			return self.BaseClass.DrawHUD(self)
		end
	end

	function SWEP:AdjustMouseSensitivity()
		return (self:GetIronsights() and 0.2) or nil
	end
end
 
function SWEP:ShootBullet( dmg, recoil, numbul, cone )
    PrimarySoundRandomInt = math.random (1,6)
    PrimarySoundRandom = ("raidsniper" .. PrimarySoundRandomInt .. ".wav")
    self:EmitSound(PrimarySoundRandom)
    local sights = self:GetIronsights()
 
 
   numbul = numbul or 1
   cone   = cone   or 0.01
 
   -- 10% accuracy bonus when sighting
   cone = sights and (cone * 0.9) or cone
 
   local bullet = {}
   bullet.Num    = numbul
   bullet.Src    = self:GetOwner():GetShootPos()
   bullet.Dir    = self:GetOwner():GetAimVector()
   bullet.Spread = Vector( cone, cone, 0 )
   bullet.Tracer = 4
   bullet.Force  = 5
   bullet.Damage = dmg
 
 
 
     bullet.Callback = function(att, tr, dmginfo)
                        if SERVER or (CLIENT and IsFirstTimePredicted()) then
                           local ent = tr.Entity
                           if (not tr.HitWorld) and IsValid(ent) then
                              local edata = EffectData()
                              edata:SetEntity(ent)
                              edata:SetMagnitude(3)
                              edata:SetScale(2)                          
                              util.Effect("TeslaHitBoxes", edata)                              
                              if SERVER and ent:IsPlayer() then
                                 PrimarySoundRandomInt = math.random (1,6)
                                 PrimarySoundRandom = ("raidsniper" .. PrimarySoundRandomInt .. ".wav")
                                 ent:EmitSound(PrimarySoundRandom)
                                 net.Start("clientpopupopen")
                                 net.Send(ent)

                              end

                              end
                           end
                        end

   self:GetOwner():FireBullets( bullet )
   self:SendWeaponAnim(self.PrimaryAnim)
 
   -- Owner can die after firebullets, giving an error at muzzleflash
   if not IsValid(self:GetOwner()) or not self:GetOwner():Alive() then return end
 
   self:GetOwner():MuzzleFlash()
   self:GetOwner():SetAnimation( PLAYER_ATTACK1 )
 
   if self:GetOwner():IsNPC() then return end
 
   if ((game.SinglePlayer() and SERVER) or
       ((not game.SinglePlayer()) and CLIENT and IsFirstTimePredicted() )) then
 
      -- reduce recoil if ironsighting
      recoil = sights and (recoil * 0.75) or recoil
 
      local eyeang = self:GetOwner():EyeAngles()
      eyeang.pitch = eyeang.pitch - recoil
      self:GetOwner():SetEyeAngles( eyeang )
    end     

if CLIENT then
   net.Receive("clientpopupopen", function(len , ply)
      local popupnumber = math.random (1,4)
         if popupnumber == 1 then
            local popup1 = vgui.Create("DFrame")
            local pos1 = math.random(1,ScrW()-440)
            local pos2 = math.random(1,ScrH()-414)
            popup1:SetPos(pos1,pos2)
            popup1:SetSize(700,600)
            popup1:ShowCloseButton(false)
            popup1:MakePopup()
            local raidimage1 = vgui.Create("DImage", popup1)
            raidimage1:SetImage("materials/vgui/ttt/raidimage/raid1.png")
            raidimage1:SetPos(0,0)
            raidimage1:SetSize(700,600)              
            local closebutton1 = vgui.Create("DButton", popup1)
            closebutton1:SetSize(150,50)
            --closebutton1:SetPos(280,350)
            local closebutton1random1 = math.random(100, 500)
            local closebutton1random2 = math.random(100, 500)
            closebutton1:SetPos(closebutton1random1,closebutton1random2)
            closebutton1:SetText("Please no RadyShady")
            --new function below for coloring the button, todo
            --closebutton1.Paint = function(s , w , h )
            --run once lol
            --local closebuttoncolor1once = 0
            --if closebuttoncolor1once == 0 then
            --closebuttoncolor1once = 1
            --local closebutton1textrandom1 = math.random(1,255)
            --local closebutton1textrandom2 = math.random(1,255)
            --local closebutton1textrandom3 = math.random(1,255)
            --end
            --draw.RoundedBox(5,0,0, w, h, Color(closebutton1textrandom1,closebutton1textrandom2,closebutton1textrandom3))
            --end   
            closebutton1.DoClick = function()
              popup1:Close()
            end

         elseif popupnumber == 2 then
            local popup2 = vgui.Create("DFrame")
            local pos3 = math.random(1,ScrW()-750)
            local pos4 = math.random(1,ScrH()-795)
            popup2:SetPos(pos3,pos4)
            popup2:SetSize(750,795)
            popup2:ShowCloseButton(false)
            popup2:MakePopup()

            local raidimage2 = vgui.Create("DImage", popup2)
            raidimage2:SetImage("materials/vgui/ttt/raidimage/raid2.png")
            raidimage2:SetPos(0,0)
            raidimage2:SetSize(750,795)          
            local closebutton2 = vgui.Create("DButton" , popup2)
            closebutton2:SetSize(150,100)
            local closebutton2random1 = math.random(100, 500)
            local closebutton2random2 = math.random(100, 500)
            closebutton2:SetPos(closebutton2random1,closebutton2random2)
            closebutton2:SetText("Im broke sorry")
            closebutton2.DoClick = function()
              popup2:Close()
            end



            elseif popupnumber == 3 then
            local popup3 = vgui.Create("DFrame")
            local pos3 = math.random(1,ScrW()-750)
            local pos4 = math.random(1,ScrH()-795)
            popup3:SetPos(pos3,pos4)
            popup3:SetSize(1200,800)
            popup3:ShowCloseButton(false)
            popup3:MakePopup()

            local raidimage3 = vgui.Create("DImage", popup3)
            raidimage3:SetImage("materials/vgui/ttt/raidimage/raid3.png")
            raidimage3:SetPos(0,0)
            raidimage3:SetSize(1200,800)          
            local closebutton3 = vgui.Create("DButton" , popup3)
            closebutton3:SetSize(200,150)
            local closebutton3random1 = math.random(300, 500)
            local closebutton3random2 = math.random(300, 500)
            closebutton3:SetPos(closebutton3random1,closebutton3random2)
            closebutton3:SetText("Raids! Thats good right?")
            closebutton3.DoClick = function()
              popup3:Close()
            end



            elseif popupnumber == 4 then
            local popup4 = vgui.Create("DFrame")
            local pos3 = math.random(1,ScrW()-750)
            local pos4 = math.random(1,ScrH()-795)
            popup4:SetPos(pos3,pos4)
            popup4:SetSize(900,600)
            popup4:ShowCloseButton(false)
            popup4:MakePopup()

            local raidimage4 = vgui.Create("DImage", popup4)
            raidimage4:SetImage("materials/vgui/ttt/raidimage/raid4.png")
            raidimage4:SetPos(0,0)
            raidimage4:SetSize(900,600)          
            local closebutton4 = vgui.Create("DButton" , popup4)
            closebutton4:SetSize(200,150)
            local closebutton4random1 = math.random(200, 400)
            local closebutton4random2 = math.random(200, 400)
            closebutton4:SetPos(closebutton4random1,closebutton4random2)
            closebutton4:SetText("My Wife left me")
            closebutton4.DoClick = function()
              popup4:Close()
            end
         end
      end)   
   end
end