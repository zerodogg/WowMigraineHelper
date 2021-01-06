std = "lua51";

max_line_length = false;

exclude_files = {
    "lib/",
}

globals = {
    -- Ours
    "SLASH_MIGRAINEFRAME1",
    "SLASH_MIGRAINEFRAME2",
    "SLASH_MIGRAINEBRIGHTNESS1",
    "SLASH_MIGRAINEBRIGHTNESS2",
    "BINDING_HEADER_MIGRAINEHELPER",
    "BINDING_NAME_TOGGLEMIGRAINEBARS",
    "BINDING_NAME_TOGGLEMIGRAINEOVERLAY",
    "WowMigraineHelperConfig",
    "MigraineHelper",

    -- From WoW
    "SlashCmdList",
}

read_globals = {
    -- WoW API
    "CreateFrame",
    "UIParent",
    "GetScreenWidth",
    "GetScreenHeight",
    "GetBindingKey",
    "SetBinding",
    "GetCurrentBindingSet",
    "SaveBindings",
    "SetCVar",
    "GetCVar",
    -- Lua
    "LibStub",
}
