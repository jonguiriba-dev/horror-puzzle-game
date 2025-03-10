extends Node

const GAME_RESOLUTION = Vector2(640,360)
const RESOLUTIONS := [Vector2(1920,1080),Vector2(1280,720),Vector2(640,360)]
var base_resolution := Vector2(1920,1080)
var current_resolution := Vector2(1920,1080)
var resolution_scale := Vector2(1,1)
var is_fullscreen := false
#we'll have base_resolution scaled down to standard sizes
#then window display size adjustment for everything

func _ready() -> void:
	load_data()
	SceneManager.game_node_registered.connect(func():
		set_resolution(current_resolution,is_fullscreen)
	)
func cycle_resolution():
	var i = RESOLUTIONS.find(current_resolution)
	if i >= RESOLUTIONS.size()-1:
		current_resolution = RESOLUTIONS[0]
	else:
		current_resolution = RESOLUTIONS[i+1]
	set_resolution(current_resolution,is_fullscreen)

func toggle_fullscreen(_is_fullscreen:bool):
	is_fullscreen = _is_fullscreen

	if !is_fullscreen:
		if current_resolution.x < 1920:
			current_resolution = Vector2(1280,720)
		else:
			current_resolution = Vector2(1920,1080)
	else:
		current_resolution = DisplayServer.window_get_size()
	
	set_resolution(current_resolution,is_fullscreen)
		
func set_resolution(resolution:Vector2, _is_fullscreen:=false):
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(current_resolution)
	get_tree().root.content_scale_size = current_resolution
	
	resolution_scale = current_resolution / base_resolution
	UIManager.set_resolution(current_resolution, resolution_scale)
	save_data()
	
	if _is_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func get_ui_game_resolution_multiplier()->Vector2:
	return current_resolution / GAME_RESOLUTION
	
func load_data():
	current_resolution = SaveManager.get_config("settings_manager","current_resolution",Vector2(1920,1080))
	is_fullscreen = SaveManager.get_config("settings_manager","is_fullscreen",false)
	
func save_data():
	SaveManager.set_config("settings_manager","current_resolution",current_resolution)
	SaveManager.set_config("settings_manager","is_fullscreen",is_fullscreen)
