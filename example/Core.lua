--[=[
example
--]=]


if not LibStub then
    error("Example requires LibStub");
    return
end

if not LibStub("AceAddon-3.0") then
    error("Example requires AceAddon-3.0");
    return;
end

if not LibStub("CallbackHandler-1.0") then
    error("Example requires CallbackHandler-1.0");
    return;
end

if not LibStub("LibNameplateRegistry-1.0") then
    error("Example requires LibNameplateRegistry-1.0");
    return;
end

local ADDON_NAME, T = ...;

-- Create a new Add-on object using AceAddon
T.Example = LibStub("AceAddon-3.0"):NewAddon("Example", "LibNameplateRegistry-1.0");

-- You could also use LibNameplateRegistry-1.0 directly:
T.Example2 = {};
LibStub("LibNameplateRegistry-1.0"):Embed(T.Example2); -- embedding is optional of course but way more convenient


local Example = T.Example;

function Example:OnEnable()
    -- Subscribe to callbacks
    self:LNR_RegisterCallback("LNR_ON_NEW_PLATE"); -- registering this event will enable the library else it'll remain idle
    self:LNR_RegisterCallback("LNR_ON_RECYCLE_PLATE");
    self:LNR_RegisterCallback("LNR_ON_GUID_FOUND");
    self:LNR_RegisterCallback("LNR_ERROR_FATAL_INCOMPATIBILITY");
end

function Example:OnDisable()
    -- unregister all LibNameplateRegistry callbacks, which will disable it if
    -- your add-on was the only one to use it
    self:LNR_UnregisterAllCallbacks();
end


function Example:LNR_ON_NEW_PLATE(eventname, plateFrame, plateData)
    print(ADDON_NAME, ":", plateData.name, "'s nameplate appeared!");
    print(ADDON_NAME, ":", "It's a", plateData.type, "and", plateData.reaction, plateData.GUID and ("we know its GUID: " .. plateData.GUID) or "GUID not yet known");
end


function Example:LNR_ON_RECYCLE_PLATE(eventname, plateFrame, plateData)
    print(ADDON_NAME, ":", plateData.name, "'s nameplate disappeared!");
end


function Example:LNR_ON_GUID_FOUND(eventname, frame, GUID, findmethod)
    print(ADDON_NAME, ":", "GUID found using", findmethod, "for", self:GetPlateName(frame), "'s nameplate:", GUID);
end


function Example:LNR_ERROR_FATAL_INCOMPATIBILITY(eventname, icompatibilityType)
    -- Here you want to check if your add-on and LibNameplateRegistry are not
    -- outdated (old TOC). if they're both up to date then it means that
    -- another add-on author thinks his add-on is more important than yours. In
    -- this later case you can register LNR_ERROR_SETPARENT_ALERT and
    -- LNR_ERROR_SETSCRIPT_ALERT which will detect such behaviour and will give
    -- you the name of the incompatible add-on so you can inform your users properly
    -- about what's happening instead of just silently "not working".
end



