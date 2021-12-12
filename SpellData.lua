local _, T = ...

T.Spells = {
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