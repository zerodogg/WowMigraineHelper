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
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0");
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

-- Constructs the framing elements
function MH:BuildFrame ()
    local width = GetScreenWidth();
    local height = GetScreenHeight();
    local VertBlockWidth = width*WowMigraineHelperConfig.Width;
    local HorizBlockHeight= height*WowMigraineHelperConfig.Height;
    self.FrameLeft = self:BuildFrameElement("LEFT","LEFT", VertBlockWidth, height);
    self.FrameRight =self:BuildFrameElement("RIGHT","RIGHT", VertBlockWidth, height);
    self.FrameTop = self:BuildFrameElement("TOP","TOP",width,HorizBlockHeight);
    self.FrameBottom = self:BuildFrameElement("BOTTOM","BOTTOM",width,HorizBlockHeight);
end

-- Constructs BrightnessFilterOverlay
function MH:BuildOverlay ()
    -- Our overlay should fit over the whole screen
    local width = GetScreenWidth();
    local height = GetScreenHeight();
    -- Create the frame
    self.BrightnessFilterOverlay = self:BuildOverlayElement("CENTER","CENTER",width,height);
    -- Add a background
    self.BrightnessFilterOverlay.bg = self.BrightnessFilterOverlay:CreateTexture();
        -- Size the background to cover all of the overlay
    self.BrightnessFilterOverlay.bg:SetAllPoints(self.BrightnessFilterOverlay);
        -- Add a black colour with the opacity set in the config
    self.BrightnessFilterOverlay.bg:SetColorTexture(0, 0, 0, WowMigraineHelperConfig.OverlayOpacity);
end

-- ---------------------------------------------------------
-- Overlay refresh methods (after config or display changes)
-- ---------------------------------------------------------

-- Refreshes the framing widgets
function MH:RefreshFrame ()
    local width = GetScreenWidth();
    local height = GetScreenHeight();
    local VertBlockWidth = width*WowMigraineHelperConfig.Width;
    local HorizBlockHeight= height*WowMigraineHelperConfig.Height;
    self.FrameLeft:SetWidth(VertBlockWidth);
    self.FrameRight:SetWidth(VertBlockWidth);
    self.FrameLeft:SetHeight(height);
    self.FrameRight:SetHeight(height);

    self.FrameTop:SetWidth(width);
    self.FrameBottom:SetWidth(width);
    self.FrameTop:SetHeight(HorizBlockHeight);
    self.FrameBottom:SetHeight(HorizBlockHeight);
end

-- Refreshes the BrightnessFilterOverlay
function MH:RefreshBrightnessFilterOverlay ()
    self.BrightnessFilterOverlay.bg:SetColorTexture(0,0,0, WowMigraineHelperConfig.OverlayOpacity);
end

-- Force-refreshes both when the DISPLAY_SIZE_CHANGED event is received
function MH:DISPLAY_SIZE_CHANGED ()
    self:RefreshBrightnessFilterOverlay();
    self:RefreshFrame();
end

-- ----------------------
-- Overlay toggle methods
-- ----------------------

-- Toggles the brightness filter
function MH:ToggleBrightnessFilter ()
    if self.BrightnessFilterOverlay:IsShown() == true then
        self.BrightnessFilterOverlay:Hide();
    else
        self:RefreshBrightnessFilterOverlay();
        self.BrightnessFilterOverlay:Show();
    end
    self:RefreshConfigDialog();
end

-- Toggles the screen-edge overlays
function MH:ToggleFrameOverlay ()
    if self.FrameLeft:IsShown() == true then
        self.FrameLeft:Hide();
        self.FrameRight:Hide();
        self.FrameTop:Hide();
        self.FrameBottom:Hide();
    else
        self:RefreshFrame();
        self.FrameLeft:Show();
        self.FrameRight:Show();
        self.FrameTop:Show();
        self.FrameBottom:Show();
    end
    self:RefreshConfigDialog();
end

-- Notifies AceConfigDialog about changes to config options (ie. the overlays
-- having been toggled)
function MH:RefreshConfigDialog () -- luacheck: ignore 212
    AceConfigRegistry:NotifyChange("Migraine Helper");
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
                -- Header for the frame settings
                frameHeader = {
                    name = "Screen frame",
                    type = "header",
                    order = 0,
                },
                -- Percentage slider for the width of the vertical framing elements
				vertWidth = {
                    order = 1,
					name = "Width",
					desc = "Sets the vertical width of the frame",
					type = "range",
					set = function(info,val) -- luacheck: ignore 212
                        WowMigraineHelperConfig.Width = val;
                        MigraineHelper:RefreshFrame();
                    end,
					get = function(info) return WowMigraineHelperConfig.Width end, -- luacheck: ignore 212
                    isPercent = true,
                    min = 0.01,
                    max = 0.45,
				},
                -- Percentage slider for the height of the horizontal framing elements
				horizHeight = {
                    order = 2,
					name = "Height",
					desc = "Sets the horizontal height of the frame",
					type = "range",
					set = function(info,val) -- luacheck: ignore 212
                        WowMigraineHelperConfig.Height = val;
                        MigraineHelper:RefreshFrame();
                    end,
					get = function(info) return WowMigraineHelperConfig.Height end, -- luacheck: ignore 212
                    isPercent = true,
                    min = 0.01,
                    max = 0.45,
				},
                -- Header for the brightness filter
                brightnessFilterHeader = {
                    order = 3,
                    name = "Brightness filter",
                    type = "header",
                },
                -- Slider for the opacity (strength) of the brightness filter
                brightnessFilter = {
                    order = 4,
                    name = "Filter strength",
                    desc = "The opacity of the brightness filter overlay",
                    type = "range",
                    set = function (info,val) -- luacheck: ignore 212
                        WowMigraineHelperConfig.OverlayOpacity = val;
                        MigraineHelper:RefreshBrightnessFilterOverlay();
                    end,
                    get = function (info) return WowMigraineHelperConfig.OverlayOpacity end, -- luacheck: ignore 212
                    min = 0.1,
                    max = 0.99,
                    isPercent = true,
                },
                -- Header for the key bindings section
                keyBindingHeader = {
                    order = 5,
                    name = "Key bindings",
                    type = "header",
                },
                -- Keybinding for toggling the frame
				frameKeybinding = {
					desc = "Bind a key to toggle the frame",
					type = "keybinding",
					name = "Show/hide frame",
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
                -- Keybinding for toggling the brightness filter
                brightnessFilterKeybinding = {
                    desc = "Bind a key to toggle the brightness filter",
                    type = "keybinding",
                    name = "Enable/disable the brightness filter",
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
                -- Header for the section providing checkboxes for turning either filter on and off
                toggleHeader = {
                    order = 8,
                    name = "Enable/disable",
                    type = "header",
                },
                -- A description for the togglers
                toggleDescription = {
                    order = 9,
                    type = "description",
                    name = "Note: enabling/disabling the features here will not be permanent. They will still default to off on each login.",
                },
                -- Checkbox for the frame overlay
                toggleEdge = {
                    order = 10,
                    type = "toggle",
                    name = "Frame overlay",
                    desc = "Toggles the frame overlay. You may also use the keybinding above or the command /migraineedge.",
                    get = function () return MH.FrameLeft:IsShown() end,
                    set = function () MH:ToggleFrameOverlay() end,
                },
                -- Checkbox for the opacity overlay
                toggleOpacity = {
                    order = 11,
                    type = "toggle",
                    name = "Brightness filter",
                    desc = "Toggles the brightness filter. You may also use the keybinding above or the command /migrainedark.",
                    get = function () return MH.BrightnessFilterOverlay:IsShown() end,
                    set = function () MH:ToggleBrightnessFilter() end,
                },
                -- WoW config values header
                wowConfigHeader = {
                    order = 12,
                    name = "WoW Config",
                    type = "header",
                },
                -- Persistence notice for config options
                wowConfigDescription = {
                    order = 13,
                    type = "description",
                    name = "These are World of Warcraft configuration options, they are saved when you log out of the game. Changes to these will persist even if you remove the Migraine Helper addon.",
                },
                -- ffxNether
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
                -- ffxGlow
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
                -- ffxDeath
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
    -- Generate the config dialog under the interface -> addons panel
    AceConfigDialog:AddToBlizOptions("Migraine Helper");
end

-- Initialize events
function MH:InitEvents ()
    -- Register for the DISPLAY_SIZE_CHANGED event that will notify us if the
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
    -- Build our framing overlay elements (hidden by default)
    self:BuildFrame();
    -- Build our brightness filter overlay (hidden by default)
    self:BuildOverlay();
    -- Header for our section under keybindings
    BINDING_HEADER_MIGRAINEHELPER = "Migraine Helper";
    -- Names for our keybindings
    BINDING_NAME_TOGGLEMIGRAINEBARS = "Toggle black bars";
    BINDING_NAME_TOGGLEMIGRAINEOVERLAY = "Toggle overlay";
    -- Slash function for toggling the brightness filter overlay
    SLASH_MIGRAINEDARK1 = "/migrainedark";
    SlashCmdList["MIGRAINEDARK"] = function ()
        MigraineHelper:ToggleBrightnessFilter();
    end;
    -- Slash function for toggling the edge overlay
    SLASH_MIGRAINEEDGE1 = "/migraineedge";
    SlashCmdList["MIGRAINEEDGE"] = function ()
        MigraineHelper:ToggleFrameOverlay();
    end;
end
