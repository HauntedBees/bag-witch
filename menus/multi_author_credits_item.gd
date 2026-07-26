@tool
class_name MultiAuthorCreditsItem extends CreditsItem

const _LABEL_SETTINGS := preload("uid://d3fgf6aofyfc4")
const _COLOR := Color("#34CEFF")

@export var authors: Array[String] = []
@export var author_sources: Array[String] = []

@onready var _container: HBoxContainer = %AuthorsContainer
@onready var _by: GASLabel = %By

func _set_author() -> void:
	for c in _container.get_children():
		if c != _by:
			c.queue_free()
	for i in authors.size():
		if i == (authors.size() - 1):
			_get_text(" and ")
		elif i > 0:
			_get_text(", ")
		var l := _get_text(authors[i])
		if !author_sources[i].is_empty():
			l.modulate = _COLOR
			if !Engine.is_editor_hint():
				l.gui_input.connect(_on_authors_gui_input.bind(author_sources[i]))

func _on_authors_gui_input(event: InputEvent, source: String) -> void:
	if GASInput.is_click(event):
		OS.shell_open(source)

func _get_text(t: String) -> GASLabel:
	var l := GASLabel.new()
	l.label_settings = _LABEL_SETTINGS
	l.text = t
	_container.add_child(l)
	return l
