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
    -- Query WoW for the current game resolution
    local width            = GetScreenWidth();
    local height           = GetScreenHeight();
    -- Calculate the dimensions of the frame
    local VertBlockWidth   = width*WowMigraineHelperConfig.Width;
    local HorizBlockHeight = height*WowMigraineHelperConfig.Height;
    -- Build the framing  elements
    self.FrameLeft         = self:BuildFrameElement("LEFT","LEFT", VertBlockWidth, height);
    self.FrameRight        = self:BuildFrameElement("RIGHT","RIGHT", VertBlockWidth, height);
    self.FrameTop          = self:BuildFrameElement("TOP","TOP",width,HorizBlockHeight);
    self.FrameBottom       = self:BuildFrameElement("BOTTOM","BOTTOM",width,HorizBlockHeight);
end

-- Constructs BrightnessFilterOverlay
function MH:BuildOverlay ()
    -- Query WoW for the current game resolution. The overlay should fit over
    -- the whole screen.
    local width                     = GetScreenWidth();
    local height                    = GetScreenHeight();
    -- Create the frame
    self.BrightnessFilterOverlay    = self:BuildOverlayElement("CENTER","CENTER",width,height);
    -- Add a background texture
    self.BrightnessFilterOverlay.bg = self.BrightnessFilterOverlay:CreateTexture();
        -- Size the background to cover all of the overlay
    self.BrightnessFilterOverlay.bg:SetAllPoints(self.BrightnessFilterOverlay);
    -- Call the refresh function to set the opacity and strata
    self:RefreshBrightnessFilterOverlay();
end


-- ---------------------------------------------------------
-- Overlay refresh methods (after config or display changes)
-- ---------------------------------------------------------

-- Refreshes the framing widgets
function MH:RefreshFrame ()
    -- Query WoW for the current game resolution.
    local width            = GetScreenWidth();
    local height           = GetScreenHeight();
    -- Calculate the size of the frame
    local VertBlockWidth   = width*WowMigraineHelperConfig.Width;
    local HorizBlockHeight = height*WowMigraineHelperConfig.Height;

    -- Size the left and right frame
    self.FrameLeft:SetWidth(VertBlockWidth);
    self.FrameRight:SetWidth(VertBlockWidth);
    self.FrameLeft:SetHeight(height);
    self.FrameRight:SetHeight(height);

    -- Size the top and bottom frame
    self.FrameTop:SetWidth(width);
    self.FrameBottom:SetWidth(width);
    self.FrameTop:SetHeight(HorizBlockHeight);
    self.FrameBottom:SetHeight(HorizBlockHeight);
end

-- Refreshes the BrightnessFilterOverlay
function MH:RefreshBrightnessFilterOverlay ()
    self.BrightnessFilterOverlay.bg:SetColorTexture(0,0,0, WowMigraineHelperConfig.OverlayOpacity);
    if WowMigraineHelperConfig.OverlayIncludeUI then
        -- When including the UI we try as hard as we can to be on top of all
        -- UI elements.
        self.BrightnessFilterOverlay:SetFrameStrata("TOOLTIP")
        self.BrightnessFilterOverlay:SetFrameLevel(10000)
    else
        -- When not including the UI we try as hard as we can to just sit above
        -- the game world, with all of the UI above us
        self.BrightnessFilterOverlay:SetFrameStrata("BACKGROUND")
        self.BrightnessFilterOverlay:SetFrameLevel(0)
    end
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
    local isActive
    if self.BrightnessFilterOverlay:IsShown() == true then
        -- Filter is currently enabled, disable it
        self.BrightnessFilterOverlay:Hide();
        isActive = false
    else
        -- Filter is currently disabled, enable it
        self:RefreshBrightnessFilterOverlay();
        self.BrightnessFilterOverlay:Show();
        isActive = true
    end
    self:RefreshConfigDialog();
    WowMigraineHelperConfig.stateBrightnessFilterEnabled = isActive
end

-- Toggles the screen-edge overlays
function MH:ToggleFrameOverlay ()
    local isActive
    if self.FrameLeft:IsShown() == true then
        -- Frame is currently enabled, disable it
        self.FrameLeft:Hide();
        self.FrameRight:Hide();
        self.FrameTop:Hide();
        self.FrameBottom:Hide();
        isActive = false
    else
        -- Frame is currently disabled, enable it
        self:RefreshFrame();
        self.FrameLeft:Show();
        self.FrameRight:Show();
        self.FrameTop:Show();
        self.FrameBottom:Show();
        isActive = true
    end
    self:RefreshConfigDialog();
    WowMigraineHelperConfig.stateFrameEnabled = isActive
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
    -- Initialize if there's no saved value
    if WowMigraineHelperConfig == nil then
        WowMigraineHelperConfig = {}
    end
    local cfg = WowMigraineHelperConfig;
    -- Reset frame width to 0.27 if there's no value or if the value is invalid
    if cfg.Width == nil or type(cfg.Width) ~= "number" or cfg.Width > 0.99 or cfg.Width < 0.01 then
        cfg.Width = 0.27;
    end
    -- Reset frame height to 0.27 if there's no value or if the value is invalid
    if cfg.Height == nil or type(cfg.Height) ~= "number" or cfg.Height > 0.99 or cfg.Height < 0.01 then
        cfg.Height = 0.27;
    end
    -- Reset brightness filter opacity to 0.7 if there's no value or if the value is invalid
    if cfg.OverlayOpacity == nil or type(cfg.OverlayOpacity) ~= "number" or cfg.OverlayOpacity > 0.95 or cfg.OverlayOpacity < 0.01 then
        cfg.OverlayOpacity = 0.7;
    end
    -- Set the brightness filter to not include the UI if there's no value or the value is invalid
    if type(cfg.OverlayIncludeUI) ~= "boolean" then
        cfg.OverlayIncludeUI = false
    end
    -- Don't remember state if the value is invalid or unset
    if type(cfg.rememberState) ~= "boolean" then
        cfg.rememberState = false
    end
    -- Disable the brightness filter by default if the value is invalid or unset
    if type(cfg.stateBrightnessFilterEnabled) ~= "boolean" then
        cfg.stateBrightnessFilterEnabled = false
    end
    -- Disable the frame overlay by default if the value is invalid or unset
    if type(cfg.stateFrameEnabled) ~= "boolean" then
        cfg.stateFrameEnabled = false
    end
end

-- Restore state if needed
function MH:RestoreState ()
    if WowMigraineHelperConfig.rememberState then
        -- Enable the frame if it was enabled when the user last logged out
        if WowMigraineHelperConfig.stateFrameEnabled then
            self:ToggleFrameOverlay();
        end
        -- Enable the brightness filter if it was enabled the last time the user logged out
        if WowMigraineHelperConfig.stateBrightnessFilterEnabled then
            self:ToggleBrightnessFilter();
        end
    end
end

-- Initialize our config screen
function MH:InitConfigScreen ()  -- luacheck: ignore 212
	AceConfig:RegisterOptionsTable("Migraine Helper", {
			type = "group",
			args = {
                -- Header for the general settings
                generalHeader = {
                    name = "General",
                    type = "header",
                    order = 100,
                },
                -- Enable/disable saving the state
                togglePersistence = {
                    order = 110,
                    type = "toggle",
                    width = "full",
                    name = "Remember enabled filters when logging out",
                    desc = "This will cause Migraine Helper to remember which filters you had enabled the last time you played, and auto-enable them the next time you log in.",
                    get = function () return WowMigraineHelperConfig.rememberState end,
                    set = function (info,val) WowMigraineHelperConfig.rememberState = val end, -- luacheck: ignore 212
                },
                -- Header for the frame settings
                frameHeader = {
                    name = "Screen frame filter",
                    type = "header",
                    order = 200,
                },
                -- Checkbox for the frame overlay
                toggleEdge = {
                    order = 202,
                    type = "toggle",
                    width = "full",
                    name = "Enable the screen frame",
                    desc = "Toggles the screen frame. You may also use the keybinding below or the command /migraineedge.",
                    get = function () return MH.FrameLeft:IsShown() end,
                    set = function () MH:ToggleFrameOverlay() end,
                },
                -- Percentage slider for the width of the vertical framing elements
				vertWidth = {
                    order = 205,
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
                    order = 210,
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
                    order = 300,
                    name = "Brightness filter",
                    type = "header",
                },
                -- Checkbox for the opacity overlay
                toggleOpacity = {
                    order = 303,
                    type = "toggle",
                    width = "double",
                    name = "Enable the brightness filter",
                    desc = "Toggles the brightness filter. You may also use the keybinding below or the command /migrainedark.",
                    get = function () return MH.BrightnessFilterOverlay:IsShown() end,
                    set = function () MH:ToggleBrightnessFilter() end,
                },
                -- Slider for the opacity (strength) of the brightness filter
                brightnessFilter = {
                    order = 305,
                    name = "Filter strength",
                    desc = "The opacity of the brightness filter overlay",
                    type = "range",
                    set = function (info,val) -- luacheck: ignore 212
                        WowMigraineHelperConfig.OverlayOpacity = val;
                        MigraineHelper:RefreshBrightnessFilterOverlay();
                    end,
                    get = function (info) return WowMigraineHelperConfig.OverlayOpacity end, -- luacheck: ignore 212
                    min = 0.1,
                    max = 0.95,
                    isPercent = true,
                },
                -- Toggler for including or excluding UI elements
                brightnessUIOverlay = {
                    order = 310,
                    name = "Reduce the brightness of the UI as well",
                    type = "toggle",
                    width = "double",
                    get = function () return WowMigraineHelperConfig.OverlayIncludeUI end,
                    set = function (info, val) -- luacheck: ignore 212
                        WowMigraineHelperConfig.OverlayIncludeUI = val;
                        MH:RefreshBrightnessFilterOverlay();
                    end,
                },
                -- Header for the key bindings section
                keyBindingHeader = {
                    order = 400,
                    name = "Key bindings",
                    type = "header",
                },
                -- Keybinding for toggling the frame
				frameKeybinding = {
					desc = "Bind a key to toggle the frame",
					type = "keybinding",
					name = "Show/hide frame",
					order = 410,
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
                    order = 420,
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
                -- WoW config values header
                wowConfigHeader = {
                    order = 500,
                    name = "WoW Config",
                    type = "header",
                },
                -- Persistence notice for config options
                wowConfigDescription = {
                    order = 510,
                    type = "description",
                    name = "These are World of Warcraft configuration options, they are saved when you log out of the game. Changes to these will persist even if you remove the Migraine Helper addon.",
                },
                -- ffxNether
                toggleNether = {
                    order = 520,
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
                    order = 530,
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
                    order = 540,
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
    -- Restore state if requested
    self:RestoreState();
    -- Header for our section under keybindings
    BINDING_HEADER_MIGRAINEHELPER = "Migraine Helper";
    -- Names for our keybindings
    BINDING_NAME_TOGGLEMIGRAINEBARS = "Toggle frame";
    BINDING_NAME_TOGGLEMIGRAINEOVERLAY = "Toggle brightness";
    -- Slash function for toggling the brightness filter overlay
    SLASH_MIGRAINEBRIGHTNESS1 = "/migrainebrightness";
    SLASH_MIGRAINEBRIGHTNESS2 = "/migrainedark"; -- Kept for backwards compatibility
    SlashCmdList["MIGRAINEBRIGHTNESS"] = function ()
        MigraineHelper:ToggleBrightnessFilter();
    end;
    -- Slash function for toggling the edge overlay
    SLASH_MIGRAINEFRAME1 = "/migraineframe";
    SLASH_MIGRAINEFRAME2 = "/migraineedge"; -- Kept for backwards compatibility
    SlashCmdList["MIGRAINEFRAME"] = function ()
        MigraineHelper:ToggleFrameOverlay();
    end;
end
