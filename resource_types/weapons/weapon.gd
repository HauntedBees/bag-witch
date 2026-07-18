class_name Weapon extends Item

## If this weapon is a spell.
@export var is_spell := false

## Once you no longer have the spellbook for this spell in your inventory, you'll have this much ammo remaining.
@export var spell_ammo := 5

## Damage dealt.
@export var damage_range := Vector2i.ZERO

## How far back the enemy should be knocked when hit. Should be a big number.
@export var knockback := 0.0

## How far the enemy should be knocked up (ayy lmao) when hit. Should be a small number.
@export var additional_y_knockback := 0.0

## Various metadata properties can be increased by this attack.
@export var metadata_increase_ranges: Dictionary[BWEnum.Effect, Vector2] = {}

func can_be_combined(me: InventoryDetail, them: InventoryDetail) -> bool:
	if them.item is not ItemMod:
		return false
	var mod: ItemMod = them.item
	if Player.data.mind < mod.mind_requirement:
		return false
	if mod.connects_to != self:
		return false
	return !me.has_mod(mod.mod_name)

func combine(me: InventoryDetail, them: InventoryDetail) -> void:
	if !can_be_combined(me, them): # ONE MORE FOR GOOD MEASURE
		return
	me.add_mod(them.item)
