-- get num group members backport
local addonName = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local LibGroupTalents = LibStub ("LibGroupTalents-1.0")

function addon:IsInRaid() 
    return GetNumRaidMembers() > 0
end

function addon:IsInGroup()
    return (GetNumRaidMembers() == 0 and GetNumPartyMembers() > 0)
end

function addon:GetNumGroupMembers()
    if addon:IsInRaid() then 
        return GetNumRaidMembers()
    else
        return GetNumPartyMembers()
    end
end


--return the specialization of the player it self

local specIDs = {
	["MAGE"] = {62, 63, 64},
	["PRIEST"] = {256, 257, 258},
	["ROGUE"] = {259, 260, 261},
	["WARLOCK"] = {265, 266, 267},
	["WARRIOR"] = {71, 72, 73},
	["PALADIN"] = {65, 66, 70},
	["DEATHKNIGHT"] = {250, 251, 252},
	["DRUID"] = {102, 103, 104, 105},
	["HUNTER"] = {253, 254, 255},
	["SHAMAN"] = {262, 263, 264},
}

function addon:SpecIDToClass(specID)
	for className, classSpecIDs in pairs(specIDs) do
		for _, classSpecID in ipairs(classSpecIDs) do
			if classSpecID == specID then
				return className
			end
		end
	end
end

local specInfo = {
	--MAGE
		--arcane
		[62]	= {
			[1]=62,
			[2]="Arcane",
			[3]=[[Manipulates raw Arcane magic, destroying enemies with overwhelming power.
			
			Preferred Weapon: Staff, Wand, Dagger, Sword]],
			[4]=135932,
			[5]="DAMAGER",
			[6]="MAGE",
			[7]="Mage"
		},
		--fire
		[63] = {
			[1]=63,
			[2]="Fire",
			[3]=[[Focuses the pure essence of Fire magic, assaulting enemies with combustive flames.
			
			Preferred Weapon: Staff, Wand, Dagger, Sword]],
			[4]=135810,
			[5]="DAMAGER",
			[6]="MAGE",
			[7]="Mage"
		},
		--frost
		[64] = {
			[1]=64,
			[2]="Frost",
			[3]=[[Freezes enemies in their tracks and shatters them with Frost magic.
			
			Preferred Weapon: Staff, Wand, Dagger, Sword]],
			[4]=135846,
			[5]="DAMAGER",
			[6]="MAGE",
			[7]="Mage"
		},

	--PRIEST
		--discipline
		[256] = {
			[1]=256,
			[2]="Discipline",
			[3]=[[Uses magic to shield allies from taking damage as well as heal their wounds.
			
			Preferred Weapon: Staff, Wand, Dagger, Mace]],
			[4]=135940,
			[5]="HEALER",
			[6]="PRIEST",
			[7]="Priest"
		},
		--holy
		[257] = {
			[1]=257,
			[2]="Holy",
			[3]=[[A versatile healer who can reverse damage on individuals or groups and even heal from beyond the grave.
			
			Preferred Weapon: Staff, Wand, Dagger, Mace]],
			[4]=237542,
			[5]="HEALER",
			[6]="PRIEST",
			[7]="Priest"
		},
		--shadow priest
		[258] = {
			[1]=258,
			[2]="Shadow",
			[3]=[[Uses sinister Shadow magic and terrifying Void magic to eradicate enemies.
			
			Preferred Weapon: Staff, Wand, Dagger, Mace]],
			[4]=136207,
			[5]="DAMAGER",
			[6]="PRIEST",
			[7]="Priest"
		},

	--ROGUE
		--assassination
		[259] = {
			[1]=259,
			[2]="Assassination",
			[3]=[[A deadly master of poisons who dispatches victims with vicious dagger strikes.
			
			Preferred Weapons: Daggers]],
			[4]=236270,
			[5]="DAMAGER",
			[6]="ROGUE",
			[7]="Rogue"
		},
		--combat
		[260] = {
			[1]=260,
			[2]="Combat",
			[3]=[[A swashbuckler who uses agility and guile to stand toe-to-toe with enemies.
			
			Preferred Weapons: Daggers]],
			[4]=236270,
			[5]="DAMAGER",
			[6]="ROGUE",
			[7]="Rogue"
		},
		--subtlety
		[261] = {
			[1]=261,
			[2]="Subtlety",
			[3]=[[A dark stalker who leaps from the shadows to ambush his unsuspecting prey.
			
			Preferred Weapons: Daggers]],
			[4]=132320,
			[5]="DAMAGER",
			[6]="ROGUE",
			[7]="Rogue"
		},

	--WARLOCK
		--affliction
		[265] = {
			[1]=265,
			[2]="Affliction",
			[3]=[[A master of shadow magic who specializes in drains and damage-over-time spells.
			
			Preferred Weapon: Staff, Wand, Dagger, Sword]],
			[4]=136145,
			[5]="DAMAGER",
			[6]="WARLOCK",
			[7]="Warlock"
		},
		--demo
		[266] = {
			[1]=266,
			[2]="Demonology",
			[3]=[[A commander of demons who twists the souls of his army into devastating power.
			
			Preferred Weapon: Staff, Wand, Dagger, Sword]],
			[4]=136172,
			[5]="DAMAGER",
			[6]="WARLOCK",
			[7]="Warlock"
		},
		--destro
		[267] = {
			[1]=267,
			[2]="Destruction",
			[3]=[[A master of chaos who calls down fire to burn and demolish enemies.
			
			Preferred Weapon: Staff, Wand, Dagger, Sword]],
			[4]=136186,
			[5]="DAMAGER",
			[6]="WARLOCK",
			[7]="Warlock"
		},

	--WARRIOR
		--Arms
		[71] = {
			[1]=71,
			[2]="Arms",
			[3]=[[A battle-hardened master of weapons, using mobility and overpowering attacks to strike his opponents down.
			
			Preferred Weapon: Two-Handed Axe, Mace, Sword]],
			[4]=132355,
			[5]="DAMAGER",
			[6]="WARRIOR",
			[7]="Warrior"
		},
		--Fury
		[72] = {
			[1]=72,
			[2]="Fury",
			[3]=[[A furious berserker unleashing a flurry of attacks to carve his opponents to pieces.
			
			Preferred Weapons: Dual Axes, Maces, Swords]],
			[4]=132347,
			[5]="DAMAGER",
			[6]="WARRIOR",
			[7]="Warrior"
		},
		--Protection
		[73] = {
			[1]=73,
			[2]="Protection",
			[3]=[[A stalwart protector who uses a shield to safeguard himself and his allies.
			
			Preferred Weapon: Axe, Mace, Sword, and Shield]],
			[4]=132341,
			[5]="TANK",
			[6]="WARRIOR",
			[7]="Warrior"
		},

	--PALADIN
		--holy
		[65] = {
			[1]=65,
			[2]="Holy",
			[3]=[[Invokes the power of the Light to heal and protect allies and vanquish evil from the darkest corners of the world.\r\
			
			Preferred Weapon: Sword, Mace, and Shield]],
			[4]=135920,
			[5]="HEALER",
			[6]="PALADIN",
			[7]="Paladin"
		},

		--protection
		[66] = {
			[1]=66,
			[2]="Protection",
			[3]=[[Uses Holy magic to shield himself and defend allies from attackers.
			
			Preferred Weapon: Sword, Mace, Axe, and Shield]],
			[4]=236264,
			[5]="TANK",
			[6]="PALADIN",
			[7]="Paladin"
		},

		--retribution
		[70] = {
			[1]=70,
			[2]="Retribution",
			[3]=[[A righteous crusader who judges and punishes opponents with weapons and Holy magic.
			
			Preferred Weapon: Two-Handed Sword, Mace, Axe]],
			[4]=135873,
			[5]="DAMAGER",
			[6]="PALADIN",
			[7]="Paladin"
		},

	--DEATH KNIGHT
		--unholy
		[252] = {
			[1]=252,
			[2]="Unholy",
			[3]=[[A master of death and decay, spreading infection and controlling undead minions to do his bidding.
			
			Preferred Weapon: Two-Handed Axe, Mace, Sword]],
			[4]=135775,
			[5]="DAMAGER",
			[6]="DEATHKNIGHT",
			[7]="Death Knight"
		},
		--frost
		[251] = {
			[1]=251,
			[2]="Frost",
			[3]=[[An icy harbinger of doom, channeling runic power and delivering vicious weapon strikes.
			
			Preferred Weapons: Dual Axes, Maces, Swords]],
			[4]=135773,
			[5]="DAMAGER",
			[6]="DEATHKNIGHT",
			[7]="Death Knight"
		},
		--blood
		[250] = {
			[1]=250,
			[2]="Blood",
			[3]=[[A dark guardian who manipulates and corrupts life energy to sustain himself in the face of an enemy onslaught.
			
			Preferred Weapon: Two-Handed Axe, Mace, Sword]],
			[4]=135770,
			[5]="TANK",
			[6]="DEATHKNIGHT",
			[7]="Death Knight"
		},

	--DRUID
		--balance
		[102] = {
			[1]=102,
			[2]="Balance",
			[3]=[[Can shapeshift into a powerful Moonkin, balancing the power of Arcane and Nature magic to destroy enemies.
			
			Preferred Weapon: Staff, Dagger, Mace]],
			[4]=136096,
			[5]="DAMAGER",
			[6]="DRUID",
			[7]="Druid"
		},
		--feral
		[103] = {
			[1]=103,
			[2]="Feral",
			[3]=[[Takes on the form of a great cat to deal damage with bleeds and bites.
			
			Preferred Weapon: Staff, Polearm]],
			[4]=132115,
			[5]="DAMAGER",
			[6]="DRUID",
			[7]="Druid"
		},
		-- guardian
		[104] = {			
			[1]=104,
			[2]="Guardian",
			[3]=[[Takes on the form of a mighty bear to absorb damage and protect allies.
			
			Preferred Weapon: Staff, Polearm]],
			[4]=132276,
			[5]="TANK",
			[6]="DRUID",
			[7]="Druid"
		},
		--restoration
		[105] = {
			[1]=105,
			[2]="Restoration",
			[3]=[[Channels powerful Nature magic to regenerate and revitalize allies.
			
			Preferred Weapon: Staff, Dagger, Mace]],
			[4]=136041,
			[5]="HEALER",
			[6]="DRUID",
			[7]="Druid"
		},

	--HUNTER
		--beast mastery
		[253] = {
			[1]=253,
			[2]="Beast Mastery",
			[3]=[[A master of the wild who can tame a wide variety of beasts to assist him in combat.
			
			Preferred Weapon: Bow, Crossbow, Gun]],
			[4]=461112,
			[5]="DAMAGER",
			[6]="HUNTER",
			[7]="Hunter"
		},
		--marksmanship
		[254] = {
			[1]=254,
			[2]="Marksmanship",
			[3]=[[A master sharpshooter who excels in bringing down enemies from afar.
			
			Preferred Weapon: Bow, Crossbow, Gun]],
			[4]=236179,
			[5]="DAMAGER",
			[6]="HUNTER",
			[7]="Hunter"
		},
		--survival
		[255] = {
			[1]=255,
			[2]="Survival",
			[3]=[[An adaptive ranger who favors using explosives, animal venom, and coordinated attacks with their bonded beast.
			
			Preferred Weapon: Polearm, Staff]],
			[4]=461113,
			[5]="DAMAGER",
			[6]="HUNTER",
			[7]="Hunter"
		},

	--SHAMAN
		--elemental
		[262] = {
			[1]=262,
			[2]="Elemental",
			[3]=[[A spellcaster who harnesses the destructive forces of nature and the elements.
			
			Preferred Weapon: Mace, Dagger, and Shield]],
			[4]=136048,
			[5]="DAMAGER",
			[6]="SHAMAN",
			[7]="Shaman"
		},
		--enhancement
		[263] = {
			[1]=263,
			[2]="Enhancement",
			[3]=[[A totemic warrior who strikes foes with weapons imbued with elemental power.
			
			Preferred Weapons: Dual Axes, Maces, Fist Weapons]],
			[4]=237581,
			[5]="DAMAGER",
			[6]="SHAMAN",
			[7]="Shaman"
		},
		--restoration
		[264] = {
			[1]=264,
			[2]="Restoration",
			[3]=[[A healer who calls upon ancestral spirits and the cleansing power of water to mend allies' wounds.
			
			Preferred Weapon: Mace, Dagger, and Shield]],
			[4]=136052,
			[5]="HEALER",
			[6]="SHAMAN",
			[7]="Shaman"
		},
}

local function GetFeralSubSpec(unit, talentGroup)
	local guardianSpells = {
		[57880] = 1, -- Natural Reactions
		[80313] = 0, -- Pulverize
		[16929] = 2, -- Thick Hide
	}
	for k,v in pairs(guardianSpells) do 
		local points = LibGroupTalents:UnitHasTalent(unit, GetSpellInfo(k), talentGroup) or 0
		if points <= v then
			return 2
		end
	end
	return 3 -- we are a guardian druid
end

function addon:GetSpecializationInfoByID (specId, ...)
	if (GetSpecializationInfoByID) then
		return GetSpecializationInfoByID (specId, ...)
	end
	return unpack(specInfo[specId] or {})
end

function addon:GetSpecializationInfo(index)
	local _, class = UnitClass("player")
	return specIDs[class] and specIDs[class][index] or 0
end

function addon:GetSpecialization(unit)
	unit = unit or "player"
	local talentGroup = LibGroupTalents:GetActiveTalentGroup(unit)
	local maxPoints, specIdx = 0, 0

	for i = 1, MAX_TALENT_TABS do
		local _, name, _, icon, pointsSpent = LibGroupTalents:GetTalentTabInfo(unit, i, talentGroup)
		if pointsSpent and pointsSpent ~= 0 then
			if maxPoints < pointsSpent then
				maxPoints = pointsSpent
				if select(2, UnitClass(unit)) == "DRUID" and i >= 2 then
					if i == 3 then 
						specIdx = 4
					elseif i == 2 then 
						specIdx = GetFeralSubSpec(unit, talentGroup)
					end
				else
					specIdx = i
				end
			end
		end
	end
	return specIdx
end