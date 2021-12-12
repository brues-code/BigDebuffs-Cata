
-- BigDebuffs by Jordon 
-- Backported and general improvements by Konjunktur
-- Spell list and minor improvements by Apparent
local addonName, T = ...
BigDebuffs = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceEvent-3.0", "AceHook-3.0", "AceTimer-3.0", "AceConsole-3.0")
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

BigDebuffs.Spells = {
	-- Death Knight
	[48792] = { type = "buffs_defensive", },  -- Icebound Fortitude
	[50461] = { type = "buffs_defensive", },  -- Anti-Magic Zone
	[47484] = { type = "buffs_defensive", }, -- Huddle (Ghoul)
	[49028] = { type = "buffs_offensive", },  -- Dancing Rune Weapon // might not work - spell id vs aura
	[47476] = { type = "cc", },  -- Strangulate
	[47481] = { type = "cc", },  -- Gnaw
	[49203] = { type = "cc", }, -- Hungering Cold
	[48707] = { type = "immunities_spells", },  -- Anti-Magic Shell
	[49039] = { type = "immunities_spells", },  -- Lichborne
	[53550] = { type = "interrupts", interruptduration = 4, },  -- Mind Freeze
	-- Druid
	[22842] = { type = "buffs_defensive", },  -- Frenzied Regeneration
	[17116] = { type = "buffs_defensive", }, -- Nature's Swiftness
	[61336] = { type = "buffs_defensive", },  -- Survival Instincts
	[22812] = { type = "buffs_defensive", },  -- Barkskin
	[29166] = { type = "buffs_offensive", },  -- Innervate
	[50334] = { type = "buffs_offensive", },  -- Berserk
	[69369] = { type = "buffs_offensive", }, -- Predator's Swiftness
	[77761] = { type = "buffs_other" }, -- Stampeding Roar (Bear)
	[77764] = { type = "buffs_other" }, -- Stampeding Roar (Cat)
	[48505] = { type = "buffs_offensive", }, -- Starfall
	[16689] = { type = "buffs_other", }, -- Nature's Grasp
	[1850] = { type = "buffs_other", },  -- Dash
	[768] = { type = "buffs_other", }, -- Cat Form
	[5487] = { type = "buffs_other", }, -- Bear Form
	[783] = { type = "buffs_other", }, -- Travel Form
	[24858] = { type = "buffs_other", }, -- Moonkin Form
	[33891] = { type = "buffs_other", }, -- Tree of Life
	[22570] = { type = "cc" },  -- Maim
	[5211] = { type = "cc", },  -- Bash
	[2637] = {type = "cc"}, -- Hibernate
	[9005] = { type = "cc", },  -- Pounce
	[33786] = { type = "immunities" },  -- Cyclone
	[45334] = { type = "roots", },  -- Feral Charge Effect (Immobilize)
	[339] = { type = "roots", },  -- Entangling Roots
	[19975] = { type = "roots", }, -- Entangling Roots (From Nature's Grasp)
	[45334] = { type = "interrupts", interruptduration = 4, },  -- Feral Charge Effect (Interrupt)
	-- Hunter
	[3045] = { type = "buffs_offensive", }, -- Rapid Fire
	[53480] = { type = "buffs_defensive", },  -- Roar of Sacrifice (Hunter Pet Skill)
	[5384] = { type = "buffs_defensive", },  -- Feign Death
	[53271] = { type = "buffs_defensive", },  -- Master's Call
	[53476] = { type = "buffs_defensive", }, -- Intervene (Pet)
	[1742] = { type = "buffs_defensive", }, -- Cower (Pet)
	[26064] = { type = "buffs_defensive", }, -- Shell Shield (Pet)
	[34471] = { type = "immunities", },  -- The Beast Within
	[19263] = { type = "immunities", },  -- Deterrence
	[19574] = { type = "immunities", }, -- Bestial Wrath (Pet)
	[24394] = { type = "cc", },  -- Intimidation (Stun)
		[19577] = { type = "buffs_offensive", }, -- Intimidation (Pet Buff)
	[19386] = { type = "cc", },  -- Wyvern Sting
	[19503] = { type = "cc", },  -- Scatter Shot
	[3355] = { type = "cc", },  -- Freezing Trap
	[1513] = { type = "cc", }, -- Scare Beast
	[35101] = { type = "cc", }, -- Chimera Shot - Daze
	[50518] = { type = "cc", }, -- Ravage (Pet)
	[91644] = { type = "cc", }, -- Snatch (Pet Disarm)
	[34490] = { type = "cc", }, -- Silencing Shot
	[19306] = { type = "roots", }, -- Counterattack
	[19185] = { type = "roots", }, -- Entrapment
		[64803] = { type = "roots", },
		[19184] = { type = "roots", },
	[50245] = { type = "roots", }, -- Pin (Pet)
	[4167] = { type = "roots", }, -- Web (Pet)
	[26090] = { type = "interrupts", interruptduration = 2, }, -- Pummel (Pet)
	-- Mage
	[11426] = { type = "buffs_other", },  -- Ice Barrier
	[12472] = { type = "buffs_offensive", },  -- Icy Veins
	[12042] = { type = "buffs_offensive", },  -- Arcane Power
	[12043] = { type = "buffs_offensive", },  -- Presence of Mind
	[12051] = { type = "buffs_offensive", },  -- Evocation
	[44544] = { type = "buffs_offensive", }, -- Fingers of Frost
	[66] = { type = "buffs_offensive", },  -- Invisibility
	[118] = { type = "cc", },  -- Polymorph
		[71319] = { type = "cc", },
		[28271] = { type = "cc", },
		[28272] = { type = "cc", },
		[61305] = { type = "cc", },
		[61721] = { type = "cc", },
	[31661] = { type = "cc", },  -- Dragon's Breath
	[44572] = { type = "cc", }, -- Deep Freeze
	[12355] = { type = "cc", }, -- Impact
	[55021] = { type = "cc", }, -- Improved Counterspell
	[64346] = { type = "cc", }, -- Fiery Payback (Fire Mage Disarm)
	[45438] = { type = "immunities", },  -- Ice Block
	[122] = { type = "roots", },  -- Frost Nova
	[2139] = { type = "interrupts", interruptduration = 6, },  -- Counterspell (Mage)
	-- Paladin
	[54428] = { type = "buffs_other", }, -- Divine Plea
	[96263] = { type = "buffs_other", }, -- Sacred Shield Proc
	[59578] = { type = "buffs_other", }, -- The Art of War
	[1022] = { type = "buffs_defensive", }, -- Hand of Protection
	[31850] = { type = "buffs_defensive", },  -- Ardent Defender
	[31821] = { type = "buffs_defensive", },  -- Aura Mastery
	[498] = { type = "buffs_defensive", },  -- Divine Protection
	[6940] = { type = "buffs_defensive", },  -- Hand of Sacrifice
	[1044] = { type = "buffs_defensive", },  -- Hand of Freedom
	[64205] = { type = "buffs_defensive", }, -- Divine Sacrifice
	[31884] = { type = "buffs_offensive", },  -- Avenging Wrath
	[20066] = { type = "cc", },  -- Repentance
	[853] = { type = "cc", },  -- Hammer of Justice
	[63529] = { type = "cc", }, -- Silenced - Shield of the Templar
	[10326] = { type = "cc", }, -- Turn Evil
	[2812] = { type = "cc", }, -- Holy Wrath
	[20170] = { type = "cc", }, -- Seal of Justice Stun
	[642] = { type = "immunities", },  -- Divine Shield
	-- Priest
	[47585] = { type = "buffs_defensive", },  -- Dispersion
	[20711] = { type = "buffs_defensive", },  -- Spirit of Redemption
	[47788] = { type = "buffs_defensive", },  -- Guardian Spirit
	[14751] = { type = "buffs_defensive", },  -- Inner Focus
	[33206] = { type = "buffs_defensive", },  -- Pain Suppression
	[64843] = { type = "buffs_defensive", },  -- Divine Hymn
	[64901] = { type = "buffs_defensive", }, -- Hymn of Hope
	[10060] = { type = "buffs_offensive", },  -- Power Infusion
	[6346] = { type = "buffs_other", },  -- Fear Ward
	[17] = { type = "buffs_other", }, -- Power Word: Shield
	[64044] = { type = "cc", }, -- Psychic Horror (Horrify)
	[64058] = { type = "cc", }, -- Psychic Horror (Disarm)
	[8122] = { type = "cc", },  -- Psychic Scream
	[15487] = { type = "cc", },  -- Silence
	[605] = { type = "cc", },  -- Mind Control
	[9484] = { type = "cc", },  -- Shackle Undead
	[96231] = { type = "interrupts", interruptduration = 4 }, -- Rebuke
	-- Rogue
	[51713] = { type = "buffs_offensive", }, -- Shadow Dance
	[13750] = { type = "buffs_offensive", },  -- Adrenaline Rush
	[51690] = { type = "buffs_offensive", },  -- Killing Spree
	[14177] = { type = "buffs_offensive", }, -- Cold Blood
	[2983] = { type = "buffs_other", },  -- Sprint
	[5277] = { type = "buffs_defensive", },  -- Evasion
	[1776] = { type = "cc", },  -- Gouge
	[51722] = {type = "cc", }, -- Dismantle
	[2094] = { type = "cc", },  -- Blind
	[408] = { type = "cc", },  -- Kidney Shot
	[6770] = { type = "cc", },  -- Sap
	[1330] = { type = "cc", },  -- Garrote - Silence
	[1833] = { type = "cc", },  -- Cheap Shot
	[18425] = { type = "cc", }, -- Silence (Improved Kick)
	[31224] = { type = "immunities_spells", },  -- Cloak of Shadows
	[1766] = { type = "interrupts", interruptduration = 5, },  -- Kick
	-- Shaman
	[16166] = { type = "buffs_offensive", }, -- Elemental Mastery (Instant Cast)
	[2825] = { type = "buffs_offensive", },  -- Bloodlust
	[32182] = { type = "buffs_offensive", },  -- Heroism
	[16191] = { type = "buffs_offensive", }, -- Mana Tide Totem
	[30823] = { type = "buffs_defensive", }, -- Shamanistic Rage
	[16188] = { type = "buffs_defensive", }, -- Nature's Swiftness
	[58861] = { type = "cc", }, -- Bash (Spirit Wolf)
	[51514] = { type = "cc", },  -- Hex
	[39796] = { type = "cc", }, -- Stoneclaw Stun
	[8178] = { type = "immunities_spells", }, -- Grounding Totem Effect
	[63685] = { type = "roots", }, -- Freeze (Enhancement)
	[64695] = { type = "roots", }, -- Earthgrab (Elemental)
	[58875] = { type = "buffs_other", }, -- Spirit Walk (Spirit Wolf)
	[55277] = { type = "buffs_other", }, -- Stoneclaw Totem (Absorb)
	[57994] = { type = "interrupts", interruptduration = 2, },  -- Wind Shear
	-- Warlock
	[47241] = { type = "buffs_offensive", }, -- Metamorphosis
	[18708] = { type = "buffs_other", },  -- Fel Domination
	[7812] = { type = "buffs_other", }, -- Sacrifice
	[60995] = { type = "cc", }, -- Demon Charge (Metamorphosis)
	[30283] = { type = "cc", },  -- Shadowfury
	[31117] = { type = "cc", },  -- Unstable Affliction (Silence)
	[710] = { type = "cc", },  -- Banish
	[47541] = { type = "cc", },  -- Death Coil
	[6358] = { type = "cc", },  -- Seduction
	[5782] = { type = "cc", },  -- Fear
	[5484] = { type = "cc", },  -- Howl of Terror
	[24259] = { type = "cc", }, -- Spell Lock (Silence)
	[89766] = { type = "cc", }, -- Axe Toss (Felguard)
	[19647] = { type = "interrupts", interruptduration = 6, },  -- Spell Lock (Interrupt)
	-- Warrior
	[12975] = { type = "buffs_defensive", },  -- Last Stand
	[55694] = { type = "buffs_defensive", },  -- Enraged Regeneration
	[871] = { type = "buffs_defensive", },  -- Shield Wall
	[3411] = { type = "buffs_defensive", },  -- Intervene
	[2565] = { type = "buffs_defensive", }, -- Shield Block
	[20230] = { type = "buffs_defensive", }, -- Retaliation
	[60503] = { type = "buffs_offensive", }, -- Taste for Blood
	[65925] = { type = "buffs_offensive", }, -- Unrelenting Assault
	[1719] = { type = "buffs_offensive", },  -- Recklessness
	[12292] = { type = "buffs_offensive", }, -- Death Wish
	[18499] = { type = "buffs_other", },  -- Berserker Rage
	[2457] = { type = "buffs_other", }, -- Battle Stance
	[2458] = { type = "buffs_other", }, -- Berserker Stance
	[71] = { type = "buffs_other", }, -- Defensive Stance
	[12809] = { type = "cc", }, -- Concussion Blow
	[676] = { type = "cc", },  -- Disarm
	[46968] = { type = "cc", },  -- Shockwave
	[5246] = { type = "cc", },  -- Intimidating Shout (Non - Target)
	[20511] = { type = "cc", }, -- Intimidating Shout (Target)
	[7922] = { type = "cc", }, -- Charge
	[20253] = { type = "cc", }, -- Intercept
	[18498] = { type = "cc", }, -- Silenced - Gag Order
	[46924] = { type = "immunities", },  -- Bladestorm
	[23920] = { type = "immunities_spells", },  -- Spell Reflection
	[6552] = { type = "interrupts", interruptduration = 4, },  -- Pummel
	-- Misc
	[43183] = { type = "buffs_other", },  -- Drink (Arena/Lvl 80 Water)
		[57073] = { type = "buffs_other" }, -- (Mage Water)
	[20549] = { type = "cc", },  -- War Stomp
	[28730] = { type = "cc", }, -- Arcane Torrent (Mana)
	[25046] = { type = "cc", }, -- Arcane Torrent (Energy)
	[50613] = { type = "cc", }, -- Arcane Torrent (Runic Power)
	[69179] = { type = "cc", }, -- Arcane Torrent (Rage)
	[80483] = { type = "cc", }, -- Arcane Torrent (Focus)
}

function BigDebuffs_SpellTest()
	for k,v in pairs(BigDebuffs.Spells) do
		if not GetSpellInfo(k) then
			print(k)
		end
	end
end

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
	if not self.Spells[id] and not self.Spells[name] then return end
	
	id = self.Spells[id] and id or name
	
	-- Make sure category is enabled
	if not self.db.profile.unitFrames[self.Spells[id].type] then return end

	-- Check for user set
	if self.db.profile.spells[id] then
		if self.db.profile.spells[id].unitFrames and self.db.profile.spells[id].unitFrames == 0 then return end
		if self.db.profile.spells[id].priority then return self.db.profile.spells[id].priority end
	end

	if self.Spells[id].nounitFrames and (not self.db.profile.spells[id] or not self.db.profile.spells[id].unitFrames) then
		return
	end

	return self.db.profile.priority[self.Spells[id].type] or 0
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
        end

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
	
	local spelldata = self.Spells[name] and self.Spells[name] or self.Spells[spellid]
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
			if self.Spells[n] or self.Spells[id] then
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
			if self.Spells[id] then
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
		if stanceId and self.Spells[stanceId] then
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

		local isFriend = UnitIsFriend("player",unit) == true
		
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
			self:Reap(guid, isFriend, true)
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
