@tool
extends EditorPlugin

func _enter_tree():
	add_autoload_singleton("GASConfig", "res://addons/gas/GASConfig.gd")
	add_autoload_singleton("GASInput", "res://addons/gas/GASInput.gd")
	add_autoload_singleton("GASText", "res://addons/gas/gas_text.gd")

func _exit_tree():
	remove_autoload_singleton("GASInput")
	remove_autoload_singleton("GASConfig")
	remove_autoload_singleton("GASText")
