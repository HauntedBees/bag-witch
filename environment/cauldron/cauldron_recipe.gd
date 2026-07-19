class_name CauldronRecipe extends Resource

@export_custom(SRP_HINT.RESOURCE_PATH, "Item") var output: String

@export_custom(SRP_HINT.RESOURCE_PATH, "PackedScene") var item_1_path: String
@export var item_1_type := Item.ItemType.None

@export_custom(SRP_HINT.RESOURCE_PATH, "PackedScene") var item_2_path: String
@export var item_2_type := Item.ItemType.None

@export_custom(SRP_HINT.RESOURCE_PATH, "PackedScene") var item_3_path: String
@export var item_3_type := Item.ItemType.None

var _cached_checks: Array[Callable] = []

func meets_requirements(wis: Array[WorldItem]) -> bool:
	_ensure_cache()
	var conditions_met: Array[bool] = [false, false, false]
	for wi in wis:
		for idx in conditions_met.size():
			if _cached_checks[idx].call(wi) == true && conditions_met[idx] == false:
				conditions_met[idx] = true
				break # don't check the same item twice!
	for c in conditions_met:
		if c == false:
			return false
	return true

func _ensure_cache() -> void:
	if _cached_checks.size() > 0:
		return # already cached
	var checks: Array[Callable] = []
	if item_1_path.is_empty():
		checks.append(_type_check.bind(item_1_type))
	else:
		checks.append(_path_check.bind(ResourceUID.path_to_uid(item_1_path)))
	if item_2_path.is_empty():
		checks.append(_type_check.bind(item_2_type))
	else:
		checks.append(_path_check.bind(ResourceUID.path_to_uid(item_2_path)))
	if item_3_path.is_empty():
		checks.append(_type_check.bind(item_3_type))
	else:
		checks.append(_path_check.bind(ResourceUID.path_to_uid(item_3_path)))
	_cached_checks = checks

func _type_check(wi: WorldItem, t: Item.ItemType) -> bool:
	return wi.item.type == t

func _path_check(wi: WorldItem, uid: String) -> bool:
	return wi.item.resource_path == uid
