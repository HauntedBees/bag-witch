class_name Potion extends Item

## If this were a full-fledged big project not being rushed to get done in a few
## days, abilities would be their own scripts hooking into things and whatnot, but
## there are probably only going to be a dozen of these tops and they're all going
## to be different enough that I wouldn't be able to reuse things or anything so
## fuck it, enums will do for now.
enum Ability {
	## For classes that inherit from Potion and do their own thing.
	Custom,
	## Gunpowder Tonic
	SuperGunshot,
	## Disaster Potion
	HurtSelf,
	## Blood Brew
	SuperPower,
	## Lava Infusion
	LavaInfusion
}

@export var ability := Ability.Custom

@export var metadata := 0

## In seconds.
@export var duration := 0.0

func _inner_use(player: BogWitch) -> void:
	if ability == Ability.HurtSelf:
		player.take_damage(20, Vector3(0.0, 3.0, 0.0), 2.0, 2.0)
		return
	Player.data.drink_potion(self)
	if ability == Ability.SuperPower:
		var amount := 50 if metadata == 1 else 10
		Player.data.max_health = maxi(Player.data.max_health - amount, 1)
		Player.data.stat_changed.emit()
		Player.data.current_health = mini(Player.data.current_health, Player.data.max_health)
