
-- BigDebuffs by Jordon 
-- Backported and general improvements by Konjunktur
-- Spell list and minor improvements by Apparent
local addonName, T = ...
local BigDebuffs = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceEvent-3.0", "AceHook-3.0", "AceTimer-3.0", "AceConsole-3.0")
_G.BigDebuffs = BigDebuffs
T.BigDebuffs = BigDebuffs

-- Debug templates
local ERROR     = 1;
local WARNING   = 2;
local INFO      = 3;
local INFO2     = 4;

-- Defaults
local defaults = {
	global = {
		HFT = 60,
		Debug = true,
	},
	profile = {
		unitFrames = {
			enabled = true,
			cooldownCount = true,
			player = {
				enabled = true,
				anchor = "auto",
				size = 50,
				cdMod = 9,
			},
			focus = {
				enabled = true,
				anchor = "auto",
				size = 50,
				cdMod = 9,
			},
			mouseover = {
				enabled = true,
				anchor = "auto",
				size = 50,
				cdMod = 9,
			},
			target = {
				enabled = true,
				anchor = "auto",
				size = 50,
				cdMod = 9,
			},
			pet = {
				enabled = true,
				anchor = "auto",
				size = 50,
				cdMod = 9,
			},
			party = {
				enabled = true,
				anchor = "auto",
				size = 50,
				cdMod = 9,
			},
			arena = {
				enabled = true,
				anchor = "auto",
				size = 50,
				cdMod = 9,
			},
			cc = true,
			interrupts = true,
			immunities = true,
			immunities_spells = true,
			buffs_defensive = true,
			buffs_offensive = true,
			buffs_other = true,
			roots = true,
		},
		priority = {
			immunities = 90,
			immunities_spells = 80,
			cc = 70,
			interrupts = 60,
			buffs_defensive = 50,
			buffs_offensive = 40,
			buffs_other = 30,
			roots = 20,
		},
		spells = {},
	}
}

BigDebuffs.Constants = {};
local BigDebuffs_C = BigDebuffs.Constants;

local units = {
	"player",
	"pet",
	"target",
	"focus",
	"mouseover",
	"party1",
	"party2",
	"party3",
	"party4",
	"arena1",
	"arena2",
	"arena3",
	"arena4",
	"arena5",
}

local UnitDebuff, UnitBuff = UnitDebuff, UnitBuff

local GetAnchor = {
	ShadowedUnitFrames = function(anchor)
		local frame = _G[anchor]
		if not frame then return end
		if frame.portrait and frame.portrait:IsShown() then
			return frame.portrait, frame
		else
			return frame, frame, true
		end
	end,
	ZPerl = function(anchor)
		local frame = _G[anchor]
		if not frame then return end
		if frame:IsShown() then
			return frame, frame
		else
			frame = frame:GetParent()
			return frame, frame, true
		end
	end,
}

local anchors = {
	["ElvUI"] = {
		noPortrait = true,
		units = {
			player = "ElvUF_Player",
			pet = "ElvUF_Pet",
			target = "ElvUF_Target",
			focus = "ElvUF_Focus",
			party1 = "ElvUF_PartyGroup1UnitButton1",
			party2 = "ElvUF_PartyGroup1UnitButton2",
			party3 = "ElvUF_PartyGroup1UnitButton3",
			party4 = "ElvUF_PartyGroup1UnitButton4",
		},
	},
	["bUnitFrames"] = {
		noPortrait = true,
		alignLeft = true,
		units = {
			player = "bplayerUnitFrame",
			pet = "bpetUnitFrame",
			target = "btargetUnitFrame",
			focus = "bfocusUnitFrame",
			arena1 = "barena1UnitFrame",
			arena2 = "barena2UnitFrame",
			arena3 = "barena3UnitFrame",
			arena4 = "barena4UnitFrame",
		},
	},
	["Shadowed Unit Frames"] = {
		func = GetAnchor.ShadowedUnitFrames,
		units = {
			player = "SUFUnitplayer",
			pet = "SUFUnitpet",
			target = "SUFUnittarget",
			focus = "SUFUnitfocus",
			party1 = "SUFHeaderpartyUnitButton1",
			party2 = "SUFHeaderpartyUnitButton2",
			party3 = "SUFHeaderpartyUnitButton3",
			party4 = "SUFHeaderpartyUnitButton4",
		},
	},
	["ZPerl"] = {
		func = GetAnchor.ZPerl,
		units = {
			player = "XPerl_PlayerportraitFrame",
			pet = "XPerl_Player_PetportraitFrame",
			target = "XPerl_TargetportraitFrame",
			focus = "XPerl_FocusportraitFrame",
			party1 = "XPerl_party1portraitFrame",
			party2 = "XPerl_party2portraitFrame",
			party3 = "XPerl_party3portraitFrame",
			party4 = "XPerl_party4portraitFrame",
		},
	},
	["Blizzard"] = {
		units = {
			player = "PlayerPortrait",
			pet = "PetPortrait",
			target = "TargetFramePortrait",
			focus = "FocusFramePortrait",
			party1 = "PartyMemberFrame1Portrait",
			party2 = "PartyMemberFrame2Portrait",
			party3 = "PartyMemberFrame3Portrait",
			party4 = "PartyMemberFrame4Portrait",
			arena1 = "ArenaEnemyFrame1ClassPortrait",
			arena2 = "ArenaEnemyFrame2ClassPortrait",
			arena3 = "ArenaEnemyFrame3ClassPortrait",
			arena4 = "ArenaEnemyFrame4ClassPortrait",
			arena5 = "ArenaEnemyFrame5ClassPortrait",
		},
	},
}


-- Modules standards configurations {{{

-- Configure default libraries for modules
BigDebuffs:SetDefaultModuleLibraries( "AceConsole-3.0", "AceEvent-3.0")

-- Set the default prototype for modules
BigDebuffs:SetDefaultModulePrototype( {
    OnEnable = function(self) self:Debug(INFO, "prototype OnEnable called!") end,

    OnDisable = function(self) self:Debug(INFO, "prototype OnDisable called!") end,

    OnInitialize = function(self)
        self:Debug(INFO, "prototype OnInitialize called!");
    end,

    Debug = function(self, ...) BigDebuffs.Debug(self, ...) end,

    Error = function(self, m) BigDebuffs.Error (self, m) end,

} )


BigDebuffs.Registry_by_GUID = {
    [true] = {}, -- [guid] = unitInfo_template
    [false] = {}, -- [guid] = unitInfo_template
}

BigDebuffs.Registry_by_Name = {
    [true] = {}, -- [name] = unitInfo_template
    [false] = {}, -- [name] = unitInfo_template
}

function BigDebuffs:BigDebuffs_UNIT_GONE(selfevent, isFriend, unitInfo)
    self.Registry_by_GUID[isFriend][unitInfo.guid]        = nil;
    self.Registry_by_Name[isFriend][unitInfo.name]        = nil;

    -- test if there are others with the same name... *sigh* this sucks
    for guid, unitInfoRecord in pairs (self.Registry_by_GUID[isFriend]) do

        if unitInfoRecord.name == unitInfo.name then
            self.Registry_by_Name[isFriend][unitInfo.name] = unitInfoRecord;

            self:Debug(INFO, "replaced record for", unitInfo.name);

            break;
        end

    end

end

local UnitInRaid                = _G.UnitInRaid;
local UnitInParty               = _G.UnitInParty;
local UnitSetRole               = _G.UnitSetRole;
local UnitGroupRolesAssigned    = _G.UnitGroupRolesAssigned;

function BigDebuffs:BigDebuffs_UNIT_BORN(selfevent, isFriend, unitInfo)

    self:Debug(INFO, "BigDebuffs:BigDebuffs_UNIT_BORN()");

    BigDebuffs.Registry_by_GUID[isFriend][unitInfo.guid] = unitInfo;
    BigDebuffs.Registry_by_Name[isFriend][unitInfo.name] = unitInfo;

end


function BigDebuffs:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New(addonName.."DB", defaults, true)
	
	self:RegisterChatCommand('bd', 'ParseParameters')
	self:RegisterChatCommand(addonName, 'ParseParameters')

	self.db.RegisterCallback(self, "OnProfileChanged", "Refresh")
	self.db.RegisterCallback(self, "OnProfileCopied", "Refresh")
	self.db.RegisterCallback(self, "OnProfileReset", "Refresh")
	self.frames = {}
	self.UnitFrames = {}
	self:SetupOptions()
end

local function HideBigDebuffs(frame)
	if not frame.BigDebuffs then return end
	for i = 1, #frame.BigDebuffs do
		frame.BigDebuffs[i]:Hide()
	end
end

function BigDebuffs:Refresh()
	for unit, frame in pairs(self.UnitFrames) do
		frame:Hide()
		frame.current = nil
		frame.cooldown.noCooldownCount = not self.db.profile.unitFrames.cooldownCount
		self:AttachUnitFrame(unit)
		self:UNIT_AURA(nil, unit)
	end
end

local unitsToUpdate = {}

function BigDebuffs:PLAYER_REGEN_ENABLED()
	for unit, _ in pairs(unitsToUpdate) do
		self:AttachUnitFrame(unit)
	end
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	unitsToUpdate = {}
end

function BigDebuffs:AttachUnitFrame(unit)
	if InCombatLockdown() then 
		unitsToUpdate[unit] = true
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		return 
	end

	local frame = self.UnitFrames[unit]
	local frameName = addonName .. unit .. "UnitFrame"

	if not frame then
		frame = CreateFrame("Button", frameName, UIParent, addonName.."UnitFrameTemplate")
		frame.icon = _G[frameName.."Icon"]
		frame.cooldownContainer = CreateFrame("Button", frameName.."CooldownContainer", frame)
		self.UnitFrames[unit] = frame
		frame.icon:SetDrawLayer("BORDER")
		frame.cooldownContainer:SetPoint("CENTER")
		frame.cooldown:SetParent(frame.cooldownContainer)
		frame.cooldown:SetAllPoints()
		frame.cooldown:SetAlpha(0.9)
		
		frame:RegisterForDrag("LeftButton")
		frame:SetMovable(true)
		frame.unit = unit
	end

	frame:EnableMouse(self.test)

	_G[frameName.."Name"]:SetText(self.test and not frame.anchor and unit)

	frame.anchor = nil
	frame.blizzard = nil

	local config = self.db.profile.unitFrames[unit:gsub("%d", "")]

	if config.anchor == "auto" then
		-- Find a frame to attach to
		for k,v in pairs(anchors) do
			local anchor, parent, noPortrait
			if v.units[unit] then
				if v.func then
					anchor, parent, noPortrait = v.func(v.units[unit])
				else
					anchor = _G[v.units[unit]]
				end

				if anchor then
					frame.anchor, frame.parent, frame.noPortrait = anchor, parent, noPortrait
					if v.noPortrait then frame.noPortrait = true end
					frame.alignLeft = v.alignLeft
					frame.blizzard = k == "Blizzard"
					if not frame.blizzard then break end
				end
			end		
		end
	end

	if frame.anchor then
		if frame.blizzard then
			-- Blizzard Frame
			frame:SetParent(frame.anchor:GetParent())
			frame:SetFrameLevel(frame.anchor:GetParent():GetFrameLevel())
			frame.cooldownContainer:SetFrameLevel(frame.anchor:GetParent():GetFrameLevel()-1)
			frame.cooldownContainer:SetSize(frame.anchor:GetWidth() - config.cdMod, frame.anchor:GetHeight() - config.cdMod)
			frame.anchor:SetDrawLayer("BACKGROUND")
		else
			frame:SetParent(frame.parent and frame.parent or frame.anchor)
			frame:SetFrameLevel(99)
			frame.cooldownContainer:SetSize(frame.anchor:GetWidth(), frame.anchor:GetHeight())
		end

		frame:ClearAllPoints()

		if frame.noPortrait then
			-- No portrait, so attach to the side
			if frame.alignLeft then
				frame:SetPoint("TOPRIGHT", frame.anchor, "TOPLEFT")
			else
				frame:SetPoint("TOPLEFT", frame.anchor, "TOPRIGHT")
			end
			local height = frame.anchor:GetHeight()
			frame:SetSize(height, height)
		else
			frame:SetAllPoints(frame.anchor)
		end
	else
		-- Manual
		frame:SetParent(UIParent)
		frame:ClearAllPoints()
		
		frame:SetSize(config.size, config.size)
		frame.cooldownContainer:SetSize(frame:GetWidth(), frame:GetHeight())
		
		frame:SetFrameLevel(frame:GetParent():GetFrameLevel()+1)
		frame.cooldownContainer:SetFrameLevel(frame:GetParent():GetFrameLevel())
		frame.cooldownContainer:SetSize(frame:GetWidth(), frame:GetHeight())

		if not self.db.profile.unitFrames[unit] then self.db.profile.unitFrames[unit] = {} end

		if self.db.profile.unitFrames[unit].position then
			frame:SetPoint(unpack(self.db.profile.unitFrames[unit].position))
		else
			-- No saved position, anchor to the blizzard position
			LoadAddOn("Blizzard_ArenaUI")
			local relativeFrame = _G[anchors.Blizzard.units[unit]] or UIParent
			frame:SetPoint("CENTER", relativeFrame, "CENTER")
		end
		
	end

end

function BigDebuffs:SaveUnitFramePosition(frame)
	self.db.profile.unitFrames[frame.unit].position = { frame:GetPoint() }
end

function BigDebuffs:Test()
	self.test = not self.test
	self:Refresh()
end

local TestDebuffs = {}

function BigDebuffs:InsertTestDebuff(spellID)
	local texture = select(3, GetSpellInfo(spellID))
	table.insert(TestDebuffs, {spellID, texture})
end

local function UnitDebuffTest(unit, index)
	local debuff = TestDebuffs[index]
	if not debuff then return end
	return GetSpellInfo(debuff[1]), nil, debuff[2], 0, "Magic", 50, GetTime()+50, nil, nil, nil, debuff[1]
end

function BigDebuffs:OnEnable()
	self:RegisterEvent("PLAYER_FOCUS_CHANGED")
	self:RegisterEvent("PLAYER_TARGET_CHANGED")
	self:RegisterEvent("UNIT_PET")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("UNIT_AURA")
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	self:RegisterEvent("UNIT_SPELLCAST_FAILED")

	
    -- Subscribe to our own callbacks
    self:RegisterMessage("BigDebuffs_UNIT_GONE");
    self:RegisterMessage("BigDebuffs_UNIT_BORN");


	self.interrupts = {}

	-- Prevent OmniCC finish animations
	if OmniCC then
		self:RawHook(OmniCC, "TriggerEffect", function(...)
			local _, _, cooldown = ...
			local name = cooldown.GetName and cooldown:GetName()
			if name and name:find(addonName) then return end
			self.hooks[OmniCC].TriggerEffect(...)
		end, true)
	end

	self:InsertTestDebuff(69369) 	-- Predator's Swiftness
end

function BigDebuffs:PLAYER_ENTERING_WORLD()
	for i = 1, #units do
		self:AttachUnitFrame(units[i])
	end
	self.stances = {}
end

-- For unit frames
function BigDebuffs:GetAuraPriority(name, id)
	if not T.Spells[id] and not T.Spells[name] then return end
	
	id = T.Spells[id] and id or name
	
	-- Make sure category is enabled
	if not self.db.profile.unitFrames[T.Spells[id].type] then return end

	-- Check for user set
	if self.db.profile.spells[id] then
		if self.db.profile.spells[id].unitFrames and self.db.profile.spells[id].unitFrames == 0 then return end
		if self.db.profile.spells[id].priority then return self.db.profile.spells[id].priority end
	end

	if T.Spells[id].nounitFrames and (not self.db.profile.spells[id] or not self.db.profile.spells[id].unitFrames) then
		return
	end

	return self.db.profile.priority[T.Spells[id].type] or 0
end

function BigDebuffs:GetUnitFromGUID(guid)
	for _,unit in pairs(units) do
		if UnitGUID(unit) == guid then
			return unit
		end
	end
	return nil
end

function BigDebuffs:UNIT_SPELLCAST_FAILED(_,unit, _, _, spellid)
	local guid = UnitGUID(unit)
	if self.interrupts[guid] == nil then
		self.interrupts[guid] = {}
		BigDebuffs:CancelTimer(self.interrupts[guid].timer)
		self.interrupts[guid].timer = self:ScheduleTimer(function(...)self:ClearInterruptGUID(...)end, 30, guid)
	end
	self.interrupts[guid].failed = GetTime()
end

    --up values
    
    local str_match                 = _G.string.match;
    local GetTime                   = _G.GetTime;

    local pairs                     = _G.pairs;
    local ipairs                    = _G.ipairs;
    local TableWipe                 = _G.table.wipe;
    local TableSort                 = _G.table.sort;


    -- Healer management {{{


    local ReapSchedulers = {};

    local Private_registry_by_GUID = {
        [true] = {}, -- [guid] = unitInfo_template
        [false] = {}, -- [guid] = unitInfo_template
    }

    local Private_registry_by_Name = {
        [true] = {}, -- [name] = unitInfo_template
        [false] = {}, -- [name] = unitInfo_template
    }


    local ReapFriend = {
        [true] = function(guid) BigDebuffs:Reap(guid, true); end,
        [false] = function(guid) BigDebuffs:Reap(guid, false); end,
    };

    local function ApointReaper(guid, isFriend, lifespan)
        if ReapSchedulers[guid] then
            BigDebuffs:CancelTimer(ReapSchedulers[guid]);
        end

        -- Take an apointment with the reaper
        ReapSchedulers[guid] = BigDebuffs:ScheduleTimer(ReapFriend[isFriend], lifespan, guid);
        BigDebuffs:Debug(INFO, "A reap is scheduled in", lifespan, "seconds");
    end

    -- send them to oblivion
    function BigDebuffs:Reap (guid, isFriend, force)

        local corpse = Private_registry_by_GUID[isFriend][guid]; -- keep it safe for autopsy

        if not corpse then
            self:Debug(ERROR, ":Reap() called on non-monitored unit:", guid, isFriend, force);
            return;
        end

        if force then
            BigDebuffs:CancelTimer(ReapSchedulers[guid]);
        end

		-- announce the (un)timely departure of this unitInfo and expose the corpse for all to see
		self:SendMessage("BigDebuffs_UNIT_GONE", isFriend, corpse);
		self:Debug(INFO2, corpse.name, "reaped");
    end

    

    -- Neatly add them to our little registry and keep an eye on them
    local record, name;
    local function RegisterHealer (time, unitInfo, configRef) -- {{{
		local isFriend, guid, sourceName, isHuman, spellName, icon, expires, duration = unpack(unitInfo)

        -- this is a new one, let's create a birth certificate
        if not Private_registry_by_GUID[isFriend][guid] then

            if sourceName then
                name = str_match(sourceName, "^[^-]+");
            else
                -- XXX fatal error out
                BigDebuffs:Debug(WARNING, "RegisterHealer(): sourceName is missing and unitInfo is new", guid);
                return;
            end

            local isUnique;

            if Private_registry_by_Name[isFriend][name] then
                isUnique = false;
            else
                isUnique = true;
            end

            record = {
                guid        = guid,
                name        = name,
				icon		= icon,
                fullName    = sourceName,
                isUnique    = isUnique,
                isHuman     = isHuman,
				start		= expires-duration,
				duration	= duration,
                rank        = -1, -- updated later
                _lastSort   =  0, -- updated later
                lastMove  =  0, -- updated later
            };

            Private_registry_by_GUID[isFriend][guid] = record;
            Private_registry_by_Name[isFriend][name] = record;
            ApointReaper(guid, isFriend, expires-GetTime());

        else
            -- fetch the existing record
            record = Private_registry_by_GUID[isFriend][guid];
			record.icon = icon;
			record.expires = expires;
			record.start = expires-duration
			record.duration = duration
        end
		print(record.icon)
		record.lastMove = time;

        if configRef.Log then -- {{{
            -- also log and keep track of used spells here if option is set
            -- keep in mind that logging can be enabled once a unitInfo has already been registered
            local log;

            if not BigDebuffs.LOGS[isFriend][guid] then
                log = {
                    guid        = guid,
                    name        = name,
                    spells      = {},
                    isFriend    = isFriend,
                    isHuman     = isHuman,
					icon		= icon,
                };

                BigDebuffs.LOGS[isFriend][guid] = log;
            else
                log = BigDebuffs.LOGS[isFriend][guid];
            end

            if not log.spells[spellName] then
                log.spells[spellName] = 1;
            else
                log.spells[spellName] = log.spells[spellName] + 1;
            end

        end -- }}}

        -- Time-consuming operations every 5 seconds minimum
        if time - record._lastSort > 5 then

            record._lastSort = time;

            if not BigDebuffs.Registry_by_GUID[isFriend][guid] then
                -- Dispatch the news
                BigDebuffs:Debug(INFO, "Healer detected:", sourceName);
                BigDebuffs:SendMessage("BigDebuffs_UNIT_BORN", isFriend, record);
            end

            BigDebuffs:SendMessage("BigDebuffs_UNIT_GROW", isFriend, record);
        end

    end -- }}}

    -- }}}



local WARRIOR_STANCES = {
	[71] = true, -- Defensive
	[2457] = true, -- Battle
	[2458] = true, -- Berserker
}

function BigDebuffs:COMBAT_LOG_EVENT_UNFILTERED(_, ...)
	local timeStamp, subEvent, _, sourceGUID, sourceName, _, _, destGUID, destName, _, _, spellid, name = ...

	if subEvent == "SPELL_CAST_SUCCESS" and WARRIOR_STANCES[spellid] then
		self:UpdateStance(sourceGUID, spellid)
	end

	if subEvent ~= "SPELL_CAST_SUCCESS" and subEvent ~= "SPELL_INTERRUPT" then
		--RegisterHealer(GetTime(), true, sourceGUID, sourceName, true, name, true, 9999, {})
		return
	end
		
	-- UnitChannelingInfo and event orders are not the same in WotLK as later expansions, UnitChannelingInfo will always return
	-- nil @ the time of this event (independent of whether something was kicked or not).
	-- We have to track UNIT_SPELLCAST_FAILED for spell failure of the target at the (approx.) same time as we interrupted
	-- this "could" be wrong if the interrupt misses with a <0.01 sec failure window (which depending on server tickrate might
	-- not even be possible)
	if subEvent == "SPELL_CAST_SUCCESS" and not (self.interrupts[destGUID] and 
			self.interrupts[destGUID].failed and GetTime() - self.interrupts[destGUID].failed < 0.01) then
		return
	end
	
	local spelldata = T.Spells[name] and T.Spells[name] or T.Spells[spellid]
	if spelldata == nil or spelldata.type ~= "interrupts" then return end
	local duration = spelldata.interruptduration
   	if not duration then return end
	
	self:UpdateInterrupt(nil, destGUID, spellid, duration)
end

function BigDebuffs:UpdateStance(guid, spellid)
	if self.stances[guid] == nil then
		self.stances[guid] = {}
	else
		self:CancelTimer(self.stances[guid].timer)
	end
	
	self.stances[guid].stance = spellid
	self.stances[guid].timer = self:ScheduleTimer(function(...)self:ClearStanceGUID(...)end, 180, guid)

	local unit = self:GetUnitFromGUID(guid)
	if unit then
		self:UNIT_AURA(nil, unit)
	end
end

function BigDebuffs:ClearStanceGUID(guid)
	local unit = self:GetUnitFromGUID(guid)
	if unit == nil then
		self.stances[guid] = nil
	else
		self.stances[guid].timer = self:ScheduleTimer(function(...)self:ClearStanceGUID(...)end, 180, guid)
	end
end

function BigDebuffs:UpdateInterrupt(unit, guid, spellid, duration)
	local t = GetTime()
	-- new interrupt
	if spellid and duration ~= nil then
		if self.interrupts[guid] == nil then self.interrupts[guid] = {} end
		BigDebuffs:CancelTimer(self.interrupts[guid].timer)
		self.interrupts[guid].timer = BigDebuffs:ScheduleTimer(function(...)self:ClearInterruptGUID(...)end, 30, guid)
		self.interrupts[guid][spellid] = {started = t, duration = duration}
	-- old interrupt expiring
	elseif spellid and duration == nil then
		if self.interrupts[guid] and self.interrupts[guid][spellid] and
				t > self.interrupts[guid][spellid].started + self.interrupts[guid][spellid].duration then
			self.interrupts[guid][spellid] = nil
		end
	end
	
	if unit == nil then
		unit = self:GetUnitFromGUID(guid)
	end
	
	if unit then	
		self:UNIT_AURA(nil, unit)
	end
	-- clears the interrupt after end of duration
	if duration then
		self:ScheduleTimer(function(arg1) self:UpdateInterrupt(unpack(arg1)) end, duration+0.1, {unit, guid, spellid})
	end
end

function BigDebuffs:ClearInterruptGUID(guid)
	self.interrupts[guid] = nil
end

function BigDebuffs:GetInterruptFor(unit)
	local guid = UnitGUID(unit)
	interrupts = self.interrupts[guid]
	if interrupts == nil then return end
	
	local name, spellid, icon, duration, endsAt
	
	-- iterate over all interrupt spellids to find the one of highest duration
	for ispellid, intdata in pairs(interrupts) do
		if type(ispellid) == "number" then
			local tmpstartedAt = intdata.started
			local dur = intdata.duration
			local tmpendsAt = tmpstartedAt + dur
			if GetTime() > tmpendsAt then
				self.interrupts[guid][ispellid] = nil
			elseif endsAt == nil or tmpendsAt > endsAt then
				endsAt = tmpendsAt
				duration = dur
				name, _, icon = GetSpellInfo(ispellid)
				spellid = ispellid
			end
		end
	end
	
	if name then
		return name, spellid, icon, duration, endsAt
	end
end

function BigDebuffs:UNIT_AURA(event, unit)
	if not self.db.profile.unitFrames[unit:gsub("%d", "")] or 
			not self.db.profile.unitFrames[unit:gsub("%d", "")].enabled then 
		return 
	end
	--self:AttachUnitFrame(unit)
	
	local frame = self.UnitFrames[unit]
	if not frame then return end
	
	local UnitDebuff = BigDebuffs.test and UnitDebuffTest or UnitDebuff
	
	local now = GetTime()
	local left, priority, duration, expires, icon, isAura, interrupt = 0, 0
	
	for i = 1, 40 do
		-- Check debuffs
		local n,_, ico, _,_, d, e, caster, _,_, id = UnitDebuff(unit, i)
		
		if id then
			if T.Spells[n] or T.Spells[id] then
				local p = self:GetAuraPriority(n, id)
				if p and (p > priority or (p == prio and expires and e < expires)) then
					left = e - now
					duration = d
					isAura = true
					priority = p
					expires = e
					icon = ico
				end
			end
		else
			break
		end
	end
	
	for i = 1, 40 do
		-- Check buffs
		local n,_, ico, _,_, d, e, _,_,_, id = UnitBuff(unit, i)
		if id then
			if T.Spells[id] then
				local p = self:GetAuraPriority(n, id)
				if p and p >= priority then
					if p and (p > priority or (p == prio and expires and e < expires)) then
						left = e - now
						duration = d
						isAura = true
						priority = p
						expires = e
						icon = ico
					end
				end
			end
		else
			break
		end
	end
	
	local n, id, ico, d, e = self:GetInterruptFor(unit)
	if n then
		local p = self:GetAuraPriority(n, id)
		if p and (p > priority or (p == prio and expires and e < expires)) then
			left = e - now
			duration = d
			isAura = true
			priority = p
			expires = e
			icon = ico
		end
	end

	-- need to always look for a stance (if we only look for it once a player
	-- changes stance we will never get back to it again once other auras fade)
	local guid = UnitGUID(unit)
	if self.stances[guid] then 
		local stanceId = self.stances[guid].stance
		if stanceId and T.Spells[stanceId] then
			n, _, ico = GetSpellInfo(stanceId)
			local p = self:GetAuraPriority(n, stanceId)
			if p and p >= priority then
				left = 0
				duration = 0
				isAura = true
				priority = p
				expires = 0
				icon = ico
			end
		end
	end

	local isFriend = UnitIsFriend("player",unit) == true
	
	if isAura then
		if frame.current ~= icon then
			if frame.blizzard then
				-- Blizzard Frame
				SetPortraitToTexture(frame.icon, icon)
				-- Adapt
				if frame.anchor and Adapt and Adapt.portraits[frame.anchor] then
					Adapt.portraits[frame.anchor].modelLayer:SetFrameStrata("BACKGROUND")
				end
			else
				frame.icon:SetTexture(icon)
			end
		end
		
		if duration >= 1 then
			frame.cooldown:SetCooldown(expires - duration, duration)
			frame.cooldownContainer:Show()
			local unitInfo = {
				isFriend,
				guid,
				UnitName(unit),
				UnitIsPlayer(guid), 
				n,
				icon,
				expires,
				duration
			}
			RegisterHealer(now, unitInfo, {})
		else 
			frame.cooldown:SetCooldown(0, 0)
			frame.cooldownContainer:Hide()
			self:Reap(guid, isFriend)
		end

		frame:Show()
		frame.current = icon
	else
		-- Adapt
		if frame.anchor and frame.blizzard and Adapt and Adapt.portraits[frame.anchor] then
			Adapt.portraits[frame.anchor].modelLayer:SetFrameStrata("LOW")
		else
			frame:Hide()
			frame.current = nil
		end
		
		self:Reap(guid, isFriend)
	end
end

function BigDebuffs:PLAYER_FOCUS_CHANGED()
	self:UNIT_AURA(nil, "focus")
end

function BigDebuffs:PLAYER_TARGET_CHANGED()
	self:UNIT_AURA(nil, "target")
end

function BigDebuffs:UNIT_PET()
	self:UNIT_AURA(nil, "pet")
end

function BigDebuffs:ParseParameters()
	LibStub("AceConfigDialog-3.0"):Open(addonName)
end
