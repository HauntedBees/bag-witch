@tool
class_name CreditsItem extends VBoxContainer

const _COMMON_LICENSES: Dictionary[String, String] = {
	"CC-BY 3.0 license": "https://creativecommons.org/licenses/by/3.0/",
	"CC-BY 4.0 license": "https://creativecommons.org/licenses/by/4.0/",
	"MIT license": "https://opensource.org/license/MIT",
	"SIL Open Font License": "https://openfontlicense.org/open-font-license-official-text/",
	"CC0 1.0 Universal license": "https://creativecommons.org/publicdomain/zero/1.0/"
}

@export var quote_string: String:
	set(value):
		var r := RegEx.create_from_string(
			"- \\[([^\\]]*)\\]\\(([^)]*)\\) by \\[([^\\]]*)\\]\\(([^)]*)\\) is licensed under the \\[([^\\]]*)\\]\\(([^)]*)\\)."
		)
		var res := r.search(value)
		if res == null:
			return
		title = res.get_string(1)
		title_source = res.get_string(2)
		author = res.get_string(3)
		author_source = res.get_string(4)
		license = res.get_string(5)
		if !_COMMON_LICENSES.has(license):
			license_source = res.get_string(6)

@export var title: String:
	set(value):
		title = value
		if is_inside_tree():
			_set_title()

@export var title_source: String

@export var author: String:
	set(value):
		author = value
		if is_inside_tree():
			_set_author()

@export var author_source: String

@export var license: String:
	set(value):
		license = value
		if is_inside_tree():
			_set_license()

@export var license_source: String

@onready var _title: GASLabel = %Title
@onready var _author: GASLabel = %Author
@onready var _license: GASLabel = %License

func _ready() -> void:
	_set_title()
	_set_author()
	_set_license()

func _set_title() -> void:
	_title.text = "\"%s\"" % title

func _set_author() -> void:
	_author.text = author

func _set_license() -> void:
	_license.text = license


func _on_title_gui_input(event: InputEvent) -> void:
	if GASInput.is_click(event):
		OS.shell_open(title_source)

func _on_author_gui_input(event: InputEvent) -> void:
	if GASInput.is_click(event):
		OS.shell_open(author_source)

func _on_license_gui_input(event: InputEvent) -> void:
	if GASInput.is_click(event):
		if _COMMON_LICENSES.has(license):
			OS.shell_open(_COMMON_LICENSES[license])
		else:
			OS.shell_open(license_source)
