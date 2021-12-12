--[=[
HealersHaveToDie World of Warcraft Add-on
Copyright (c) 2009-2010 by John Wellesz (Archarodim@teaser.fr)
All rights reserved

Version 2.0.0

This is a very simple and light add-on that rings when you hover or target a
unit of the opposite faction who healed someone during the last 60 seconds (can
be configured).
Now you can spot those nasty unitInfos instantly and help them to accomplish their destiny!

This add-on uses the Ace3 framework.

type /BigDebuffs to get a list of existing options.

-----
    NamePlateHooker.lua
-----

This component hooks the name plates above characters and adds a sign on top to identifie them as unitInfos


--]=]

--  module framework {{{
local ERROR     = 1;
local WARNING   = 2;
local INFO      = 3;
local INFO2     = 4;


local ADDON_NAME, T = ...;
local BigDebuffs = T.BigDebuffs
local L = BigDebuffs.Localized_Text;
local LNP = LibStub("LibNameplate-1.0");

BigDebuffs.Name_Plate_Hooker = BigDebuffs:NewModule("NPH")
local NPH = BigDebuffs.Name_Plate_Hooker;

local PLATES__NPH_NAMES = {
    [true] = 'BigDebuffs_FriendHealer',
    [false] = 'BigDebuffs_EnemyHealer'
};

local LAST_TEXTURE_UPDATE = 0;

-- upvalues {{{
local GetCVarBool           = _G.GetCVarBool;
local GetTime               = _G.GetTime;
local pairs                 = _G.pairs;
local ipairs                = _G.ipairs;
local CreateFrame           = _G.CreateFrame;
local GetTexCoordsForRole   = _G.GetTexCoordsForRole;
-- }}}

NPH.Debug = BigDebuffs.Debug

function NPH:OnInitialize() -- {{{
    self:Debug(INFO, "OnInitialize called!");
    self.db = BigDebuffs.db:RegisterNamespace('NPH', {
        global = {
            sPve = false,
            marker_Scale = 1,
            marker_Xoffset = 0,
            marker_Yoffset = 0,
        },
    })
end -- }}}

function NPH:GetOptions () -- {{{
    return {
        [NPH:GetName()] = {
            name = L[NPH:GetName()],
            type = 'group',
            get = function (info) return NPH.db.global[info[#info]]; end,
            set = function (info, value) BigDebuffs:SetHandler(self, info, value) end,
            args = {
                Warning1 = {
                    type = 'description',
                    name = BigDebuffs:ColorText(L["OPT_NPH_WARNING1"], "FFFF0000"),
                    hidden = function () return GetCVarBool("nameplateShowEnemies") end,
                    order = 0,
                },
                Warning2 = {
                    type = 'description',
                    name = BigDebuffs:ColorText(L["OPT_NPH_WARNING2"], "FFFF0000"),
                    hidden = function () return GetCVarBool("nameplateShowFriends") end,
                    order = 1,
                },
                sPve = {
                    type = 'toggle',
                    name = L["OPT_STRICTGUIDPVE"],
                    desc = L["OPT_STRICTGUIDPVE_DESC"],
                    disabled = function() return not BigDebuffs.db.global.Pve or not BigDebuffs:IsEnabled(); end,
                    order = 10,
                },
                Header100 = {
                        type = 'header',
                        name = L["OPT_NPH_MARKER_SETTINGS"],
                        order = 15,
                    },
                marker_Scale = {
                        type = "range",
                        name = L["OPT_NPH_MARKER_SCALE"],
                        desc = L["OPT_NPH_MARKER_SCALE_DESC"],
                        min = 0.45,
                        max = 3,
                        softMax = 2,
                        step = 0.01,
                        bigStep = 0.03,
                        order = 20,
                        isPercent = true,

                        set = function (info, value)
                            BigDebuffs:SetHandler(self, info, value);
                            NPH:UpdateTextures();
                        end,
                    },
                    marker_Xoffset = {
                        type = "range",
                        name = L["OPT_NPH_MARKER_X_OFFSET"],
                        desc = L["OPT_NPH_MARKER_X_OFFSET_DESC"],
                        min = -100,
                        max = 100,
                        softMin = -60,
                        softMax = 60,
                        step = 0.01,
                        bigStep = 1,
                        order = 30,

                        set = function (info, value)
                            BigDebuffs:SetHandler(self, info, value);
                            NPH:UpdateTextures();
                        end,
                    },
                    marker_Yoffset = {
                        type = "range",
                        name = L["OPT_NPH_MARKER_Y_OFFSET"],
                        desc = L["OPT_NPH_MARKER_Y_OFFSET_DESC"],
                        min = -100,
                        max = 100,
                        softMin = -60,
                        softMax = 60,
                        step = 0.01,
                        bigStep = 1,
                        order = 30,

                        set = function (info, value)
                            BigDebuffs:SetHandler(self, info, value);
                            NPH:UpdateTextures();
                        end,
                    },
            },
        },
    };
end -- }}}

function NPH:OnEnable() -- {{{
    self:Debug(INFO, "OnEnable");

    if LibStub then
        if (select(2, LibStub:GetLibrary("LibNameplate-1.0"))) < 30 then
            message("The shared library |cFF00FF00LibNameplate-1.0|r is out-dated, version |cFF0077FF1.0.30 (revision 125)|r at least is required. BigDebuffs won't add its symbols over name plates.|r\n");
            self:Debug("LibNameplate-1.0",  LibStub:GetLibrary("LibNameplate-1.0"));
            self:Disable();
            return;
        end
    end

    -- Subscribe to callbacks
    LNP.RegisterCallback(self, "LibNameplate_NewNameplate");
    LNP.RegisterCallback(self, "LibNameplate_RecycleNameplate");
    LNP.RegisterCallback(self, "LibNameplate_FoundGUID");
    
    -- Subscribe to BigDebuffs callbacks
    self:RegisterMessage("BigDebuffs_UNIT_GONE");
    self:RegisterMessage("BigDebuffs_UNIT_BORN");
    self:RegisterMessage("BigDebuffs_UNIT_GROW");

    self:RegisterEvent("PLAYER_ENTERING_WORLD");

end -- }}}

function NPH:OnDisable() -- {{{
    self:Debug(INFO2, "OnDisable");

    LNP.UnregisterCallback(self, "LibNameplate_NewNameplate");
    LNP.UnregisterCallback(self, "LibNameplate_RecycleNameplate");
    LNP.UnregisterCallback(self, "LibNameplate_FoundGUID");

    -- clean all nameplates
    for i, isFriend in ipairs({true,false}) do
        for plateTID, plate in pairs(self.DisplayedPlates_byFrameTID[isFriend]) do
            self:HideCrossFromPlate(plate, isFriend);
        end
    end
end -- }}}
-- }}}



NPH.DisplayedPlates_byFrameTID = { -- used for updating plates dipslay attributes
    [true] = {}, -- for Friendly unitInfos
    [false] = {} -- for enemy unitInfos
};

local Plate_Name_Count = { -- array by name so we have to make the difference between friends and foes
    [true] = {}, -- for Friendly unitInfos
    [false] = {} -- for enemy unitInfos
};
local NP_Is_Not_Unique = { -- array by name so we have to make the difference between friends and foes
    [true] = {}, -- for Friendly unitInfos
    [false] = {} -- for enemy unitInfos
};

local Multi_Plates_byName = {
    [true] = {}, -- for Friendly unitInfos
    [false] = {} -- for enemy unitInfos
};

function NPH:PLAYER_ENTERING_WORLD() -- {{{
    self:Debug(INFO2, "Cleaning multi instanced unitInfos data");
    Plate_Name_Count[true] = {};
    Plate_Name_Count[false] = {};
    NP_Is_Not_Unique[true] = {};
    NP_Is_Not_Unique[false] = {};
    Multi_Plates_byName[true] = {};
    Multi_Plates_byName[false] = {};
end


-- }}}

-- Internal CallBacks (BigDebuffs_UNIT_GONE -- BigDebuffs_UNIT_BORN -- ON_UNIT_PLATE_TOUCH -- BigDebuffs_MOUSE_OVER_OR_TARGET) {{{
function NPH:BigDebuffs_UNIT_GONE(selfevent, isFriend, unitInfo)
    self:Debug(INFO2, "NPH:BigDebuffs_UNIT_GONE", unitInfo.name, unitInfo.guid, isFriend);

    if not isFriend and not GetCVarBool("nameplateShowEnemies") or isFriend and not GetCVarBool("nameplateShowFriends") then
        self:Debug(INFO2, "NPH:BigDebuffs_UNIT_GONE(): bad state, nameplates disabled",  unitInfo.name, unitInfo.guid, isFriend);
        return;
    end

    local plateByName = LNP:GetNameplateByName(unitInfo.name);
    local plateByGuid;
    if self.db.global.sPve then
        plateByGuid = LNP:GetNameplateByGUID(unitInfo.guid);
    end

    local plate = plateByGuid or plateByName;


    if plate then

        -- if we can acces to the plate using its guid or if it's unique
        if plateByGuid or not NP_Is_Not_Unique[isFriend][unitInfo.name] then
            --self:Debug("Must drop", unitInfo.name);
            self:HideCrossFromPlate(plate, isFriend, unitInfo.name);

        elseif not self.db.global.sPve and not BigDebuffs.Registry_by_Name[isFriend][unitInfo.name] then -- Just hide all the symbols on the plates with that name if there is none left

            for plate, plate in pairs (Multi_Plates_byName[isFriend][unitInfo.name]) do
                self:HideCrossFromPlate(plate, isFriend, unitInfo.name);
            end
        end
    else
        self:Debug(INFO2, "BigDebuffs_UNIT_GONE: no plate for", unitInfo.name);
    end
end

function NPH:BigDebuffs_UNIT_GROW (selfevent, isFriend, unitInfo)
    --self:Debug(INFO, 'Updating displayed ranks');
    --self:UpdateRanks();
end

function NPH:BigDebuffs_UNIT_BORN (selfevent, isFriend, unitInfo)

    if not isFriend and not GetCVarBool("nameplateShowEnemies") or isFriend and not GetCVarBool("nameplateShowFriends") then
        return;
    end


    local plateByName = LNP:GetNameplateByName(unitInfo.name);
    local plateByGuid;
    if self.db.global.sPve then
        plateByGuid = LNP:GetNameplateByGUID(unitInfo.guid);
    end

    local plate = plateByGuid or plateByName;

    -- local plateType = LNP:GetType(plate);

    if plate then
        -- we have have access to the correct plate through the unit's GUID or it's uniquely named.
        if plateByGuid or not NP_Is_Not_Unique[isFriend][unitInfo.name] then
            self:AddCrossToPlate (plate, isFriend, unitInfo.name, unitInfo.guid, unitInfo.icon, unitInfo.start, unitInfo.duration);

            self:Debug(INFO, "BigDebuffs_UNIT_BORN(): GUID available or unique", NP_Is_Not_Unique[isFriend][unitInfo.name]);
            self:Debug(WARNING, unitInfo.name, NP_Is_Not_Unique[isFriend][unitInfo.name]);

        elseif not self.db.global.sPve then -- we can only access through its name and we are not in strict pve mode -- when multi pop, it will add the cross to all plates

            for plate, plate in pairs (Multi_Plates_byName[isFriend][unitInfo.name]) do
                self:AddCrossToPlate (plate, isFriend, unitInfo.name, nil, unitInfo.icon, unitInfo.start, unitInfo.duration);

                self:Debug(INFO, "BigDebuffs_UNIT_BORN(): Using name only", unitInfo.name);
            end
        else
            self:Debug(WARNING, "BigDebuffs_UNIT_BORN: multi and sPVE and noguid :'( ", unitInfo.name);
        end
    else
        -- if spve we won't do anything since thee is no way to know the right plate.
        self:Debug(WARNING, "BigDebuffs_UNIT_BORN: no plate for ", unitInfo.name);
        return;
    end
end

-- }}}

-- Lib Name Plates CallBacks {{{
function NPH:LibNameplate_NewNameplate(selfevent, plate)

    local plateName = LNP:GetName(plate);
    local isFriend = (LNP:GetReaction(plate) == "FRIENDLY") and true or false;

    -- test for uniqueness of the nameplate

    if not Plate_Name_Count[isFriend][plateName] then
        Plate_Name_Count[isFriend][plateName] = 1;
    else
        Plate_Name_Count[isFriend][plateName] = Plate_Name_Count[isFriend][plateName] + 1;
        if not NP_Is_Not_Unique[isFriend][plateName] then
            NP_Is_Not_Unique[isFriend][plateName] = true;
            self:Debug(INFO, plateName, "is not unique");
        end
    end

    if not Multi_Plates_byName[isFriend][plateName] then
        Multi_Plates_byName[isFriend][plateName] = {};
    end

    Multi_Plates_byName[isFriend][plateName][plate] = plate;

    -- Check if this name plate is of interest -- XXX
    if BigDebuffs.Registry_by_Name[isFriend][plateName] then
        
        -- If there are several plates with the same name and sPve is set then
        -- we do nothing since there is no way to be sure
        if NP_Is_Not_Unique[isFriend][plateName] and self.db.global.sPve then
            self:Debug(INFO2, "new plate but sPve and not unique");
            return;
        end

        --self:AddCrossToPlate(plate, isFriend, plateName);
    end
end

function NPH:LibNameplate_RecycleNameplate(selfevent, plate)

    local plateName = LNP:GetName(plate);

    for i, isFriend in ipairs({true,false}) do

        self:HideCrossFromPlate(plate, isFriend, plateName);


        -- prevent uniqueness data from stacking
        if Plate_Name_Count[isFriend][plateName] then

            Multi_Plates_byName[isFriend][plateName][plate] = nil;

            Plate_Name_Count[isFriend][plateName] = Plate_Name_Count[isFriend][plateName] - 1;
            if Plate_Name_Count[isFriend][plateName] == 0 then
                Plate_Name_Count[isFriend][plateName] = nil;
            end
        end
    end
end

function NPH:LibNameplate_FoundGUID(selfevent, plate, guid, unitID)
    local unitInfo = BigDebuffs.Registry_by_GUID[true][guid] or BigDebuffs.Registry_by_GUID[false][guid]
    if unitInfo then
        self:Debug(INFO, "GUID found");
        self:AddCrossToPlate(plate, nil, LNP:GetName(plate), guid, unitInfo.icon, unitInfo.start, unitInfo.duration);
    end

end

-- }}}


do
    local SmallFontName = _G.NumberFont_Shadow_Small:GetFont();

    local IsFriend;
    local Plate;
    local PlateAdditions;
    local PlateName;
    local Guid;
    local Icon;
    local Start;
    local Duration;

    local function SetTextureParams(t) -- MUL XXX
        local profile = NPH.db.global;

        t:SetSize(64 * profile.marker_Scale, 64 * profile.marker_Scale);
        t:SetPoint("BOTTOM", Plate, "TOP", 0 + profile.marker_Xoffset, 0 + profile.marker_Yoffset);
    end

    local function CreateCooldown(t)
        print(Icon)
        local container = t:GetParent()
        t:SetTexture(Icon);
        t:SetDrawLayer("BORDER")
        if not t.cooldown then
            t.cooldown = CreateFrame("Cooldown", container:GetName().."CD", container, "CooldownFrameTemplate");
        end
        t.cooldown:SetCooldown(Start, Duration)
        t.cooldown:SetAllPoints(container)
        t.cooldown:SetAlpha(0.9)
    end

    local function MakeTexture() -- ONCE
        local container = CreateFrame("FRAME", PlateName.."container", Plate)
        SetTextureParams(container)
        local t = container:CreateTexture();
        SetTextureParams(t);
        CreateCooldown(t);

        return t;

    end

    local function MakeFontString(symbol) -- ONCE
        local f = Plate:CreateFontString();
        f:SetFont(SmallFontName, 12.2, "THICKOUTLINE, MONOCHROME");
        
        f:SetTextColor(1, 1, 1, 1);
        
        f:SetPoint("CENTER", symbol, "CENTER", 0, 0);

        return f;
    end

    local function UpdateTexture () -- MUL XXX

        if not PlateAdditions.textureUpdate or PlateAdditions.textureUpdate < LAST_TEXTURE_UPDATE then
            --self:Debug('Updating texture');

            SetTextureParams(PlateAdditions.texture);
            CreateCooldown(PlateAdditions.texture)

            PlateAdditions.textureUpdate = GetTime();
        end

    end

    local function AddElements () -- ONCEx
        local texture  = MakeTexture();

        PlateAdditions.texture = texture;
        PlateAdditions.texture:Show();

        PlateAdditions.IsShown = true;

    end

    function NPH:AddCrossToPlate (plate, isFriend, plateName, guid, icon, start, duration) -- {{{
        if not plate then
            self:Debug(ERROR, "AddCrossToPlate(), plate is not defined");
            return false;
        end

        if not plateName then
            self:Debug(ERROR, "AddCrossToPlate(), plateName is not defined");
            return false;
        end

        if isFriend==nil then
            isFriend = (LNP:GetReaction(plate) == "FRIENDLY") and true or false;
            self:Debug(ERROR, "AddCrossToPlate(), isFriend was not defined", isFriend);
        end

        -- export useful data
        IsFriend        = isFriend;
        Icon            = icon;
        Guid            = guid;
        Plate           = plate;
        PlateName       = plateName;
        Start           = start;
        Duration        = duration;
        PlateAdditions  = plate[PLATES__NPH_NAMES[isFriend]];

        if not PlateAdditions then
            plate[PLATES__NPH_NAMES[isFriend]] = {};
            plate[PLATES__NPH_NAMES[isFriend]].isFriend = isFriend;

            PlateAdditions  = plate[PLATES__NPH_NAMES[isFriend]];
            AddElements();

        elseif not PlateAdditions.IsShown then

            UpdateTexture();
            PlateAdditions.texture:Show();
            PlateAdditions.texture.cooldown:Show();
            PlateAdditions.IsShown = true;
        end

        PlateAdditions.plateName = plateName;

        self.DisplayedPlates_byFrameTID[isFriend][plate] = plate;

        --[===[@alpha@
        IsFriend        = nil;
        Guid            = nil;
        Plate           = nil;
        PlateName       = nil;
        PlateAdditions  = nil;
        --@end-alpha@]===]

    end -- }}}

    function NPH:UpdateTextures ()

        LAST_TEXTURE_UPDATE = GetTime();

        for i, isFriend in ipairs({true,false}) do
            for plate in pairs(self.DisplayedPlates_byFrameTID[isFriend]) do

                PlateAdditions  = plate[PLATES__NPH_NAMES[isFriend]];
                Plate           = plate;

                UpdateTexture();

            end
        end

        --[===[@alpha@
        PlateAdditions  = nil;
        PlateName       = nil;
        --@end-alpha@]===]
    end

end

function NPH:HideCrossFromPlate(plate, isFriend, plateName) -- {{{

    if not plate then
        self:Debug(ERROR, "HideCrossFromPlate(), plate is not defined");
        return;
    end

    local plateAdditions = plate[PLATES__NPH_NAMES[isFriend]];

    if plateAdditions and plateAdditions.IsShown then

        --[===[@debug@
        if plateName and plateName ~= plateAdditions.plateName then
            self:Debug(ERROR, "plateAdditions.plateName ~= plateName:", plateAdditions.plateName, plateName);
        end
        --@end-debug@]===]

        plateAdditions.texture:Hide();
        plateAdditions.texture.cooldown:SetCooldown(0,0);
        plateAdditions.texture.cooldown:Hide();
        plateAdditions.IsShown = false;

        plateAdditions.plateName = nil;
        -- self:Debug(INFO2, isFriend and "|cff00ff00Friendly|r" or "|cffff0000Enemy|r", "cross hidden for", plateName);
    end

    self.DisplayedPlates_byFrameTID[isFriend][plate] = nil;

end -- }}}

