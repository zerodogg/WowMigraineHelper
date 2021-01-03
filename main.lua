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

local MigraineOverlay

local MigraineLeft
local MigraineRight
local MigraineTop
local MigraineBottom

-- Builds "blocker" elements (completely black UI elements)
local function BuildBlocker (relativeTo, relativePoint, width, height)
    -- Create the frame
    Blocker = CreateFrame("Frame", nil, UIParent);
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

-- Constructs MigraineLeft, MigraineRight, MigraineTop, MigraineBottom
local function BuildBlockers ()
    local width = GetScreenWidth();
    local height = GetScreenHeight();
    local VertBlockWidth = width*0.27;
    local HorizBlockHeight= height*0.25;
    MigraineLeft = BuildBlocker("LEFT","LEFT", VertBlockWidth, height);
    MigraineRight = BuildBlocker("RIGHT","RIGHT", VertBlockWidth, height);
    MigraineTop = BuildBlocker("TOP","TOP",width,HorizBlockHeight);
    MigraineBottom = BuildBlocker("BOTTOM","BOTTOM",width,HorizBlockHeight);
end

-- Constructs MigraineOverlay
local function BuildOverlay ()
    -- Our overlay should fit over the whole screen
    local width = GetScreenWidth();
    local height = GetScreenHeight();
    -- Create the frame
    MigraineOverlay = CreateFrame("Frame", "WoWMigraineHelper", UIParent);
	MigraineOverlay:SetClampedToScreen(true);
	MigraineOverlay:SetPoint("CENTER", UIParent, "CENTER");
	MigraineOverlay:SetWidth(width);
	MigraineOverlay:SetHeight(height);
    -- Don't allow it to be moved
	MigraineOverlay:SetMovable(false);
    -- Ignore all input
	MigraineOverlay:EnableMouse(false)
	MigraineOverlay:EnableKeyboard(false)
    -- Layer it to the background
    MigraineOverlay:SetFrameStrata("BACKGROUND");
    -- Default to hidden
	MigraineOverlay:Hide()
    -- Add a background
    local bg = MigraineOverlay:CreateTexture();
    bg:SetAllPoints(MigraineOverlay);
    bg:SetColorTexture(0, 0, 0, 0.7);
end

-- Toggles the opacity overlay
function ToggleMigraineHelperDarkOverlay ()
    if MigraineOverlay:IsShown() == true then
        print "Migraine mode off";
        MigraineOverlay:Hide();
    else
        print "Migraine mode on";
        MigraineOverlay:Show();
    end
end

-- Toggles the screen-edge overlays
function ToggleMigraineHelperEdgeOverlay ()
    if MigraineLeft:IsShown() == true then
        print "Migraine edge mode off";
        MigraineLeft:Hide();
        MigraineRight:Hide();
        MigraineTop:Hide();
        MigraineBottom:Hide();
    else
        print "Migraine edge mode on";
        MigraineLeft:Show();
        MigraineRight:Show();
        MigraineTop:Show();
        MigraineBottom:Show();
    end
end

-- Main initialization
local function main ()
    SLASH_MIGRAINEDARK1 = "/migrainedark";
    SlashCmdList["MIGRAINEDARK"] = ToggleMigraineHelperDarkOverlay;
    SLASH_MIGRAINEEDGE1 = "/migraineedge";
    SlashCmdList["MIGRAINEEDGE"] = ToggleMigraineHelperEdgeOverlay;
    BuildBlockers();
    BuildOverlay();
    BINDING_HEADER_MIGRAINEHELPER = "WoW Migraine Helper";
    BINDING_NAME_TOGGLEMIGRAINEBARS = "Toggle black bars";
    BINDING_NAME_TOGGLEMIGRAINEOVERLAY = "Toggle overlay";
    print "MigraineHelper available: /migraineedge, /migrainedark";
end

main();
