std = "lua51";

max_line_length = false;

exclude_files = {
    "lib/",
}

globals = {
    -- Ours
    "SLASH_MIGRAINEDARK1",
    "SLASH_MIGRAINEEDGE1",
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
    -- Lua
    "LibStub",
}
