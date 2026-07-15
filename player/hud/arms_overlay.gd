class_name ArmsOverlay extends TextureRect

@onready var arms: ArmsOverlayInner = %ArmsOverlayInner
@onready var _suckage: ColorRect = %Suckage

func _on_arms_overlay_inner_set_suck(on: bool) -> void:
	_suckage.visible = on
