if SERVER then
  AddCSLuaFile()
  resource.AddFile("materials/vgui/ttt/dynamic/roles/icon_duel.vmt")
  util.AddNetworkString("ttt2_duelist_inital_message")
  util.AddNetworkString("ttt2_duelist_removed_message")
  util.AddNetworkString("ttt2_duelist_added_message")
  util.AddNetworkString("ttt2_duelist_victory_message")
end

function ROLE:PreInitialize()
  self.color = Color(80, 130, 150, 255)

  self.abbr = "duel"
  self.surviveBonus = 0
  self.scoreKillsMultiplier = 5
  self.scoreTeamKillsMultiplier = -16

  self.defaultEquipment = SPECIAL_EQUIPMENT
  self.defaultTeam = TEAM_NONE

  self.conVarData = {
    pct = 0.17,
    maximum = 1,
    minPlayers = 6,
    togglable = true
  }
end

if SERVER then

  local function CheckDuelists()
    if DUELIST.count == nil then DUELIST.count = 0 end
    if DUELIST.victory_role == nil then DUELIST.victory_role = -1 end

    if DUELIST.count > 0 and DUELIST.victory_role == -1 then
      local tmp = {}
      for _, p in ipairs(player.GetAll()) do
        if not IsValid(p) or not p:IsActive() or not p:IsTerror() then continue end

        if p:GetSubRole() ~= ROLE_DUELIST and not p:IsDeadTerror() then
          tmp[#tmp + 1] = p
        end
      end

      if #tmp > 0 then
        local otherPly = tmp[math.random(1, #tmp)]
        if GetConVar("ttt2_duelist_prize_type"):GetInt() == 2 and ROLE_UNDECIDED then
          DUELIST.victory_role = ROLE_UNDECIDED
        elseif GetConVar("ttt2_duelist_prize_type"):GetInt() == 1 then
          local role_data_list = roles.GetList()
          table.remove(role_data_list, ROLE_NONE)
          DUELIST.victory_role = role_data_list[math.random(1, #role_data_list)].index
        else
          DUELIST.victory_role = otherPly:GetSubRole()
        end
        otherPly:SetRole(ROLE_DUELIST)

        local duelists_names = {}
        for _, p in ipairs(player.GetAll()) do
          if not IsValid(p) or not p:IsActive() or not p:IsTerror() then continue end
          if p:GetSubRole() == ROLE_DUELIST then duelists_names[#duelists_names + 1] = p:GetName() end
        end
        
        for _, p in ipairs(player.GetAll()) do
          if not IsValid(p) or not p:IsActive() or not p:IsTerror() then continue end
          if p:GetSubRole() == ROLE_DUELIST then 
            net.Start("ttt2_duelist_inital_message")
            net.WriteTable(duelists_names)
            net.Send(p)
          end
        end
      else
        for _, p in ipairs(player.GetAll()) do
          if not IsValid(p) or not p:IsActive() or not p:IsTerror() then continue end
          if p:GetSubRole() == ROLE_DUELIST then p:SetRole(ROLE_INNOCENT) end
        end
      end
      SendFullStateUpdate()
    end
  end

  function ROLE:GiveRoleLoadout(ply, isRoleChange)
    ply:GetSubRoleData().isPublicRole = GetConVar("ttt2_duelist_is_public"):GetBool()

    if not ply.active_duelist then
      if DUELIST.count == nil then DUELIST.count = 0 end
      DUELIST.count = DUELIST.count + 1
      ply.active_duelist = true
      if DUELIST.roundStarted then
        local duelists_names = {}

        for _, p in ipairs(player.GetAll()) do
          if not IsValid(p) or not p:IsActive() or not p:IsTerror() then continue end
          if p:GetSubRole() == ROLE_DUELIST then 
            if ply ~= p and p:Alive() then
              net.Start("ttt2_duelist_added_message")
              net.WriteString(ply:GetName())
              net.Send(p)
            end
            duelists_names[#duelists_names + 1] = p:GetName()
          end
        end

        net.Start("ttt2_duelist_inital_message")
        net.WriteTable(duelists_names)
        net.Send(ply)
      end
    end
    if DUELIST.roundStarted then CheckDuelists() end
  end

  function ROLE:RemoveRoleLoadout(ply, isRoleChange) 
    if ply.active_duelist then 
      DUELIST.count = DUELIST.count - 1
      ply.active_duelist = false
      for _, p in ipairs(player.GetAll()) do
        if not IsValid(p) or not p:IsActive() or not p:IsTerror() then continue end
        if p:GetSubRole() == ROLE_DUELIST and ply ~= p and p:Alive() then 
          net.Start("ttt2_duelist_removed_message")
          net.WriteString(ply:GetName())
          net.Send(p)
        end
      end
    end
    if DUELIST.count == 1 then
      for _, p in ipairs(player.GetAll()) do
        if not IsValid(p) or not p:IsActive() or not p:IsTerror() then continue end

        if p.active_duelist then
          p:SetRole(DUELIST.victory_role)
          p:SetHealth(math.max(p:Health(), GetConVar("ttt2_duelist_victory_regenerate"):GetInt()))
          DUELIST.victory_role = -1
          SendFullStateUpdate()
          net.Start("ttt2_duelist_victory_message")
          net.Send(p)
        end
      end
    end
  end

  hook.Add("TTTBeginRound", "DuelistBeginRound", function() 
    CheckDuelists()
    DUELIST.roundStarted = true
  end)

  local function ResetDuelists() 
    if not DUELIST then return end
    DUELIST.victory_role = -1
    DUELIST.count = 0
    DUELIST.roundStarted = false
    for _, p in ipairs(player.GetAll()) do
      if IsValid(p) then p.active_duelist = false end
    end
  end

  hook.Add("TTTEndRound", "DuelistEndRound", ResetDuelists)
  hook.Add("TTTPrepareRound", "DuelistPrepareRound", ResetDuelists)

  hook.Add("TTT2ModifyWinningAlives", "CheckDuelistInGame", function(alives)
    if alives == nil or not GetConVar("ttt2_duelist_prevent_win"):GetBool() then return end

    for _, ply in ipairs(player.GetAll()) do
      if not IsValid(ply) or not ply:Alive() then continue end
			if SpecDM and (ply.IsGhost and ply:IsGhost() or (vics.IsGhost and vics:IsGhost())) then continue end

      if ply:GetSubRole() == ROLE_DUELIST then
        table.insert(alives, "duelist-" .. ply:GetName())
      end
    end
  end)

  hook.Add("EntityTakeDamage", "DuelistTakeDamage", function(target, dmg_info)
    local attacker = dmg_info:GetAttacker()
		if GetRoundState() ~= ROUND_ACTIVE or not IsValid(target) or not target:IsPlayer() or not IsValid(attacker) or not attacker:IsPlayer() then return end
    if GetConVar("ttt2_duelist_immunity"):GetBool() and (target:GetSubRole() == ROLE_DUELIST or attacker:GetSubRole() == ROLE_DUELIST) and target:GetSubRole() ~= attacker:GetSubRole() then 
      dmg_info:SetDamage(0)
    end
  end)
end

if CLIENT then
  net.Receive("ttt2_duelist_inital_message", function()
    EPOP:AddMessage({text = "Duel", color = Color(80, 130, 150, 255)}, {
      text = "To the death!", color = Color(255, 255, 255, 255)}, 5)

    for _, name in ipairs(net.ReadTable()) do
      chat.AddText(Color(80, 130, 150, 255), name, Color(255, 255, 255, 255), " is a Duelist.")
    end
  end)

  net.Receive("ttt2_duelist_added_message", function()
    EPOP:AddMessage({text = "New Duelist", color = Color(80, 130, 150, 255)}, {
      text = "Has joined the fight!", color = Color(255, 255, 255, 255)}, 5)

    chat.AddText(Color(80, 130, 150, 255), net.ReadString(), Color(255, 255, 255, 255), " is now a new Duelist.")
  end)

  net.Receive("ttt2_duelist_removed_message", function()
    chat.AddText(Color(80, 130, 150, 255), net.ReadString(), Color(255, 255, 255, 255), " is no longer a competing Duelist...")
  end)

  net.Receive("ttt2_duelist_victory_message", function()
    EPOP:AddMessage({text = "Victory!", color = Color(80, 130, 150, 255)}, {
      text = "You have won the duel!", color = Color(255, 255, 255, 255)}, 5)
  end)

  function ROLE:AddToSettingsMenu(parent)
		local form = vgui.CreateTTT2Form(parent, "header_roles_additional")

    form:MakeCheckBox({
			serverConvar = "ttt2_duelist_is_public",
			label = "label_duelist_is_public"
		})

    form:MakeCheckBox({
			serverConvar = "ttt2_duelist_prevent_win",
			label = "label_duelist_prevent_win"
		})

    form:MakeCheckBox({
			serverConvar = "ttt2_duelist_immunity",
			label = "label_duelist_immunity"
		})

    form:MakeSlider({
			serverConvar = "ttt2_duelist_prize_type",
			label = "label_duelist_prize_type",
			min = 0,
			max = 2,
			decimal = 0
		})

		form:MakeSlider({
			serverConvar = "ttt2_duelist_victory_regenerate",
			label = "label_duelist_victory_regenerate",
			min = 0,
			max = 200,
			decimal = 0
		})
	end
end