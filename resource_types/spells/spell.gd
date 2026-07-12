class_name Spell extends ProjectileWeapon

@export var magic_level_requirement := 1

## If you have multiple spells of the same category available, only the highest level one
## you have access to will be available. Meaning if you have Icicle and Icicle II (both of
## the category "icicle", then if your magic level is 1, you'll only have Icicle (standard
## magic level rule), and if it's 2 or 3, you'll only have Icicle II (that's this rule).
@export var category := ""
