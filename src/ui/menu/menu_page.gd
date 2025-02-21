extends Control

@onready var resolution_button := $VBoxContainer/Row/Control2/Resolution
@onready var is_fullscreen_button := $VBoxContainer/Row2/FullscreenRow/Control/CheckBox

func _ready() -> void:
	resolution_button.pressed.connect(_on_resolution_button_pressed)
	is_fullscreen_button.pressed.connect(_on_fullscreen_toggled)

func _on_resolution_button_pressed():
	if is_fullscreen_button.button_pressed:
		return
	SettingsManager.cycle_resolution()
	resolution_button.get_node("Label").text = "%s x %s"%[
		SettingsManager.current_resolution.x,
		SettingsManager.current_resolution.y
	]
	
func _on_fullscreen_toggled():
	SettingsManager.toggle_fullscreen(is_fullscreen_button.button_pressed)
	resolution_button.get_node("Label").text = "%s x %s"%[
		SettingsManager.current_resolution.x,
		SettingsManager.current_resolution.y
	]
