﻿local padding = ScreenScale(32)
DEFINE_BASECLASS("ixCharMenuPanel")
local PANEL = {}
function PANEL:Init()
  local parent = self:GetParent()
  local halfWidth = parent:GetWide() * 0.5 - padding * 2
  local halfHeight = parent:GetTall() * 0.5 - padding * 2
  local modelFOV = ScrW() > ScrH() * 1.8 and 100 or 78
  self:ResetPayload(true)
  self.factionButtons = {}
  self.repopulatePanels = {}
  self.containerPanels = {}
  self.factionPanel = self:AddSubpanel("faction", true)
  self.factionPanel:SetTitle("chooseFaction")
  self.factionPanel.OnSetActive = function() if #self.factionButtons == 1 then self:SetActiveSubpanel("description", 0) end end
  local modelList = self.factionPanel:Add("Panel")
  modelList:Dock(RIGHT)
  modelList:SetSize(halfWidth + padding * 2, halfHeight)
  local proceed = modelList:Add("ixMenuButton")
  proceed:SetText("proceed")
  proceed:SetContentAlignment(6)
  proceed:Dock(BOTTOM)
  proceed:SizeToContents()
  proceed.DoClick = function()
    self.progress:IncrementProgress()
    self:Populate()
    self:SetActiveSubpanel("description")
  end

  self.factionModel = modelList:Add("ixModelPanel")
  self.factionModel:Dock(FILL)
  self.factionModel:SetModel("models/error.mdl")
  self.factionModel:SetFOV(modelFOV)
  self.factionModel.PaintModel = self.factionModel.Paint
  self.factionButtonsPanel = self.factionPanel:Add("ixCharMenuButtonList")
  self.factionButtonsPanel:SetWide(halfWidth)
  self.factionButtonsPanel:Dock(FILL)
  local factionBack = self.factionPanel:Add("ixMenuButton")
  factionBack:SetText("return")
  factionBack:SizeToContents()
  factionBack:Dock(BOTTOM)
  factionBack.DoClick = function()
    self.progress:DecrementProgress()
    self:SetActiveSubpanel("faction", 0)
    self:SlideDown()
    parent.mainPanel:Undim()
  end

  self.description = self:AddSubpanel("description")
  self.description:SetTitle("chooseDescription")
  local descriptionModelList = self.description:Add("Panel")
  descriptionModelList:Dock(LEFT)
  descriptionModelList:SetSize(halfWidth, halfHeight)
  local descriptionBack = descriptionModelList:Add("ixMenuButton")
  descriptionBack:SetText("return")
  descriptionBack:SetContentAlignment(4)
  descriptionBack:SizeToContents()
  descriptionBack:Dock(BOTTOM)
  descriptionBack.DoClick = function()
    self.progress:DecrementProgress()
    if #self.factionButtons == 1 then
      factionBack:DoClick()
    else
      self:SetActiveSubpanel("faction")
    end
  end

  self.descriptionModel = descriptionModelList:Add("ixModelPanel")
  self.descriptionModel:Dock(FILL)
  self.descriptionModel:SetModel(self.factionModel:GetModel())
  self.descriptionModel:SetFOV(modelFOV - 13)
  self.descriptionModel.PaintModel = self.descriptionModel.Paint
  self.descriptionPanel = self.description:Add("Panel")
  self.descriptionPanel:SetWide(halfWidth + padding * 2)
  self.descriptionPanel:Dock(RIGHT)
  local descriptionProceed = self.descriptionPanel:Add("ixMenuButton")
  descriptionProceed:SetText("proceed")
  descriptionProceed:SetContentAlignment(6)
  descriptionProceed:SizeToContents()
  descriptionProceed:Dock(BOTTOM)
  descriptionProceed.DoClick = function()
    if self:VerifyProgression("description") then
      if #self.attributesPanel:GetChildren() < 2 then
        self:SendPayload()
        return
      end

      self.progress:IncrementProgress()
      self:SetActiveSubpanel("background")
    end
  end

  self.containerPanels["description"] = self.descriptionPanel
  self.background = self:AddSubpanel("background")
  self.background:SetTitle("chooseBackground")
  self.backgroundList = self.background:Add("Panel")
  self.backgroundList:SetSize(halfWidth, halfHeight)
  self.backgroundList:Dock(LEFT)
  local backgroundBack = self.backgroundList:Add("ixMenuButton")
  backgroundBack:SetText("return")
  backgroundBack:SetContentAlignment(4)
  backgroundBack:SizeToContents()
  backgroundBack:Dock(BOTTOM)
  backgroundBack.DoClick = function()
    self.progress:DecrementProgress()
    self:SetActiveSubpanel("description")
  end

  self.backgroundPanel = self.background:Add("Panel")
  self.backgroundPanel:SetWide(halfWidth + padding * 2)
  self.backgroundPanel:Dock(RIGHT)
  local backgroundProceed = self.backgroundPanel:Add("ixMenuButton")
  backgroundProceed:SetText("proceed")
  backgroundProceed:SetContentAlignment(6)
  backgroundProceed:SizeToContents()
  backgroundProceed:Dock(BOTTOM)
  backgroundProceed.DoClick = function()
    self.progress:IncrementProgress()
    self:SetActiveSubpanel("attributes")
  end

  self.containerPanels["backgrounds"] = self.backgroundList
  self.containerPanels["traits"] = self.backgroundPanel
  self.attributes = self:AddSubpanel("attributes")
  self.attributes:SetTitle("chooseSkills")
  local attributesModelList = self.attributes:Add("Panel")
  attributesModelList:Dock(LEFT)
  attributesModelList:SetSize(halfWidth, halfHeight)
  local attributesBack = attributesModelList:Add("ixMenuButton")
  attributesBack:SetText("return")
  attributesBack:SetContentAlignment(4)
  attributesBack:SizeToContents()
  attributesBack:Dock(BOTTOM)
  attributesBack.DoClick = function()
    self.progress:DecrementProgress()
    self:SetActiveSubpanel("background")
  end

  self.attributesModel = attributesModelList:Add("ixModelPanel")
  self.attributesModel:Dock(FILL)
  self.attributesModel:SetModel(self.factionModel:GetModel())
  self.attributesModel:SetFOV(modelFOV - 13)
  self.attributesModel.PaintModel = self.attributesModel.Paint
  self.attributesPanel = self.attributes:Add("Panel")
  self.attributesPanel:SetWide(halfWidth + padding * 2)
  self.attributesPanel:Dock(RIGHT)
  local create = self.attributesPanel:Add("ixMenuButton")
  create:SetText("finish")
  create:SetContentAlignment(6)
  create:SizeToContents()
  create:Dock(BOTTOM)
  create.DoClick = function() self:SendPayload() end
  self.attributesScrollPanel = self.attributesPanel:Add("DScrollPanel")
  self.attributesScrollPanel:Dock(FILL)
  self.containerPanels["attributes"] = self.attributesScrollPanel
  self.progress = self:Add("ixSegmentedProgress")
  self.progress:SetBarColor(ix.config.Get("color"))
  self.progress:SetSize(parent:GetWide(), 0)
  self.progress:SizeToContents()
  self.progress:SetPos(0, parent:GetTall() - self.progress:GetTall())
  self:AddPayloadHook("model", function(value)
    local faction = ix.faction.indices[self.payload.faction]
    if faction then
      local model = faction:GetModels(LocalPlayer())[value]
      if istable(model) then
        self.factionModel:SetModel(model[1], model[2] or 0, model[3])
        self.descriptionModel:SetModel(model[1], model[2] or 0, model[3])
        self.attributesModel:SetModel(model[1], model[2] or 0, model[3])
      else
        self.factionModel:SetModel(model)
        self.descriptionModel:SetModel(model)
        self.attributesModel:SetModel(model)
      end
    end
  end)

  net.Receive("ixCharacterAuthed", function()
    timer.Remove("ixCharacterCreateTimeout")
    self.awaitingResponse = false
    local id = net.ReadUInt(32)
    local indices = net.ReadUInt(6)
    local charList = {}
    for _ = 1, indices do
      charList[#charList + 1] = net.ReadUInt(32)
    end

    ix.characters = charList
    self:SlideDown()
    if not IsValid(self) or not IsValid(parent) then return end
    if LocalPlayer():GetCharacter() then
      parent.mainPanel:Undim()
      parent:ShowNotice(2, L("charCreated"))
    elseif id then
      self.bMenuShouldClose = true
      net.Start("ixCharacterChoose")
      net.WriteUInt(id, 32)
      net.SendToServer()
    else
      self:SlideDown()
    end
  end)

  net.Receive("ixCharacterAuthFailed", function()
    timer.Remove("ixCharacterCreateTimeout")
    self.awaitingResponse = false
    local fault = net.ReadString()
    local args = net.ReadTable()
    self:SlideDown()
    parent.mainPanel:Undim()
    parent:ShowNotice(3, L(fault, unpack(args)))
  end)
end

function PANEL:SendPayload()
  if self.awaitingResponse or not self:VerifyProgression() then return end
  self.awaitingResponse = true
  timer.Create("ixCharacterCreateTimeout", 10, 1, function()
    if IsValid(self) and self.awaitingResponse then
      local parent = self:GetParent()
      self.awaitingResponse = false
      self:SlideDown()
      parent.mainPanel:Undim()
      parent:ShowNotice(3, L("unknownError"))
    end
  end)

  self.payload:Prepare()
  net.Start("ixCharacterCreate")
  net.WriteUInt(table.Count(self.payload), 8)
  for k, v in pairs(self.payload) do
    net.WriteString(k)
    net.WriteType(v)
  end

  net.SendToServer()
end

function PANEL:OnSlideUp()
  self:ResetPayload()
  self:Populate()
  self.progress:SetProgress(1)
  self:SetActiveSubpanel("faction", 0)
end

function PANEL:OnSlideDown()
end

function PANEL:ResetPayload(bWithHooks)
  if bWithHooks then self.hooks = {} end
  self.payload = {}
  function self.payload.Set(payload, key, value)
    self:SetPayload(key, value)
  end

  function self.payload.AddHook(payload, key, callback)
    self:AddPayloadHook(key, callback)
  end

  function self.payload.Prepare(payload)
    self.payload.Set = nil
    self.payload.AddHook = nil
    self.payload.Prepare = nil
  end
end

function PANEL:SetPayload(key, value)
  self.payload[key] = value
  self:RunPayloadHook(key, value)
end

function PANEL:AddPayloadHook(key, callback)
  if not self.hooks[key] then self.hooks[key] = {} end
  self.hooks[key][#self.hooks[key] + 1] = callback
end

function PANEL:RunPayloadHook(key, value)
  local hooks = self.hooks[key] or {}
  for _, v in ipairs(hooks) do
    v(value)
  end
end

function PANEL:GetContainerPanel(name)
  if self.containerPanels[name] then return self.containerPanels[name] end
  return self.descriptionPanel
end

function PANEL:AttachCleanup(panel)
  self.repopulatePanels[#self.repopulatePanels + 1] = panel
end

function PANEL:Populate()
  if not self.bInitialPopulate then
    local lastSelected
    for _, v in pairs(self.factionButtons) do
      if v:GetSelected() then lastSelected = v.faction end
      if IsValid(v) then v:Remove() end
    end

    self.factionButtons = {}
    for _, v in SortedPairs(ix.faction.teams) do
      if ix.faction.HasWhitelist(v.index) then
        local button = self.factionButtonsPanel:Add("ixMenuSelectionButton")
        button:SetBackgroundColor(v.color or color_white)
        button:SetText(L(v.name):utf8upper())
        button:SizeToContents()
        button:SetButtonList(self.factionButtons)
        button.faction = v.index
        button.OnSelected = function(panel)
          local faction = ix.faction.indices[panel.faction]
          local models = faction:GetModels(LocalPlayer())
          self.payload:Set("faction", panel.faction)
          self.payload:Set("model", math.random(1, #models))
        end

        if lastSelected and lastSelected == v.index or not lastSelected and v.isDefault then button:SetSelected(true) end
      end
    end
  end

  for i = 1, #self.repopulatePanels do
    self.repopulatePanels[i]:Remove()
  end

  self.repopulatePanels = {}
  if not self.payload.faction then
    for _, v in pairs(self.factionButtons) do
      if v:GetSelected() then
        v:SetSelected(true)
        break
      end
    end
  end

  self.factionButtonsPanel:SizeToContents()
  local zPos = 1
  for k, v in SortedPairsByMemberValue(ix.char.vars, "index") do
    if not v.bNoDisplay and k ~= "__SortedIndex" then
      local container = self:GetContainerPanel(v.category or "description")
      if v.ShouldDisplay and v:ShouldDisplay(container, self.payload) == false then continue end
      local panel
      if v.OnDisplay then
        panel = v:OnDisplay(container, self.payload)
      elseif isstring(v.default) then
        panel = container:Add("ixTextEntry")
        panel:Dock(TOP)
        panel:SetFont("ixMenuButtonHugeFont")
        panel:SetUpdateOnType(true)
        panel.OnValueChange = function(this, text) self.payload:Set(k, text) end
      end

      if IsValid(panel) then
        local label = container:Add("DLabel")
        label:SetFont("ixMenuButtonLabelFont")
        label:SetText(L(k):utf8upper())
        label:SizeToContents()
        label:DockMargin(0, 16, 0, 2)
        label:Dock(TOP)
        label:SetZPos(zPos - 1)
        panel:SetZPos(zPos)
        self:AttachCleanup(label)
        self:AttachCleanup(panel)
        if v.OnPostSetup then v:OnPostSetup(panel, self.payload) end
        zPos = zPos + 2
      end
    end
  end

  if not self.bInitialPopulate then
    if #self.factionButtons > 1 then self.progress:AddSegment("@faction") end
    self.progress:AddSegment("@description")
    if #self.backgroundPanel:GetChildren() > 1 then self.progress:AddSegment("@background") end
    if #self.attributesPanel:GetChildren() > 1 then self.progress:AddSegment("@skills") end
    if #self.progress:GetSegments() == 1 then self.progress:SetVisible(false) end
  end

  self.bInitialPopulate = true
end

function PANEL:VerifyProgression(name)
  for k, v in SortedPairsByMemberValue(ix.char.vars, "index") do
    if name ~= nil and (v.category or "description") ~= name then continue end
    local value = self.payload[k]
    if not v.bNoDisplay or v.OnValidate then
      if v.OnValidate then
        local result = {v:OnValidate(value, self.payload, LocalPlayer())}
        if result[1] == false then
          self:GetParent():ShowNotice(3, L(unpack(result, 2)))
          return false
        end
      end

      self.payload[k] = value
    end
  end
  return true
end

function PANEL:Paint(width, height)
  derma.SkinFunc("PaintCharacterCreateBackground", self, width, height)
  BaseClass.Paint(self, width, height)
end

vgui.Register("ixCharMenuNew", PANEL, "ixCharMenuPanel")
