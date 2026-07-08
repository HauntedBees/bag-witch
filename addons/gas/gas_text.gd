extends Node

signal font_scale_changed()

var override_font_scale := 1.0:
	set(value):
		override_font_scale = value
		font_scale_changed.emit()

var _label_settings_cache: Dictionary[LabelSettings, LabelSettingsInfo] = {}

## The following code:
## [code]
## func _ready() -> void:
##     GASText.font_scale_changed.connect(_on_font_scale_changed)
##     _on_font_scale_changed()
## func _on_font_scale_changed() -> void:
##     _save_info.size_flags_stretch_ratio = 1.25 if GASText.override_font_scale > 1.5 else 1.0
## [/code]
## can be rewritten to:
## [code]
## func _ready() -> void:
##    GASText.bind_control_change(_save_info, &"size_flags_stretch_ratio", func(size: float) -> float:
##        return 1.25 if size > 1.5 else 1.0
##    )
## [/code]
## If you're only changing one or properties in a given node based on font size changes,
## this is a bit less verbose than doin things manually.
func bind_control_change(control: Control, property: StringName, calc: Callable) -> void:
	var method := func() -> void:
		control.set(property, calc.call(override_font_scale))
	font_scale_changed.connect(method)
	method.call()
	control.tree_exiting.connect(func() -> void:
		font_scale_changed.disconnect(method)
	, CONNECT_ONE_SHOT)

func register_label_settings(l: LabelSettings) -> void:
	if !_label_settings_cache.has(l):
		_label_settings_cache[l] = LabelSettingsInfo.new(l)

func get_adjusted_label_settings(l: LabelSettings) -> LabelSettings:
	if override_font_scale == 1.0:
		return l
	register_label_settings(l)
	return _label_settings_cache[l].get_size(override_font_scale)

func get_adjusted_theme_override_font_size(orig_size: int) -> int:
	if override_font_scale == 1.0:
		return orig_size
	return roundi(orig_size * override_font_scale)

class LabelSettingsInfo:
	var adjusted_scales: Dictionary[float, LabelSettings] = {}
	var _base_label_settings: LabelSettings

	func _init(l: LabelSettings) -> void:
		_base_label_settings = l

	func get_size(scale: float) -> LabelSettings:
		if !adjusted_scales.has(scale):
			var split: LabelSettings = _base_label_settings.duplicate()
			split.font_size = roundi(_base_label_settings.font_size * scale)
			adjusted_scales[scale] = split
		return adjusted_scales[scale]
