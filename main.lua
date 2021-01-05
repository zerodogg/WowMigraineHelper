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
MigraineHelper = LibStub("AceAddon-3.0"):NewAddon("MigraineHelper","AceEvent-3.0")
local MH = MigraineHelper

-- -----------------
-- UI helper methods
-- -----------------

-- Builds a component of our framing elements
function MH:BuildFrameElement (relativeTo, relativePoint, width, height)
    local Element = self:BuildOverlayElement(relativeTo,relativePoint,width,height)
    -- Add a solid black background
    local bg = Element:CreateTexture();
        -- Size it to cover the entire element
    bg:SetAllPoints(Element);
        -- Make it solid black
    bg:SetColorTexture(0, 0, 0, 1);
    return Element
end

-- Builds a generic overlay element that defaults to hidden
function MH:BuildOverlayElement(relativeTo, relativePoint, width, height) -- luacheck: ignore 212
    -- Create the frame
    local Element = CreateFrame("Frame", nil, UIParent);
    -- Default to hidden
	Element:Hide()
    -- Don't allow the frame to go offscreen
	Element:SetClampedToScreen(true);
    -- Set the placement of the element
	Element:SetPoint(relativeTo, UIParent, relativePoint);
    -- Sizing
	Element:SetWidth(width);
	Element:SetHeight(height);
    -- Don't allow it to be moved
	Element:SetMovable(false);
    -- Ignore all input
	Element:EnableMouse(false)
	Element:EnableKeyboard(false)
    -- Layer it to the background
    Element:SetFrameStrata("BACKGROUND");
    return Element
end

-- ----------------------------
-- Overlay construction methods
-- ----------------------------

-- Constructs the blocker widgets
function MH:BuildBlockers ()
    local width = GetScreenWidth();
    local height = GetScreenHeight();
    local VertBlockWidth = width*WowMigraineHelperConfig.Width;
    local HorizBlockHeight= height*WowMigraineHelperConfig.Height;
    self.MigraineLeft = self:BuildFrameElement("LEFT","LEFT", VertBlockWidth, height);
    self.MigraineRight =self:BuildFrameElement("RIGHT","RIGHT", VertBlockWidth, height);
    self.MigraineTop = self:BuildFrameElement("TOP","TOP",width,HorizBlockHeight);
    self.MigraineBottom = self:BuildFrameElement("BOTTOM","BOTTOM",width,HorizBlockHeight);
end

-- Constructs MigraineOverlay
function MH:BuildOverlay ()
    -- Our overlay should fit over the whole screen
    local width = GetScreenWidth();
    local height = GetScreenHeight();
    -- Create the frame
    self.MigraineOverlay = self:BuildOverlayElement("CENTER","CENTER",width,height);
    -- Add a background
    self.MigraineOverlay.bg = self.MigraineOverlay:CreateTexture();
        -- Size the background to cover all of the overlay
    self.MigraineOverlay.bg:SetAllPoints(self.MigraineOverlay);
        -- Add a black colour with the opacity set in the config
    self.MigraineOverlay.bg:SetColorTexture(0, 0, 0, WowMigraineHelperConfig.OverlayOpacity);
end

-- ---------------------------------------------------------
-- Overlay refresh methods (after config or display changes)
-- ---------------------------------------------------------

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

-- Refreshes the MigraineOverlay
function MH:RefreshMigraineOverlay ()
    self.MigraineOverlay.bg:SetColorTexture(0,0,0, WowMigraineHelperConfig.OverlayOpacity);
end

-- Force-refreshes both when the DISPLAY_SIZE_CHANGED event is received
function MH:DISPLAY_SIZE_CHANGED ()
    self:RefreshMigraineOverlay();
    self:RefreshBlockers();
end

-- ----------------------
-- Overlay toggle methods
-- ----------------------

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

-- ----------------------------------------
-- Initialization and configuration methods
-- ----------------------------------------

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

-- Initialize our config screen
function MH:InitConfigScreen ()  -- luacheck: ignore 212
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
                    name = "These are World of Warcraft configuration options, they are saved when you log out of the game. Changes to these will persist even if you remove the Migraine Helper addon.",
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

-- Initialize events
function MH:InitEvents ()
    -- Register for the DISPLAY_SIZE_CHANGED that will notify us if the
    -- resolution changes (which for us means we need to resize the overlays).
    self:RegisterEvent("DISPLAY_SIZE_CHANGED")
end

-- Main initialization
function MH:OnInitialize ()
    -- Initialize the config variable
    self:InitConfig();
    -- Initialize the config screen
    self:InitConfigScreen();
    -- Initialize event listeners
    self:InitEvents();
    -- Build our blocker overlay elements (hidden by default)
    self:BuildBlockers();
    -- Build our opacity overlay (hidden by default)
    self:BuildOverlay();
    -- Header for our section under keybindings
    BINDING_HEADER_MIGRAINEHELPER = "Migraine Helper";
    -- Names for our keybindings
    BINDING_NAME_TOGGLEMIGRAINEBARS = "Toggle black bars";
    BINDING_NAME_TOGGLEMIGRAINEOVERLAY = "Toggle overlay";
    -- Slash function for toggling the opacity overlay
    SLASH_MIGRAINEDARK1 = "/migrainedark";
    SlashCmdList["MIGRAINEDARK"] = function ()
        MigraineHelper:ToggleOpacityOverlay();
    end;
    -- Slash function for toggling the edge overlay
    SLASH_MIGRAINEEDGE1 = "/migraineedge";
    SlashCmdList["MIGRAINEEDGE"] = function ()
        MigraineHelper:ToggleEdgeOverlay();
    end;
end
