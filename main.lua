-- wow-migraine-helper
--
-- Copyright (C) Eskild Hustvedt 2021
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
MigraineHelper = LibStub("AceAddon-3.0"):NewAddon("MigraineHelper")
local MH = MigraineHelper

-- Builds "blocker" elements (completely black UI elements)
local function BuildBlocker (relativeTo, relativePoint, width, height)
    -- Create the frame
    local Blocker = CreateFrame("Frame", nil, UIParent);
	Blocker:SetClampedToScreen(true);
	Blocker:SetPoint(relativeTo, UIParent, relativePoint);
	Blocker:SetWidth(width);
	Blocker:SetHeight(height);
    -- Don't allow it to be moved
	Blocker:SetMovable(false);
    -- Ignore all input
	Blocker:EnableMouse(false)
	Blocker:EnableKeyboard(false)
    -- Layer it to the background
    Blocker:SetFrameStrata("BACKGROUND");
    -- Default to hidden
	Blocker:Hide()
    -- Add a background
    local bg = Blocker:CreateTexture();
    bg:SetAllPoints(Blocker);
    bg:SetColorTexture(0, 0, 0, 1);
    return Blocker
end

-- Constructs the blocker widgets
function MH:BuildBlockers ()
    local width = GetScreenWidth();
    local height = GetScreenHeight();
    local VertBlockWidth = width*WowMigraineHelperConfig.Width;
    local HorizBlockHeight= height*WowMigraineHelperConfig.Height;
    self.MigraineLeft = BuildBlocker("LEFT","LEFT", VertBlockWidth, height);
    self.MigraineRight =BuildBlocker("RIGHT","RIGHT", VertBlockWidth, height);
    self.MigraineTop = BuildBlocker("TOP","TOP",width,HorizBlockHeight);
    self.MigraineBottom = BuildBlocker("BOTTOM","BOTTOM",width,HorizBlockHeight);
end

-- Refreshes the blocker widgets
function MH:RefreshBlockers ()
    local width = GetScreenWidth();
    local height = GetScreenHeight();
    local VertBlockWidth = width*WowMigraineHelperConfig.Width;
    local HorizBlockHeight= height*WowMigraineHelperConfig.Height;
    self.MigraineLeft:SetWidth(VertBlockWidth);
    self.MigraineRight:SetWidth(VertBlockWidth);
    self.MigraineLeft:SetHeight(height);
    self.MigraineRight:SetHeight(height);

    self.MigraineTop:SetWidth(width);
    self.MigraineBottom:SetWidth(width);
    self.MigraineTop:SetHeight(HorizBlockHeight);
    self.MigraineBottom:SetHeight(HorizBlockHeight);
end

-- Constructs MigraineOverlay
function MH:BuildOverlay ()
    -- Our overlay should fit over the whole screen
    local width = GetScreenWidth();
    local height = GetScreenHeight();
    -- Create the frame
    self.MigraineOverlay = CreateFrame("Frame", "WoWMigraineHelper", UIParent);
	self.MigraineOverlay:SetClampedToScreen(true);
	self.MigraineOverlay:SetPoint("CENTER", UIParent, "CENTER");
	self.MigraineOverlay:SetWidth(width);
	self.MigraineOverlay:SetHeight(height);
    -- Don't allow it to be moved
	self.MigraineOverlay:SetMovable(false);
    -- Ignore all input
	self.MigraineOverlay:EnableMouse(false)
	self.MigraineOverlay:EnableKeyboard(false)
    -- Layer it to the background
    self.MigraineOverlay:SetFrameStrata("BACKGROUND");
    -- Default to hidden
	self.MigraineOverlay:Hide()
    -- Add a background
    self.MigraineOverlay.bg = self.MigraineOverlay:CreateTexture();
    self.MigraineOverlay.bg:SetAllPoints(self.MigraineOverlay);
    self.MigraineOverlay.bg:SetColorTexture(0, 0, 0, WowMigraineHelperConfig.OverlayOpacity);
end

-- Refreshes the MigraineOverlay
function MH:RefreshMigraineOverlay ()
    self.MigraineOverlay.bg:SetColorTexture(0,0,0, WowMigraineHelperConfig.OverlayOpacity);
end

-- Toggles the opacity overlay
function MH:ToggleOpacityOverlay ()
    if self.MigraineOverlay:IsShown() == true then
        self.MigraineOverlay:Hide();
    else
        self:RefreshMigraineOverlay();
        self.MigraineOverlay:Show();
    end
end

-- Toggles the screen-edge overlays
function MH:ToggleEdgeOverlay ()
    if self.MigraineLeft:IsShown() == true then
        self.MigraineLeft:Hide();
        self.MigraineRight:Hide();
        self.MigraineTop:Hide();
        self.MigraineBottom:Hide();
    else
        self:RefreshBlockers();
        self.MigraineLeft:Show();
        self.MigraineRight:Show();
        self.MigraineTop:Show();
        self.MigraineBottom:Show();
    end
end

-- Initialize the config
function MH:InitConfig () -- luacheck: ignore 212
    if WowMigraineHelperConfig == nil then
        WowMigraineHelperConfig = {}
    end
    if WowMigraineHelperConfig.Width == nil then
        WowMigraineHelperConfig.Width = 0.27;
    end
    if WowMigraineHelperConfig.Height == nil then
        WowMigraineHelperConfig.Height = 0.27;
    end
    if WowMigraineHelperConfig.OverlayOpacity == nil then
        WowMigraineHelperConfig.OverlayOpacity = 0.7;
    end
end

-- Main initialization
function MH:OnInitialize ()
    SLASH_MIGRAINEDARK1 = "/migrainedark";
    SlashCmdList["MIGRAINEDARK"] = function ()
        MigraineHelper:ToggleOpacityOverlay();
    end;
    SLASH_MIGRAINEEDGE1 = "/migraineedge";
    SlashCmdList["MIGRAINEEDGE"] = function ()
        MigraineHelper:ToggleEdgeOverlay();
    end;
    self:InitConfig();
    self:BuildBlockers();
    self:BuildOverlay();
    BINDING_HEADER_MIGRAINEHELPER = "Migraine Helper";
    BINDING_NAME_TOGGLEMIGRAINEBARS = "Toggle black bars";
    BINDING_NAME_TOGGLEMIGRAINEOVERLAY = "Toggle overlay";
	AceConfig:RegisterOptionsTable("Migraine Helper", {
			type = "group",
			args = {
                blockerHeader = {
                    name = "Edge blockers",
                    type = "header",
                    order = 0,
                },
				vertWidth = {
                    order = 1,
					name = "Width",
					desc = "Sets the width of the vertical blockers",
					type = "range",
					set = function(info,val) -- luacheck: ignore 212
                        WowMigraineHelperConfig.Width = val;
                        MigraineHelper:RefreshBlockers();
                    end,
					get = function(info) return WowMigraineHelperConfig.Width end, -- luacheck: ignore 212
                    isPercent = true,
                    min = 0.01,
                    max = 0.45,
				},
				horizHeight = {
                    order = 2,
					name = "Height",
					desc = "Sets the height of the horizontal blockers",
					type = "range",
					set = function(info,val) -- luacheck: ignore 212
                        WowMigraineHelperConfig.Height = val;
                        MigraineHelper:RefreshBlockers();
                    end,
					get = function(info) return WowMigraineHelperConfig.Height end, -- luacheck: ignore 212
                    isPercent = true,
                    min = 0.01,
                    max = 0.45,
				},
                opacityHeader = {
                    order = 3,
                    name = "Opacity overlay",
                    type = "header",
                },
                opacity = {
                    order = 4,
                    name = "Opacity of overlay",
                    desc = "The opacity of the dark overlay",
                    type = "range",
                    set = function (info,val) -- luacheck: ignore 212
                        WowMigraineHelperConfig.OverlayOpacity = val;
                        MigraineHelper:RefreshMigraineOverlay();
                    end,
                    get = function (info) return WowMigraineHelperConfig.OverlayOpacity end, -- luacheck: ignore 212
                    min = 0.1,
                    max = 0.99,
                    isPercent = true,
                },
                keyBindingHeader = {
                    order = 5,
                    name = "Key bindings",
                    type = "header",
                },
				blockerKeybinding = {
					desc = "Bind a key to toggle the blockers",
					type = "keybinding",
					name = "Show/hide blockers",
					order = 6,
					width = "double",
					set = function(info,val) -- luacheck: ignore 212
						local b1, b2 = GetBindingKey("TOGGLEMIGRAINEBARS")
						if b1 then SetBinding(b1) end
						if b2 then SetBinding(b2) end
						SetBinding(val, "TOGGLEMIGRAINEBARS")
						SaveBindings(GetCurrentBindingSet())
					end,
					get = function(info) return GetBindingKey("TOGGLEMIGRAINEBARS") end, -- luacheck: ignore 212
				},
                opacityKeybinding = {
                    desc = "Bind a key to toggle the opacity overlay",
                    type = "keybinding",
                    name = "Show/hide opacity overlay",
                    order = 7,
                    width = "double",
					set = function(info,val) -- luacheck: ignore 212
                        local b1, b2 = GetBindingKey("TOGGLEMIGRAINEOVERLAY")
                        if b1 then SetBinding(b1) end
                        if b2 then SetBinding(b2) end
                        SetBinding(val, "TOGGLEMIGRAINEOVERLAY")
                        SaveBindings(GetCurrentBindingSet())
                    end,
                    get = function(info) return GetBindingKey("TOGGLEMIGRAINEOVERLAY") end, -- luacheck: ignore 212
                },
                toggleHeader = {
                    order = 8,
                    name = "Enable/disable",
                    type = "header",
                },
                toggleDescription = {
                    order = 9,
                    type = "description",
                    name = "Note: enabling/disabling the features here will not be permanent. They will still default to off on each login.",
                },
                toggleEdge = {
                    order = 10,
                    type = "toggle",
                    name = "Edge blocker overlay",
                    get = function () return MH.MigraineLeft:IsShown() end,
                    set = function () MH:ToggleEdgeOverlay() end,
                },
                toggleOpacity = {
                    order = 11,
                    type = "toggle",
                    name = "Opacity overlay",
                    get = function () return MH.MigraineOverlay:IsShown() end,
                    set = function () MH:ToggleOpacityOverlay() end,
                },
                wowConfigHeader = {
                    order = 12,
                    name = "WoW Config",
                    type = "header",
                },
                wowConfigDescription = {
                    order = 13,
                    type = "description",
                    name = "These are World of Warcraft configuration options, they are saved when you log out of the game.",
                },
                toggleNether = {
                    order = 14,
                    name = 'Enable the netherworld effect',
                    desc = "Sets the CVar 'ffxNether'",
                    width = "full",
                    type = "toggle",
                    get = function () return GetCVar("ffxNether") == "1" end,
                    set = function (info, val) -- luacheck: ignore 212
                        local noVal = "0";
                        if val == true then
                            noVal = "1";
                        end
                        SetCVar("ffxNether",noVal)
                    end,
                },
                toggleGlow = {
                    order = 15,
                    name = 'Enable full screen glow effects',
                    desc = "Sets the CVar 'ffxGlow'",
                    width = "full",
                    type = "toggle",
                    get = function () return GetCVar("ffxGlow") == "1" end,
                    set = function (info, val) -- luacheck: ignore 212
                        local noVal = "0";
                        if val == true then
                            noVal = "1";
                        end
                        SetCVar("ffxGlow",noVal)
                    end,
                },
                toggleDeathEff = {
                    order = 16,
                    name = 'Enable the full screen death effect',
                    desc = "Sets the CVar 'ffxDeath'",
                    width = "full",
                    type = "toggle",
                    get = function () return GetCVar("ffxDeath") == "1" end,
                    set = function (info, val) -- luacheck: ignore 212
                        local noVal = "0";
                        if val == true then
                            noVal = "1";
                        end
                        SetCVar("ffxDeath",noVal)
                    end,
                },
			},
		}, {"migrainehelper"});
    AceConfigDialog:AddToBlizOptions("Migraine Helper");
end
