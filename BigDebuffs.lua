
-- BigDebuffs by Jordon

local addonName, addon = ...

BigDebuffs = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceEvent-3.0", "AceHook-3.0")
local LibSharedMedia = LibStub("LibSharedMedia-3.0")

-- Defaults
local defaults = {
    profile = {
        raidFrames = {
            maxDebuffs = 1,
            anchor = "INNER",
            enabled = true,
            cooldownCount = true,
            cooldownFontSize = 10,
            cooldownFontEffect = "OUTLINE",
            cooldownFont = "Friz Quadrata TT",
            showAllClassBuffs = true,
            hideBliz = true,
            redirectBliz = false,
            increaseBuffs = false,
            cc = 50,
            dispellable = {
                cc = 60,
                roots = 50,
            },
            interrupts = 55,
            roots = 40,
            warning = 40,
            debuffs_offensive = 35,
            default = 30,
            special = 30,
            pve = 50,
            warningList = {
                [212183] = true, -- Smoke Bomb
                [81261] = true, -- Solar Beam
                [316099] = true, -- Unstable Affliction
                [342938] = true, -- Unstable Affliction
                [34914] = true, -- Vampiric Touch
            },
            inRaid = {
                hide = false,
                size = 5
            }
        },
        unitFrames = {
            enabled = true,
            cooldownCount = true,
            cooldownFontSize = 16,
            cooldownFontEffect = "OUTLINE",
            cooldownFont = "Friz Quadrata TT",
            tooltips = true,
            player = {
                enabled = true,
                anchor = "auto",
                anchorPoint = "auto",
                relativePoint = "auto",
                x = 0,
                y = 0,
                matchFrameHeight = true,
                size = 50,
            },
            target = {
                enabled = true,
                anchor = "auto",
                anchorPoint = "auto",
                relativePoint = "auto",
                x = 0,
                y = 0,
                matchFrameHeight = true,
                size = 50,
            },
            pet = {
                enabled = true,
                anchor = "auto",
                anchorPoint = "auto",
                relativePoint = "auto",
                x = 0,
                y = 0,
                matchFrameHeight = true,
                size = 50,
            },
            party = {
                enabled = true,
                anchor = "auto",
                anchorPoint = "auto",
                relativePoint = "auto",
                x = 0,
                y = 0,
                matchFrameHeight = true,
                size = 50,
            },
            cc = true,
            interrupts = true,
            immunities = true,
            immunities_spells = true,
            buffs_defensive = true,
            buffs_offensive = true,
            buffs_other = true,
            debuffs_offensive = true,
            roots = true,
            buffs_speed_boost = true,
        },
		nameplates = {
			enabled = true,
			cooldownCount = true,
            cooldownFontSize = 16,
            cooldownFontEffect = "OUTLINE",
            cooldownFont = "Friz Quadrata TT",
            tooltips = true,
			enemy = true,
			friendly = true,
			npc = true,
            enemyAnchor = {
                anchor = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE and "RIGHT" or "TOP",
                size = 40,
                x = 0,
                y = 0,
            },
            friendlyAnchor = {
                friendlyAnchorEnabled = false,
                anchor = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE and "RIGHT" or "TOP",
                size = 40,
                x = 0,
                y = 0,
            },
			cc = true,
            interrupts = true,
            immunities = true,
            immunities_spells = true,
            buffs_defensive = true,
            buffs_offensive = true,
            buffs_other = true,
            debuffs_offensive = true,
            roots = true,
            buffs_speed_boost = true,
		},
        priority = {
            immunities = 80,
            immunities_spells = 70,
            cc = 60,
            interrupts = 55,
            buffs_defensive = 50,
            buffs_offensive = 40,
            debuffs_offensive = 35,
            buffs_other = 30,
            roots = 20,
            special = 19,
            buffs_speed_boost = 10,
        },
        spells = {},
    }
}


-- Show one of these when a big debuff is displayed
BigDebuffs.WarningDebuffs = {
    212183, -- Smoke Bomb
    81261, -- Solar Beam
    316099, -- Unstable Affliction
    342938, -- Unstable Affliction
    34914, -- Vampiric Touch
    323673, -- Mindgames
}

-- Make sure we always see these debuffs, but don't make them bigger
BigDebuffs.PriorityDebuffs = {
    316099, -- Unstable Affliction
    342938, -- Unstable Affliction
    34914, -- Vampiric Touch
    209749, -- Faerie Swarm
    117405, -- Binding Shot
    122470, -- Touch of Karma
    208997, -- Counterstrike Totem
    343294, -- Soul Reaper (Unholy)
    323673, -- Mindgames
}

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
	[53201] = { type = "buffs_offensive", }, -- Starfall
	[53312] = { type = "buffs_other", }, -- Nature's Grasp
	[33357] = { type = "buffs_other", },  -- Dash
	[768] = { type = "buffs_other", }, -- Cat Form
	[5487] = { type = "buffs_other", }, -- Bear Form
	[783] = { type = "buffs_other", }, -- Travel Form
	[24858] = { type = "buffs_other", }, -- Moonkin Form
	[33891] = { type = "buffs_other", }, -- Tree of Life
	[22570] = { type = "cc" },  -- Maim
	[5211] = { type = "cc", },  -- Bash
	[2637] = {type = "cc"}, -- Hibernate
	[49803] = { type = "cc", },  -- Pounce
	[33786] = { type = "immunities" },  -- Cyclone
	[45334] = { type = "roots", },  -- Feral Charge Effect (Immobilize)
	[53308] = { type = "roots", },  -- Entangling Roots
	[53313] = { type = "roots", }, -- Entangling Roots (From Nature's Grasp)
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
	[49012] = { type = "cc", },  -- Wyvern Sting
	[19503] = { type = "cc", },  -- Scatter Shot
	[3355] = { type = "cc", },  -- Freezing Trap
	[14327] = { type = "cc", }, -- Scare Beast
	[53359] = { type = "cc", }, -- Chimera Shot - Scorpid (Disarm)
	[53562] = { type = "cc", }, -- Ravage (Pet)
	[53543] = { type = "cc", }, -- Snatch (Pet Disarm)
	[34490] = { type = "cc", }, -- Silencing Shot
	[19306] = { type = "roots", }, -- Counterattack
	[19185] = { type = "roots", }, -- Entrapment
		[64803] = { type = "roots", },
		[64804] = { type = "roots", },
	[53548] = { type = "roots", }, -- Pin (Pet)
	[4167] = { type = "roots", }, -- Web (Pet)
	[26090] = { type = "interrupts", interruptduration = 2, }, -- Pummel (Pet)
	-- Mage
	[11426] = { type = "buffs_other", },  -- Ice Barrier
	[12472] = { type = "buffs_offensive", },  -- Icy Veins
	[54748] = { type = "buffs_offensive", }, -- Burning Determination (Interrupt/Silence Immunity)
	[12042] = { type = "buffs_offensive", },  -- Arcane Power
	[12043] = { type = "buffs_offensive", },  -- Presence of Mind
	[12051] = { type = "buffs_offensive", },  -- Evocation
	[44544] = { type = "buffs_offensive", }, -- Fingers of Frost
	[66] = { type = "buffs_offensive", },  -- Invisibility
	[118] = { type = "cc", },  -- Polymorph
		[12826] = { type = "cc", },
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
	[12494] = { type = "roots", },  -- Frostbite
	[122] = { type = "roots", },  -- Frost Nova
	[2139] = { type = "interrupts", interruptduration = 6, },  -- Counterspell (Mage)
	-- Paladin
	[54428] = { type = "buffs_other", }, -- Divine Plea
	[58597] = { type = "buffs_other", }, -- Sacred Shield Proc
	[59578] = { type = "buffs_other", }, -- The Art of War
	[1022] = { type = "buffs_defensive", }, -- Hand of Protection
	[31852] = { type = "buffs_defensive", },  -- Ardent Defender
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
	[48817] = { type = "cc", }, -- Holy Wrath
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
	[48066] = { type = "buffs_other", }, -- Power Word: Shield
	[64044] = { type = "cc", }, -- Psychic Horror (Horrify)
	[64058] = { type = "cc", }, -- Psychic Horror (Disarm)
	[10890] = { type = "cc", },  -- Psychic Scream
	[15487] = { type = "cc", },  -- Silence
	[605] = { type = "cc", },  -- Mind Control
	[9484] = { type = "cc", },  -- Shackle Undead
	[96231] = { type = "interrupts", interruptduration = 4 }, -- Rebuke
	-- Rogue
	[51713] = { type = "buffs_offensive", }, -- Shadow Dance
	[13750] = { type = "buffs_offensive", },  -- Adrenaline Rush
	[51690] = { type = "buffs_offensive", },  -- Killing Spree
	[14177] = { type = "buffs_offensive", }, -- Cold Blood
	[11305] = { type = "buffs_other", },  -- Sprint
	[26669] = { type = "buffs_defensive", },  -- Evasion
	[1776] = { type = "cc", },  -- Gouge
	[51722] = {type = "cc", }, -- Dismantle
	[2094] = { type = "cc", },  -- Blind
	[8643] = { type = "cc", },  -- Kidney Shot
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
	[47986] = { type = "buffs_other", }, -- Sacrifice
	[60995] = { type = "cc", }, -- Demon Charge (Metamorphosis)
	[47847] = { type = "cc", },  -- Shadowfury
	[30283] = { type = "cc", },
	[31117] = { type = "cc", },  -- Unstable Affliction (Silence)
	[18647] = { type = "cc", },  -- Banish
	[47860] = { type = "cc", },  -- Death Coil
	[6358] = { type = "cc", },  -- Seduction
	[6215] = { type = "cc", },  -- Fear
	[17928] = { type = "cc", },  -- Howl of Terror
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
	[12798] = { type = "cc", }, -- Revenge Stun
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

-- create a lookup table since CombatLogGetCurrentEventInfo() returns 0 for spellId

defaults.profile.unitFrames.focus = {
	enabled = true,
	anchor = "auto",
	anchorPoint = "auto",
	relativePoint = "auto",
	x = 0,
	y = 0,
	matchFrameHeight = true,
	size = 50,
}

defaults.profile.unitFrames.arena = {
	enabled = true,
	anchor = "auto",
	anchorPoint = "auto",
	relativePoint = "auto",
	x = 0,
	y = 0,
	matchFrameHeight = true,
	size = 50,
}

BigDebuffs.specDispelTypes = {
	[62] = { -- Arcane Mage
		Curse = true,
	},
	[63] = { -- Fire Mage
		Curse = true,
	},
	[64] = { -- Frost Mage
		Curse = true,
	},
	[65] = { -- Holy Paladin
		Magic = true,
		Poison = true,
		Disease = true,
	},
	[66] = { -- Protection Paladin
		Poison = true,
		Disease = true,
	},
	[70] = { -- Retribution Paladin
		Poison = true,
		Disease = true,
	},
	[102] = { -- Balance Druid
		Curse = true,
		Poison = true,
	},
	[103] = { -- Feral Druid
		Curse = true,
		Poison = true,
	},
	[104] = { -- Guardian Druid
		Curse = true,
		Poison = true,
	},
	[105] = { -- Restoration Druid
		Magic = true,
		Curse = true,
		Poison = true,
	},
	[256] = { -- Discipline Priest
		Magic = true,
		Disease = true,
	},
	[257] = { -- Holy Priest
		Magic = true,
		Disease = true,
	},
	[258] = { -- Shadow Priest
		Magic = true,
		Disease = true,
	},
	[262] = { -- Elemental Shaman
		Curse = true,
	},
	[263] = { -- Enhancement Shaman
		Curse = true,
	},
	[264] = { -- Restoration Shaman
		Magic = true,
		Curse = true,
	},
	[577] = {
		Magic = function() return GetSpellInfo(205604) end, -- Reverse Magic
	},
	[581] = {
		Magic = function() return GetSpellInfo(205604) end, -- Reverse Magic
	},
}

-- Store interrupt spellId and start time
BigDebuffs.units = {}

local units = {
	"player",
	"pet",
	"target",
	"focus",
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

local unitsWithRaid = {}

for i = 1, #units do
    table.insert(unitsWithRaid, units[i])
end

for i = 1, 40 do
    table.insert(unitsWithRaid, "raid" .. i)
end

local UnitDebuff, UnitBuff = UnitDebuff, UnitBuff

local GetAnchor = {
    ElvUIFrames = function(anchor)
        local anchors, unit = BigDebuffs.anchors

        for u,configAnchor in pairs(anchors.ElvUI.units) do
            if anchor == configAnchor then
                unit = u
                break
            end
        end

        if unit and ( unit:match("party") or unit:match("player") ) then
            local unitGUID = UnitGUID(unit)
            for i = 1,5,1 do
                local elvUIFrame = _G["ElvUF_PartyGroup1UnitButton"..i]
                if elvUIFrame and elvUIFrame:IsVisible() and elvUIFrame.unit then
                    if unitGUID == UnitGUID(elvUIFrame.unit) then
                        return elvUIFrame
                    end
                end
            end
            return
        end

        if unit and ( unit:match("arena") or unit:match("arena") ) then
            local unitGUID = UnitGUID(unit)
            for i = 1,5,1 do
                local elvUIFrame = _G["ElvUF_Arena"..i]
                if elvUIFrame and elvUIFrame:IsVisible() and elvUIFrame.unit then
                    if unitGUID == UnitGUID(elvUIFrame.unit) then
                        return elvUIFrame
                    end
                end
            end
            return
        end

        return _G[anchor]
    end,
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

local GetNameplateAnchor = {
	ElvUINameplates = function(frame)
        if frame.unitFrame and frame.unitFrame.Health and frame.unitFrame.Health:IsShown() then
            return frame.unitFrame.Health, frame.unitFrame
        elseif frame.unitFrame then
            return frame.unitFrame, frame.unitFrame
        end
    end,
    KuiNameplate = function(frame)
        if frame.kui and frame.kui.HealthBar and frame.kui.HealthBar:IsShown() then
            return frame.kui.HealthBar, frame.kui
		elseif frame.kui and frame.kui.NameText and frame.kui.NameText:IsShown() then
			return frame.kui.NameText, frame.kui
		elseif frame.kui then
            return frame.kui, frame.kui
        end
    end,
	Plater = function(frame)
		if frame.unitFrame and frame.unitFrame.healthBar and frame.unitFrame.healthBar:IsShown() then
			return frame.unitFrame.healthBar, frame.unitFrame
		elseif frame.unitFrame and frame.unitFrame.ActorNameSpecial and frame.unitFrame.ActorNameSpecial:IsShown() then
			return frame.unitFrame.ActorNameSpecial, frame.unitFrame
		elseif frame.unitFrame then
			return frame.unitFrame, frame.unitFrame
		end
    end,
    NeatPlates = function(frame)
        if frame.carrier and frame.extended and frame.extended.bars and frame.carrier:IsShown() then
            return frame.extended.bars.healthbar, frame.extended
        end
    end,
  ThreatPlates = function(frame)
    local tp_frame = frame.TPFrame
    if tp_frame then
      local visual = tp_frame.visual
      -- healthbar and name are always defined, so checks are not really needed here.
      if visual.healthbar and visual.healthbar:IsShown() then
        return visual.healthbar, tp_frame
      elseif visual.name and visual.name:IsShown() then
        return visual.name, tp_frame
      else
        return tp_frame, tp_frame
      end
    end
  end,
  TidyPlates = function(frame)
    if frame.carrier and frame.extended and frame.extended.bars and frame.carrier:IsShown() then
        return frame.extended.bars.healthbar, frame.extended
    end
  end,
	Blizzard = function(frame)
        if WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then
            return frame.UnitFrame, frame.UnitFrame
        end
        if frame.UnitFrame and frame.UnitFrame.healthBar and frame.UnitFrame.healthBar:IsShown() then
            return frame.UnitFrame.healthBar, frame.UnitFrame
		elseif frame.UnitFrame and frame.UnitFrame.name and frame.UnitFrame.name:IsShown() then
            return frame.UnitFrame.name, frame.UnitFrame
        elseif frame.UnitFrame then
            return frame.UnitFrame, frame.UnitFrame
        end
    end,
}

local nameplatesAnchors = {
	[1] = {
        used = function()
			return ElvUI and ElvUI[1].NamePlates and ElvUI[1].NamePlates.Initialized
		end,
        func = GetNameplateAnchor.ElvUINameplates,
    },
	[2] = {
        used = function()
			return KuiNameplates ~= nil
		end,
        func = GetNameplateAnchor.KuiNameplate,
    },
	[3] = {
        used = function()
			return Plater ~= nil
		end,
        func = GetNameplateAnchor.Plater,
    },
    [4] = {
        used = function()
            return NeatPlates ~= nil
        end,
        func = GetNameplateAnchor.NeatPlates,
    },
    [5] = {
        used = function()
            -- IsAddOnLoaded("TidyPlates_ThreatPlates") should be better
            return TidyPlatesThreat ~= nil
        end,
        func = GetNameplateAnchor.ThreatPlates,
    },
    [6] = {
        used = function()
            return TidyPlates ~= nil
        end,
        func = GetNameplateAnchor.TidyPlates,
    },
    [7] = {
        used = function(frame) return frame.UnitFrame ~= nil end,
        func = GetNameplateAnchor.Blizzard,
    },
}

local anchors = {
    ["GladiusExParty"] = {
        noPortait = true,
        units = {
            party1 = "GladiusExButtonFrameparty1",
            party2 = "GladiusExButtonFrameparty2",
            party3 = "GladiusExButtonFrameparty3",
            party4 = "GladiusExButtonFrameparty4"
        }
    },
    ["GladiusExArena"] = {
        noPortait = true,
        alignLeft = true,
        units = {
            arena1 = "GladiusExButtonFramearena1",
            arena2 = "GladiusExButtonFramearena2",
            arena3 = "GladiusExButtonFramearena3",
            arena4 = "GladiusExButtonFramearena4",
            arena5 = "GladiusExButtonFramearena5",
        }
    },
    ["ElvUI"] = {
        func = GetAnchor.ElvUIFrames,
        noPortait = true,
        units = {
            player = "ElvUF_Player",
            pet = "ElvUF_Pet",
            target = "ElvUF_Target",
            focus = "ElvUF_Focus",
            party1 = "ElvUF_PartyGroup1UnitButton2",
            party2 = "ElvUF_PartyGroup1UnitButton3",
            party3 = "ElvUF_PartyGroup1UnitButton4",
            party4 = "ElvUF_PartyGroup1UnitButton5",
            arena1 = "ElvUF_Arena1",
            arena2 = "ElvUF_Arena2",
            arena3 = "ElvUF_Arena3",
            arena4 = "ElvUF_Arena4",
            arena5 = "ElvUF_Arena5",
        },
    },
    ["bUnitFrames"] = {
        noPortait = true,
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

BigDebuffs.anchors = anchors

function BigDebuffs:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("BigDebuffsDB", defaults, true)

    -- Upgrade old database
    if type(self.db.profile.raidFrames.dispellable) == "number" then
        self.db.profile.raidFrames.dispellable = {
            cc = self.db.profile.raidFrames.dispellable,
            roots = self.db.profile.raidFrames.roots
        }
    end
    for i = 1, #units do
        local key = units[i]:gsub("%d", "")
        if type(self.db.profile.unitFrames[key]) == "boolean" then
            self.db.profile.unitFrames[key] = {
                enabled = self.db.profile.unitFrames[key],
                anchor = "auto",
                anchorPoint = "auto",
                relativePoint = "auto",
                x = 0,
                y = 0,
                matchFrameHeight = true,
                size = 50
            }
        else
            if type(self.db.profile.unitFrames[key].anchorPoint) ~= "string" then
                self.db.profile.unitFrames[key].anchorPoint = "auto"
            end

            if type(self.db.profile.unitFrames[key].relativePoint) ~= "string" then
                self.db.profile.unitFrames[key].relativePoint = "auto"
            end

            if type(self.db.profile.unitFrames[key].x) ~= "number" then
                self.db.profile.unitFrames[key].x = 0
            end

            if type(self.db.profile.unitFrames[key].y) ~= "number" then
                self.db.profile.unitFrames[key].y = 0
            end

            if type(self.db.profile.unitFrames[key].matchFrameHeight) ~= "boolean" then
                self.db.profile.unitFrames[key].matchFrameHeight = true
            end
        end
    end

    if self.db.profile.raidFrames.showAllClassBuffs == nil then
        self.db.profile.raidFrames.showAllClassBuffs = true
    end

    self.db.RegisterCallback(self, "OnProfileChanged", "Refresh")
    self.db.RegisterCallback(self, "OnProfileCopied", "Refresh")
    self.db.RegisterCallback(self, "OnProfileReset", "Refresh")
    self.frames = {}
    self.UnitFrames = {}
	self.Nameplates = {}
    self:SetupOptions()
end

local function HideBigDebuffs(frame)
    if not frame.BigDebuffs then return end
    for i = 1, #frame.BigDebuffs do
        frame.BigDebuffs[i]:Hide()
    end
end

function BigDebuffs:Refresh()
    for frame, _ in pairs(self.frames) do
        if frame:IsVisible() then CompactUnitFrame_UpdateAuras(frame) end
        if frame and frame.BigDebuffs then self:AddBigDebuffs(frame) end
    end
    for unit, frame in pairs(self.UnitFrames) do
        frame:Hide()
        frame.current = nil
        if self.db.profile.unitFrames.cooldownCount then
            local text = frame.cooldown:GetRegions()
            if text then
                text:SetFont(LibSharedMedia:Fetch("font", BigDebuffs.db.profile.unitFrames.cooldownFont),
                    self.db.profile.unitFrames.cooldownFontSize, self.db.profile.unitFrames.cooldownFontEffect)
            end
        end

        frame.cooldown.noCooldownCount = not self.db.profile.unitFrames.cooldownCount
        self:UNIT_AURA(nil,unit)
    end
	for unit, frame in pairs(self.Nameplates) do
        frame:Hide()
        frame.current = nil
        if self.db.profile.unitFrames.cooldownCount then
            local text = frame.cooldown:GetRegions()
            if text then
                text:SetFont(LibSharedMedia:Fetch("font", BigDebuffs.db.profile.unitFrames.cooldownFont),
                    self.db.profile.unitFrames.cooldownFontSize, self.db.profile.unitFrames.cooldownFontEffect)
            end
        end

        frame.cooldown.noCooldownCount = not self.db.profile.unitFrames.cooldownCount
        self:UNIT_AURA_NAMEPLATE(unit)
    end
end

function BigDebuffs:AttachUnitFrame(unit)
    if InCombatLockdown() then return end

    local frame = self.UnitFrames[unit]
    local frameName = addonName .. unit .. "UnitFrame"

    if not frame then
        frame = CreateFrame("Button", frameName, UIParent, "BigDebuffsUnitFrameTemplate")
        self.UnitFrames[unit] = frame
        frame:SetScript("OnEvent", function() self:UNIT_AURA(nil,unit) end)
        if self.db.profile.unitFrames.cooldownCount then
            local text = frame.cooldown:GetRegions()
            if text then
                text:SetFont(LibSharedMedia:Fetch("font", BigDebuffs.db.profile.unitFrames.cooldownFont),
                    self.db.profile.unitFrames.cooldownFontSize, self.db.profile.unitFrames.cooldownFontEffect)
            end
        end

        frame.cooldown.noCooldownCount = not self.db.profile.unitFrames.cooldownCount
        frame.icon:SetDrawLayer("BORDER")
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
            local anchor, parent, noPortait
            if v.units[unit] then
                if v.func then
                    anchor, parent, noPortait = v.func(v.units[unit])
                else
                    anchor = _G[v.units[unit]]
                end

                if anchor then
                    frame.anchor, frame.parent, frame.noPortait = anchor, parent, noPortait
                    if v.noPortait then frame.noPortait = true end
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
            frame.cooldown:SetFrameLevel(frame.anchor:GetParent():GetFrameLevel())
            frame.anchor:SetDrawLayer("BACKGROUND")
        else
            frame:SetParent(frame.parent and frame.parent or frame.anchor)
            frame:SetFrameLevel(99)
        end

        frame:ClearAllPoints()

        if config.anchorPoint ~= "auto" or frame.noPortait then
            if config.anchorPoint == "auto" then
                -- No portrait, so attach to the side
                if frame.alignLeft then
                    frame:SetPoint("TOPRIGHT", frame.anchor, "TOPLEFT")
                else
                    frame:SetPoint("TOPLEFT", frame.anchor, "TOPRIGHT")
                end
            else
                if config.relativePoint == "auto" then
                    if config.anchorPoint == "BOTTOM" then
                        frame:SetPoint("TOP", frame.anchor, config.anchorPoint, config.x, config.y)
                    elseif config.anchorPoint == "BOTTOMLEFT" then
                        frame:SetPoint("BOTTOMRIGHT", frame.anchor, config.anchorPoint, config.x, config.y)
                    elseif config.anchorPoint == "BOTTOMRIGHT" then
                        frame:SetPoint("BOTTOMLEFT", frame.anchor, config.anchorPoint, config.x, config.y)
                    elseif config.anchorPoint == "CENTER" then
                        frame:SetPoint("CENTER", frame.anchor, config.anchorPoint, config.x, config.y)
                    elseif config.anchorPoint == "LEFT" then
                        frame:SetPoint("RIGHT", frame.anchor, config.anchorPoint, config.x, config.y)
                    elseif config.anchorPoint == "RIGHT" then
                        frame:SetPoint("LEFT", frame.anchor, config.anchorPoint, config.x, config.y)
                    elseif config.anchorPoint == "TOP" then
                        frame:SetPoint("BOTTOM", frame.anchor, config.anchorPoint, config.x, config.y)
                    elseif config.anchorPoint == "TOPLEFT" then
                        frame:SetPoint("TOPRIGHT", frame.anchor, config.anchorPoint, config.x, config.y)
                    elseif config.anchorPoint == "TOPRIGHT" then
                        frame:SetPoint("TOPLEFT", frame.anchor, config.anchorPoint, config.x, config.y)
                    end
                else
                    frame:SetPoint(config.relativePoint, frame.anchor, config.anchorPoint, config.x, config.y)
                end
            end

            if not config.matchFrameHeight then
                frame:SetSize(config.size, config.size)
            else
                local height = frame.anchor:GetHeight()
                frame:SetSize(height, height)
            end
        else
            frame:SetAllPoints(frame.anchor)
        end
    else
        -- Manual
        frame:SetParent(UIParent)
        frame:ClearAllPoints()

        if not self.db.profile.unitFrames[unit] then self.db.profile.unitFrames[unit] = {} end

        if self.db.profile.unitFrames[unit].position then
            frame:SetPoint(unpack(self.db.profile.unitFrames[unit].position))
        else
            -- No saved position, anchor to the blizzard position
            if WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC then LoadAddOn("Blizzard_ArenaUI") end
            local relativeFrame = _G[anchors.Blizzard.units[unit]] or UIParent
            frame:SetPoint("CENTER", relativeFrame, "CENTER")
        end

        frame:SetSize(config.size, config.size)
    end
end

function BigDebuffs:AttachNameplate(unit)
	if InCombatLockdown() then return end

    local frame = self.Nameplates[unit]

	local config = self.db.profile.nameplates

	if config.cooldownCount then
		local text = frame.cooldown:GetRegions()
		if text then
			text:SetFont(LibSharedMedia:Fetch("font", config.cooldownFont),
				config.cooldownFontSize, config.cooldownFontEffect)
		end
	end

	frame.cooldown.noCooldownCount = not config.cooldownCount

	frame:EnableMouse(config.tooltips)

    local anchorStyle = "enemyAnchor"
    if (not UnitCanAttack("player", unit) and config["friendlyAnchor"].friendlyAnchorEnabled == true) then
        anchorStyle = "friendlyAnchor"
    end

	frame:ClearAllPoints()
	if config[anchorStyle].anchor == "RIGHT" then
		frame:SetPoint("LEFT", frame.anchor, "RIGHT", config[anchorStyle].x, config[anchorStyle].y)
	elseif config[anchorStyle].anchor == "TOP" then
		frame:SetPoint("BOTTOM", frame.anchor, "TOP", config[anchorStyle].x, config[anchorStyle].y)
	elseif config[anchorStyle].anchor == "LEFT" then
		frame:SetPoint("RIGHT", frame.anchor, "LEFT", config[anchorStyle].x, config[anchorStyle].y)
	elseif config[anchorStyle].anchor == "BOTTOM" then
		frame:SetPoint("TOP", frame.anchor, "BOTTOM", config[anchorStyle].x, config[anchorStyle].y)
	end

	frame:SetSize(config[anchorStyle].size, config[anchorStyle].size)
end

function BigDebuffs:SaveUnitFramePosition(frame)
    self.db.profile.unitFrames[frame.unit].position = { frame:GetPoint() }
end

function BigDebuffs:Test()
    self.test = not self.test
    self:Refresh()
end

local TestDebuffs = {}

local function InsertTestDebuff(spellID, dispelType)
    local texture = GetSpellTexture(spellID)
    table.insert(TestDebuffs, { spellID, texture, 0, dispelType })
end

local function UnitDebuffTest(unit, index)
    local debuff = TestDebuffs[index]
    if not debuff then return end
    -- name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId
    return "Test", debuff[2], 0, debuff[4], 60, GetTime() + 60, nil, nil, nil, debuff[1]
end

function BigDebuffs:OnEnable()
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:RegisterEvent("PLAYER_TARGET_CHANGED")
    self:RegisterEvent("UNIT_PET")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	self:RegisterEvent("UNIT_AURA")

	self:RegisterEvent("PLAYER_TALENT_UPDATE")
	self:PLAYER_TALENT_UPDATE()
    
	self:RegisterEvent("PLAYER_FOCUS_CHANGED")

	-- Prevent OmniCC finish animations
	if OmniCC then
		self:RawHook(OmniCC, "TriggerEffect", function(...)
			local _, _, cooldown = ...
			local name = cooldown.GetName and cooldown:GetName()
			if name and name:find(addonName) then return end
			self.hooks[OmniCC].TriggerEffect(...)
		end, true)
	end


    InsertTestDebuff(8122, "Magic") -- Psychic Scream
    InsertTestDebuff(408, nil) -- Kidney Shot
    InsertTestDebuff(1766, nil) -- Kick


    InsertTestDebuff(339, "Magic") -- Entangling Roots
    InsertTestDebuff(589, "Magic") -- Shadow Word: Pain
	InsertTestDebuff(589, "Magic") -- Shadow Word: Pain
	InsertTestDebuff(589, "Magic") -- Shadow Word: Pain
	InsertTestDebuff(589, "Magic") -- Shadow Word: Pain
    InsertTestDebuff(772, nil) -- Rend
end

function BigDebuffs:PLAYER_ENTERING_WORLD()
    for i = 1, #units do
        self:AttachUnitFrame(units[i])
    end
end

local function UnitBuffByName(unit, name)
    for i = 1, 40 do
        local n = UnitBuff(unit, i)
        if n == name then return true end
    end
end

function BigDebuffs:COMBAT_LOG_EVENT_UNFILTERED(_,...)
	local timestamp, subEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellId, name = ...

    -- SPELL_INTERRUPT doesn't fire for some channeled spells
    if event ~= "SPELL_INTERRUPT" and event ~= "SPELL_CAST_SUCCESS" then return end

    if spellId == 0 then spellId = spellIdByName[spellName] end

    local spell = self.Spells[spellId]
    if not spell then return end
    local spellType = spell.parent and self.Spells[spell.parent].type or spell.type
    if spellType ~= "interrupts" then return end

    -- Find unit
    for i = 1, #unitsWithRaid do
        local unit = unitsWithRaid[i]
        if destGUID == UnitGUID(unit) and (event ~= "SPELL_CAST_SUCCESS" or
            (UnitChannelInfo and select(7, UnitChannelInfo(unit)) == false))
        then
            local duration = spell.parent and self.Spells[spell.parent].duration or spell.duration
            local _, class = UnitClass(unit)

            if UnitBuffByName(unit, "Calming Waters") then
                duration = duration * 0.5
            end

            self.units[destGUID] = self.units[destGUID] or {}
            self.units[destGUID].expires = GetTime() + duration
            self.units[destGUID].spellId = spellId
            self.units[destGUID].duration = duration
            self.units[destGUID].spellId = spell.parent and spell.parent or spellId

            -- Make sure we clear it after the duration
            C_Timer.After(duration, function()
                self:UNIT_AURA_ALL_UNITS()
            end)

            self:UNIT_AURA_ALL_UNITS()

            return

        end
    end
end

function BigDebuffs:UNIT_AURA_ALL_UNITS()
    for i = 1, #unitsWithRaid do
        local unit = unitsWithRaid[i]

        if self.AttachedFrames[unit] then
            self:ShowBigDebuffs(self.AttachedFrames[unit])
        end

        if not unit:match("^raid") and not unit:find("nameplate") then
            self:UNIT_AURA(nil, unit)
        end

		if unit:find("nameplate") then
			self:UNIT_AURA_NAMEPLATE(unit)
		end
    end
end

BigDebuffs.AttachedFrames = {}

local MAX_BUFFS = 6

function BigDebuffs:AddBigDebuffs(frame)
    if not frame or not frame.displayedUnit or not UnitIsPlayer(frame.displayedUnit) then return end
    local frameName = frame:GetName()
    if self.db.profile.raidFrames.increaseBuffs then
        for i = 4, MAX_BUFFS do
            local buffPrefix = frameName .. "Buff"
            local buffFrame = _G[buffPrefix .. i] or
                CreateFrame("Button", buffPrefix .. i, frame, "CompactBuffTemplate")
            buffFrame:ClearAllPoints()
            buffFrame:SetSize(frame.buffFrames[1]:GetSize())
            if math.fmod(i - 1, 3) == 0 then
                buffFrame:SetPoint("BOTTOMRIGHT", _G[buffPrefix .. i - 3], "TOPRIGHT")
            else
                buffFrame:SetPoint("BOTTOMRIGHT", _G[buffPrefix .. i - 1], "BOTTOMLEFT")
            end
        end
    end

    self.AttachedFrames[frame.displayedUnit] = frame

    frame.BigDebuffs = frame.BigDebuffs or {}
    local max = self.db.profile.raidFrames.maxDebuffs + 1 -- add a frame for warning debuffs
    for i = 1, max do
        local big = frame.BigDebuffs[i] or
            CreateFrame("Button", frameName .. "BigDebuffsRaid" .. i, frame, "CompactDebuffTemplate")
        big:ClearAllPoints()
        if i > 1 then
            if self.db.profile.raidFrames.anchor == "INNER" then
				big:SetPoint("BOTTOMLEFT", frame.BigDebuffs[i-1], "BOTTOMRIGHT", 0, 0)
            elseif self.db.profile.raidFrames.anchor == "LEFT" then
                big:SetPoint("BOTTOMRIGHT", frame.BigDebuffs[i-1], "BOTTOMLEFT", 0, 0)
            elseif self.db.profile.raidFrames.anchor == "RIGHT" then
                big:SetPoint("BOTTOMLEFT", frame.BigDebuffs[i-1], "BOTTOMRIGHT", 0, 0)
            end
        else
            if self.db.profile.raidFrames.anchor == "INNER" then
                big:SetPoint("BOTTOMLEFT", frame.debuffFrames[1], "BOTTOMLEFT", 0, 0)
            elseif self.db.profile.raidFrames.anchor == "LEFT" then
                big:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT", 0, 1)
            elseif self.db.profile.raidFrames.anchor == "RIGHT" then
                big:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", 0, 1)
            end
        end

        big.cooldown.noCooldownCount = not self.db.profile.raidFrames.cooldownCount

        big.cooldown:SetDrawEdge(false)
        frame.BigDebuffs[i] = big
        big:Hide()
        self.frames[frame] = true
        self:ShowBigDebuffs(frame)
    end
    return true
end

local pending = {}

hooksecurefunc("CompactUnitFrame_UpdateAll", function(frame)
    if not BigDebuffs.db.profile.raidFrames.enabled then return end

    local name = frame:GetName()
    if not name or not name:match("^Compact") then return end
    if InCombatLockdown() and not frame.BigDebuffs then
        if not pending[frame] then pending[frame] = true end
    else
        BigDebuffs:AddBigDebuffs(frame)
    end
end)

function BigDebuffs:PLAYER_TALENT_UPDATE()
	local specID = self:GetSpecializationInfo(self:GetSpecialization() or 1)
	self.specDispel = specID and self.specDispelTypes[specID] and self.specDispelTypes[specID]
end

function BigDebuffs:PLAYER_REGEN_ENABLED()
    for frame,_ in pairs(pending) do
        BigDebuffs:AddBigDebuffs(frame)
        pending[frame] = nil
    end
end

function BigDebuffs:IsPriorityDebuff(id)
    for i = 1, #BigDebuffs.PriorityDebuffs do
        if id == BigDebuffs.PriorityDebuffs[i] then
            return true
        end
    end
end

hooksecurefunc("CompactUnitFrame_HideAllDebuffs", HideBigDebuffs)

function BigDebuffs:IsDispellable(unit, dispelType)
    if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
        if (not dispelType) or (not self.dispelTypes) then return end
        if type(self.dispelTypes[dispelType]) == "function" then return self.dispelTypes[dispelType]() end

        -- dwarves can use Stoneform to remove diseases and poisons
        if (not self.dispelTypes[dispelType]) and
            unit == "player" and
            (dispelType == "Poison" or dispelType == "Disease")
        then
            return IsUsableSpell("Stoneform")
        end

        return self.dispelTypes[dispelType]
    else
        if not dispelType or not self.specDispel then return end
        if type(self.specDispel[dispelType]) == "function" then return self.specDispel[dispelType]() end
        return self.specDispel[dispelType]
    end
end

function BigDebuffs:GetDebuffSize(id, dispellable)
    if self.db.profile.raidFrames.pve > 0 then
        local _, instanceType = IsInInstance()
        if dispellable and instanceType and (instanceType == "raid" or instanceType == "party") then
            return self.db.profile.raidFrames.pve
        end
    end

    if not self.Spells[id] then return end
    id = self.Spells[id].parent or id -- Check for parent spellID

    local category = self.Spells[id].type

    if not category or not self.db.profile.raidFrames[category] then return end

    -- Check for user set
    if self.db.profile.spells[id] then
        if self.db.profile.spells[id].raidFrames and self.db.profile.spells[id].raidFrames == 0 then return end
        if self.db.profile.spells[id].size then return self.db.profile.spells[id].size end
    end

    if self.Spells[id].noraidFrames and
        (not self.db.profile.spells[id] or not self.db.profile.spells[id].raidFrames)
    then
        return
    end

    local dispellableSize = self.db.profile.raidFrames.dispellable[category]
    if dispellable and dispellableSize and dispellableSize > 0 then return dispellableSize end

    if self.db.profile.raidFrames[category] > 0 then
        return self.db.profile.raidFrames[category]
    end
end

-- For raid frames
function BigDebuffs:GetDebuffPriority(id)
    if not self.Spells[id] then return 0 end
    id = self.Spells[id].parent or id -- Check for parent spellID

    return self.db.profile.spells[id] and self.db.profile.spells[id].priority or
        self.db.profile.priority[self.Spells[id].type] or 0
end

-- For unit frames
function BigDebuffs:GetAuraPriority(id)
    if not self.Spells[id] then return end
    id = self.Spells[id].parent or id -- Check for parent spellID

    -- Make sure category is enabled
    if not self.db.profile.unitFrames[self.Spells[id].type] then return end

    -- Check for user set
    if self.db.profile.spells[id] then
        if self.db.profile.spells[id].unitFrames and self.db.profile.spells[id].unitFrames == 0 then return end
        if self.db.profile.spells[id].priority then return self.db.profile.spells[id].priority end
    end

    if self.Spells[id].nounitFrames and
        (not self.db.profile.spells[id] or not self.db.profile.spells[id].unitFrames)
    then
        return
    end

    return self.db.profile.priority[self.Spells[id].type] or 0
end

-- For nameplates
function BigDebuffs:GetNameplatesPriority(id)
    if not self.Spells[id] then return end
    id = self.Spells[id].parent or id -- Check for parent spellID

    -- Make sure category is enabled
    if not self.db.profile.nameplates[self.Spells[id].type] then return end

    -- Check for user set
    if self.db.profile.spells[id] then
        if self.db.profile.spells[id].nameplates and self.db.profile.spells[id].nameplates == 0 then return end
        if self.db.profile.spells[id].priority then return self.db.profile.spells[id].priority end
    end

    if self.Spells[id].nonameplates and
        (not self.db.profile.spells[id] or not self.db.profile.spells[id].nameplates)
    then
        return
    end

    return self.db.profile.priority[self.Spells[id].type] or 0
end

local function CompactUnitFrame_UtilSetDebuff(debuffFrame, unit, index, filter, isBossAura, isBossBuff, ...)
    local UnitDebuff = BigDebuffs.test and UnitDebuffTest or UnitDebuff
    -- make sure you are using the correct index here!
    --isBossAura says make this look large.
    --isBossBuff looks in HELPFULL auras otherwise it looks in HARMFULL ones
    local name, icon, count, debuffType, duration, expirationTime, unitCaster, _, _, spellId = ...;

    if index == -1 then
        -- it's an interrupt
        local spell = BigDebuffs.units[UnitGUID(unit)]
        spellId = spell.spellId
        icon = GetSpellTexture(spellId)
        count = 1
        duration = spell.duration
        expirationTime = spell.expires
    else
        if name == nil then
            -- for backwards compatibility - this functionality will be removed in a future update
            if unit then
                if (isBossBuff) then
                    name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, _, _, spellId = UnitBuff(unit, index, filter);
                else
                    name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, _, _, spellId = UnitDebuff(unit, index, filter);
                end
            else
                return;
            end
        end
    end

    debuffFrame.filter = filter;
    debuffFrame.icon:SetTexture(icon);
    if ( count > 1 ) then
        local countText = count;
        if ( count >= 100 ) then
            countText = BUFF_STACKS_OVERFLOW;
        end
        debuffFrame.count:Show();
        debuffFrame.count:SetText(countText);
    else
        debuffFrame.count:Hide();
    end
    debuffFrame:SetID(index);

    local enabled = expirationTime and expirationTime ~= 0;
    if enabled then
        local startTime = expirationTime - duration;
        local text = debuffFrame.cooldown:GetRegions();
		if text then
        text:SetFont(LibSharedMedia:Fetch("font", BigDebuffs.db.profile.raidFrames.cooldownFont),
            BigDebuffs.db.profile.raidFrames.cooldownFontSize, BigDebuffs.db.profile.raidFrames.cooldownFontEffect);
		end
        CooldownFrame_Set(debuffFrame.cooldown, startTime, duration, true);
    else
        CooldownFrame_Clear(debuffFrame.cooldown);
    end

    local color = DebuffTypeColor[debuffType] or DebuffTypeColor["none"];
    debuffFrame.border:SetVertexColor(color.r, color.g, color.b);

    debuffFrame.isBossBuff = isBossBuff;
    if ( isBossAura ) then
        local size = min(debuffFrame.baseSize + BOSS_DEBUFF_SIZE_INCREASE, debuffFrame.maxHeight);
        debuffFrame:SetSize(size, size);
    else
        debuffFrame:SetSize(debuffFrame.baseSize, debuffFrame.baseSize);
    end

    debuffFrame:Show();
end

local Default_CompactUnitFrame_UtilIsPriorityDebuff = CompactUnitFrame_UtilIsPriorityDebuff

local function CompactUnitFrame_UtilIsPriorityDebuff(...)
	local _,_,_,_,_,_,_,_,_,_, spellId = UnitDebuff(...)
	return BigDebuffs:IsPriorityDebuff(spellId) or Default_CompactUnitFrame_UtilIsPriorityDebuff(...)
end

local Default_SpellGetVisibilityInfo = SpellGetVisibilityInfo

local function CompactUnitFrame_UtilShouldDisplayBuff(unit, index, filter)
	local name, _, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId, canApplyAura = UnitBuff(unit, index, filter);

	local hasCustom, alwaysShowMine, showForMySpec = SpellGetVisibilityInfo(spellId, UnitAffectingCombat("player") and "RAID_INCOMBAT" or "RAID_OUTOFCOMBAT");

	local showAllClassBuffs = BigDebuffs.db.profile.raidFrames.showAllClassBuffs and canApplyAura

	if ( hasCustom ) then
		return showForMySpec or (alwaysShowMine and (showAllClassBuffs or unitCaster == "player" or unitCaster == "pet" or unitCaster == "vehicle"));
	else
		return (showAllClassBuffs or unitCaster == "player" or unitCaster == "pet" or unitCaster == "vehicle") and canApplyAura and not SpellIsSelfBuff(spellId);
	end
end

local function CompactUnitFrame_UtilShouldDisplayDebuff(unit, index, filter)
	local name, _, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId, canApplyAura, isBossAura = UnitDebuff(unit, index, filter);

	local hasCustom, alwaysShowMine, showForMySpec = SpellGetVisibilityInfo(spellId, UnitAffectingCombat("player") and "RAID_INCOMBAT" or "RAID_OUTOFCOMBAT");

	local showAllClassBuffs = BigDebuffs.db.profile.raidFrames.showAllClassBuffs and canApplyAura

	if ( hasCustom ) then
		return showForMySpec or (alwaysShowMine and (showAllClassBuffs or unitCaster == "player" or unitCaster == "pet" or unitCaster == "vehicle") );   --Would only be "mine" in the case of something like forbearance.
	else
		return true;
	end
end

local function CompactUnitFrame_UtilIsBossAura(unit, index, filter, checkAsBuff)
	-- make sure you are using the correct index here!	allAurasIndex ~= debuffIndex
	local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId, canApplyAura, isBossAura;
	if (checkAsBuff) then
		name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId, canApplyAura, isBossAura = UnitBuff(unit, index, filter);
	else
		name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId, canApplyAura, isBossAura = UnitDebuff(unit, index, filter);
	end
	return isBossAura;
end


hooksecurefunc("CompactUnitFrame_UpdateDebuffs", function(frame)
	if ( not frame.debuffFrames or not frame.optionTable.displayDebuffs ) then
		CompactUnitFrame_HideAllDebuffs(frame);
		return;
	end

	local index = 1;
	local frameNum = 1;
	local filter = nil;
	local maxDebuffs = frame.maxDebuffs;
	--Show both Boss buffs & debuffs in the debuff location
	--First, we go through all the debuffs looking for any boss flagged ones.
	while ( frameNum <= maxDebuffs ) do
		local debuffName = UnitDebuff(frame.displayedUnit, index, filter);
		if ( debuffName ) then
			if ( CompactUnitFrame_UtilIsBossAura(frame.displayedUnit, index, filter, false) ) then
				local debuffFrame = frame.debuffFrames[frameNum];
				CompactUnitFrame_UtilSetDebuff(debuffFrame, frame.displayedUnit, index, filter, true, false);
				frameNum = frameNum + 1;
				--Boss debuffs are about twice as big as normal debuffs, so display one less.
				local bossDebuffScale = (debuffFrame.baseSize + BOSS_DEBUFF_SIZE_INCREASE)/debuffFrame.baseSize
				maxDebuffs = maxDebuffs - (bossDebuffScale - 1);
			end
		else
			break;
		end
		index = index + 1;
	end
	--Then we go through all the buffs looking for any boss flagged ones.
	index = 1;
	while ( frameNum <= maxDebuffs ) do
		local debuffName = UnitBuff(frame.displayedUnit, index, filter);
		if ( debuffName ) then
			if ( CompactUnitFrame_UtilIsBossAura(frame.displayedUnit, index, filter, true) ) then
				local debuffFrame = frame.debuffFrames[frameNum];
				CompactUnitFrame_UtilSetDebuff(debuffFrame, frame.displayedUnit, index, filter, true, true);
				frameNum = frameNum + 1;
				--Boss debuffs are about twice as big as normal debuffs, so display one less.
				local bossDebuffScale = (debuffFrame.baseSize + BOSS_DEBUFF_SIZE_INCREASE)/debuffFrame.baseSize
				maxDebuffs = maxDebuffs - (bossDebuffScale - 1);
			end
		else
			break;
		end
		index = index + 1;
	end

	--Now we go through the debuffs with a priority (e.g. Weakened Soul and Forbearance)
	index = 1;
	while ( frameNum <= maxDebuffs ) do
		local debuffName = UnitDebuff(frame.displayedUnit, index, filter);
		if ( debuffName ) then
			if ( CompactUnitFrame_UtilIsPriorityDebuff(frame.displayedUnit, index, filter) ) then
				local debuffFrame = frame.debuffFrames[frameNum];
				CompactUnitFrame_UtilSetDebuff(debuffFrame, frame.displayedUnit, index, filter, false, false);
				frameNum = frameNum + 1;
			end
		else
			break;
		end
		index = index + 1;
	end

	if ( frame.optionTable.displayOnlyDispellableDebuffs ) then
		filter = "RAID";
	end

	index = 1;
	--Now, we display all normal debuffs.
	if ( frame.optionTable.displayNonBossDebuffs ) then
	while ( frameNum <= maxDebuffs ) do
		local debuffName = UnitDebuff(frame.displayedUnit, index, filter);
		if ( debuffName ) then
			if ( CompactUnitFrame_UtilShouldDisplayDebuff(frame.displayedUnit, index, filter) and not CompactUnitFrame_UtilIsBossAura(frame.displayedUnit, index, filter, false) and
				not CompactUnitFrame_UtilIsPriorityDebuff(frame.displayedUnit, index, filter)) then
				local debuffFrame = frame.debuffFrames[frameNum];
				CompactUnitFrame_UtilSetDebuff(debuffFrame, frame.displayedUnit, index, filter, false, false);
				frameNum = frameNum + 1;
			end
		else
			break;
		end
		index = index + 1;
	end
	end

	for i=frameNum, frame.maxDebuffs do
		local debuffFrame = frame.debuffFrames[i];
		debuffFrame:Hide();
	end

	BigDebuffs:ShowBigDebuffs(frame)
end)

-- Show extra buffs
hooksecurefunc("CompactUnitFrame_UpdateBuffs", function(frame)
	if ( not frame.buffFrames or not frame.optionTable.displayBuffs ) then
		CompactUnitFrame_HideAllBuffs(frame);
		return;
	end

	if not UnitIsPlayer(frame.displayedUnit) then
		return
	end

	if (not BigDebuffs.db.profile.raidFrames.increaseBuffs) and
		(not BigDebuffs.db.profile.raidFrames.showAllClassBuffs)
	then
		return
	end

	local maxBuffs = BigDebuffs.db.profile.raidFrames.increaseBuffs and MAX_BUFFS or frame.maxBuffs

	local index = 1;
	local frameNum = 1;
	local filter = nil;
	while ( frameNum <= maxBuffs ) do
		local buffName = UnitBuff(frame.displayedUnit, index, filter);
		if ( buffName ) then
			if ( CompactUnitFrame_UtilShouldDisplayBuff(frame.displayedUnit, index, filter) and
				not CompactUnitFrame_UtilIsBossAura(frame.displayedUnit, index, filter, true) )
			then
				local buffFrame = frame.buffFrames[frameNum];
				if buffFrame then
					CompactUnitFrame_UtilSetBuff(buffFrame, frame.displayedUnit, index, filter);
					frameNum = frameNum + 1;
				end
			end
		else
			break;
		end
		index = index + 1;
	end
	for i=frameNum, maxBuffs do
		local buffFrame = frame.buffFrames[i];
		if buffFrame then buffFrame:Hide() end
	end
end)


function BigDebuffs:ShowBigDebuffs(frame)
    if (not self.db.profile.raidFrames.enabled) or
        (not frame.debuffFrames) or
        (not frame.BigDebuffs) or
        (not self:ShowInRaids()) or
        (not UnitIsPlayer(frame.displayedUnit))
    then
        return
    end

    local UnitDebuff = self.test and UnitDebuffTest or UnitDebuff

    HideBigDebuffs(frame)

    local debuffs = {}
    local big
    local now = GetTime()
    local warning, warningId

    for i = 1, 40 do
        local _,_,_, dispelType, _, time, caster, _,_, id = UnitDebuff(frame.displayedUnit, i)
        if id then
            local reaction = caster and UnitReaction("player", caster) or 0
            local friendlySmokeBomb = id == 212183 and reaction > 4
            local size = self:GetDebuffSize(id, self:IsDispellable(frame.displayedUnit, dispelType))
            if size and not friendlySmokeBomb then
                big = true
                local duration = time and time - now or 0
                tinsert(debuffs, { i, size, duration, self:GetDebuffPriority(id) })
            elseif self.db.profile.raidFrames.redirectBliz or
            (self.db.profile.raidFrames.anchor == "INNER" and not self.db.profile.raidFrames.hideBliz) then
                if not frame.optionTable.displayOnlyDispellableDebuffs or
                    self:IsDispellable(frame.displayedUnit, dispelType)
                then
                    -- duration 0 to preserve Blizzard order
                    tinsert(debuffs, { i, self.db.profile.raidFrames.default, 0, 0 })
                end
            end

            -- Set warning debuff
            if WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC then
                local k
                for j = 1, #self.WarningDebuffs do
                    if id == self.WarningDebuffs[j] and
                    self.db.profile.raidFrames.warningList[id] and
                    not friendlySmokeBomb and
                    (not k or j < k) then
                        k = j
                        warning = i
                        warningId = id
                    end
                end
            end

        end
    end

    -- check for interrupts
    local guid = UnitGUID(frame.displayedUnit)
    if guid and self.units[guid] and self.units[guid].expires and self.units[guid].expires > GetTime() then
        local spellId = self.units[guid].spellId
        local size = self:GetDebuffSize(spellId, false)
        if size then
            big = true
            tinsert(debuffs, { -1, size, 0, self:GetDebuffPriority(spellId) })
        end
    end

    if #debuffs > 0 then
        -- insert the warning debuff if it exists and we have a big debuff
        if big and warning then
            local size = self.db.profile.raidFrames.warning
            -- remove duplicate
            for k,v in pairs(debuffs) do
                if v[1] == warning then
                    if self.Spells[warningId] then size = v[2] end -- preserve the size
                    table.remove(debuffs, k)
                    break
                end
            end
            tinsert(debuffs, { warning, size, 0, 0, true })
        else
            warning = nil
        end

        -- sort by priority > size > duration > index
        table.sort(debuffs, function(a, b)
            if a[4] == b[4] then
                if a[2] == b[2] then
                    if a[3] < b[3] then return true end
                    if a[3] == b[3] then return a[1] < b[1] end
                end
                return a[2] > b[2]
            end
            return a[4] > b[4]
        end)

        local index = 1

        if self.db.profile.raidFrames.hideBliz or
        self.db.profile.raidFrames.anchor == "INNER" or
        self.db.profile.raidFrames.redirectBliz then
            CompactUnitFrame_HideAllDebuffs(frame)
        end

        for i = 1, #debuffs do
            if index <= self.db.profile.raidFrames.maxDebuffs or debuffs[i][1] == warning then
                if not frame.BigDebuffs[index] then break end
                frame.BigDebuffs[index].baseSize = frame:GetHeight() * debuffs[i][2] * 0.01
                CompactUnitFrame_UtilSetDebuff(frame.BigDebuffs[index],
                    frame.displayedUnit, debuffs[i][1], nil, false, false)
                frame.BigDebuffs[index].cooldown:SetSwipeColor(0, 0, 0, 0.7)
                index = index + 1
            end
        end
    end
end

function BigDebuffs:IsPriorityBigDebuff(id)
    if not self.Spells[id] then return end
    id = self.Spells[id].parent or id -- Check for parent spellID
    return self.Spells[id].priority
end

function BigDebuffs:UNIT_AURA(event,unit,...)
	print(unit:gsub("%d", ""))
    if not self.db.profile.unitFrames.enabled or
        not self.db.profile.unitFrames[unit:gsub("%d", "")].enabled or
        (self:GetNumGroupMembers() > 5 and unit:match("party"))
    then
        return
    end

    self:AttachUnitFrame(unit)

    local frame = self.UnitFrames[unit]
    if not frame then return end

    local UnitDebuff = BigDebuffs.test and UnitDebuffTest or UnitDebuff

    local now = GetTime()
    local left, priority, duration, expires, icon, debuff, buff, interrupt = 0, 0

    for i = 1, 40 do
        -- Check debuffs
        local _, n, _,_, d, e, caster, _,_, id = UnitDebuff(unit, i)
        if id then
            if self.Spells[id] then
                local reaction = caster and UnitReaction("player", caster) or 0
                local friendlySmokeBomb = id == 212183 and reaction > 4
                local p = self:GetAuraPriority(id)
                if p and p >= priority and not friendlySmokeBomb then
                    if p > priority or self:IsPriorityBigDebuff(id) or e == 0 or e - now > left then
                        left = e - now
                        duration = d
                        debuff = i
                        priority = p
                        expires = e
                        icon = n
                    end
                end
            end
        end

        -- Check buffs
		_, n, _,_, d, e, caster, _,_, id = UnitBuff(unit, i)
        if id then
            if self.Spells[id] then
                local p = self:GetAuraPriority(id)
                if p and p >= priority then
                    if p > priority or self:IsPriorityBigDebuff(id) or e == 0 or e - now > left then
                        left = e - now
                        duration = d
                        debuff = i
                        priority = p
                        expires = e
                        icon = n
                        buff = true
                    end
                end
            end
        end
    end

    -- Check for interrupt
    local guid = UnitGUID(unit)
    if guid and self.units[guid] and self.units[guid].expires and self.units[guid].expires > GetTime() then
        local spell = self.units[guid]
        local spellId = spell.spellId
        local p = self:GetAuraPriority(spellId)
        if p and p >= priority then
            left = spell.expires - now
            duration = self.Spells[spellId].duration
            debuff = spellId
            expires = spell.expires
            icon = GetSpellTexture(spellId)
            interrupt = spellId
        end
    end


    if debuff then
        if duration < 1 then duration = 1 end -- auras like Solar Beam don't have a duration

        if frame.current ~= icon then
            if frame.blizzard then
                -- Blizzard Frame

                -- fix Obsidian Claw icon
                icon = icon == 611425 and 1508487 or icon

                frame.icon:SetTexture(icon)

                if not frame.mask then
                    frame.mask = frame:CreateMaskTexture()
                    frame.mask:SetAllPoints(frame.icon)
                    frame.mask:SetTexture("Interface/CHARACTERFRAME/TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
                    frame.icon:AddMaskTexture(frame.mask)
                end
            else
                frame.icon:SetTexture(icon)
            end
        end

        frame.cooldown:SetCooldown(expires - duration, duration)
        frame:Show()
        frame.cooldown:SetSwipeColor(0, 0, 0, 0.6)

        -- set for tooltips
        frame:SetID(debuff)
        frame.buff = buff
        frame.interrupt = interrupt
        frame.current = icon
    else
        frame:Hide()
        frame.current = nil
    end
end

function BigDebuffs:PLAYER_FOCUS_CHANGED()
    self:UNIT_AURA(nil,"focus")
end

function BigDebuffs:PLAYER_TARGET_CHANGED()
    self:UNIT_AURA(nil,"target")
end

function BigDebuffs:UNIT_PET()
    self:UNIT_AURA(nil,"pet")
end

function BigDebuffs:ShowInRaids()
    local grpSize = self:GetNumGroupMembers();
    local inRaid = self.db.profile.raidFrames.inRaid;
    if ( inRaid.hide and grpSize > inRaid.size ) then
        return false;
    end

    return true;
end

SLASH_BigDebuffs1 = "/bd"
SLASH_BigDebuffs2 = "/bigdebuffs"
SlashCmdList.BigDebuffs = function(msg)
    InterfaceOptionsFrame_OpenToCategory(addonName)
    InterfaceOptionsFrame_OpenToCategory(addonName)
end
