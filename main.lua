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

local MigraineFrame

function BuildOverlay ()
    -- Our overlay should fit over the whole screen
    local width = GetScreenWidth();
    local height = GetScreenHeight();
    -- Create the frame
    MigraineFrame = CreateFrame("Frame", "WoWMigraineHelper", UIParent);
	MigraineFrame:SetClampedToScreen(true);
	MigraineFrame:SetPoint("CENTER", UIParent, "CENTER");
	MigraineFrame:SetWidth(width);
	MigraineFrame:SetHeight(height);
    -- Don't allow it to be moved
	MigraineFrame:SetMovable(false);
    -- Ignore all input
	MigraineFrame:EnableMouse(false)
	MigraineFrame:EnableKeyboard(false)
    -- Layer it to the background
    MigraineFrame:SetFrameStrata("BACKGROUND");
    -- Default to hidden
	MigraineFrame:Hide()
    -- Add a background
    local bg = MigraineFrame:CreateTexture();
    bg:SetAllPoints(MigraineFrame);
    bg:SetColorTexture(0, 0, 0, 0.7);
end

function ToggleFrame ()
    if MigraineFrame:IsShown() == true then
        print "Migraine mode off";
        MigraineFrame:Hide();
    else
        print "Migraine mode on";
        MigraineFrame:Show();
    end
end

function main ()
    SLASH_MIGRAINE1 = "/migraine";
    SlashCmdList["MIGRAINE"] = ToggleFrame;
    BuildOverlay();
end

main();
