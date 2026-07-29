class_name Spellbook extends Item

@export var spells: Array[Spell] = []

## If you combine two books, you can unlock next levels of some spells, too.
@export var unlockable_spells: Array[Spell] = []

func _init() -> void:
	first_get_text = "Finally! A spellbook! These portals mess with me memory, so this should help me remember a spell or two!"

func is_mergeable() -> bool:
	return true

func can_be_combined(_me: InventoryDetail, them: InventoryDetail) -> bool:
	return them.item is Spellbook

func combine(me: InventoryDetail, them: InventoryDetail) -> void:
	if !can_be_combined(me, them): # ONE MORE FOR GOOD MEASURE
		return
	var potential_new_spells: Array[Spell] = []
	var new_book: Spellbook = me.item.duplicate()
	new_book.name = "Merged Spellbook"
	potential_new_spells.append_array((me.item as Spellbook).unlockable_spells)
	potential_new_spells.append_array((them.item as Spellbook).unlockable_spells)
	var spell_string_parts: PackedStringArray = []
	for s in (them.item as Spellbook).spells:
		if !new_book.spells.has(s):
			new_book.spells.append(s)
			spell_string_parts.append(s.name)
	while potential_new_spells.size() > 0:
		var s: Spell = potential_new_spells.pick_random()
		if new_book.spells.has(s):
			potential_new_spells.erase(s)
		else:
			new_book.spells.append(s)
			spell_string_parts.append(s.name)
			break
	spell_string_parts[-1] = "and %s" % spell_string_parts[-1] # Oxford comma wins because it makes this code easier.
	new_book.description = "I combined multiple spellbooks to create this one. It has runes for the %s spells." % ", ".join(spell_string_parts)
	me.item = new_book
