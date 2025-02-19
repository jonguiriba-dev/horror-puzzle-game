extends Control

var resolutions := [[1920,1080],[1280,720],[640,360]]
var current_resolution = resolutions[0]
@onready var resolution_button := $VBoxContainer/Row/Control2/Resolution
@onready var is_fullscreen_button := $VBoxContainer/Row2/FullscreenRow/Control/CheckBox

func _ready() -> void:
	resolution_button.pressed.connect(_on_resolution_button_pressed)
	is_fullscreen_button.pressed.connect(_on_fullscreen_toggled)

func _on_resolution_button_pressed():
	resolutions.push_front(resolutions.pop_back())
	
	resolution_button.get_node("Label").text = "%s x %s"%[resolutions[0][0],resolutions[0][1]]
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	print("resolution ", "%s x %s"%[resolutions[0][0],resolutions[0][1]])
	
	var resolution_vector := Vector2i(resolutions[0][0],resolutions[0][1])
	DisplayServer.window_set_size(resolution_vector)
	await get_tree().process_frame  
	#
	var size_override
	if resolutions[0] == [1920,1080]:
		size_override = Vector2i(640,360)
		UIManager.set_resolution_scale(Vector2(1,1))
	if resolutions[0] == [1280,720]:
		size_override = Vector2i(1280,720)
		UIManager.set_resolution_scale(Vector2(0.65,0.65))
	if resolutions[0] == [640,360]:
		size_override = Vector2i(1920,1080)
		UIManager.set_resolution_scale(Vector2(0.25,0.25))
		
	
	UIManager.view_port_container.size = DisplayServer.window_get_size()
	#UIManager.view_port.size_2d_override = size_override
	#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	
	if is_fullscreen_button.button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _on_fullscreen_toggled():
	if is_fullscreen_button.button_pressed:
		var resolution_vector = Vector2i(1920,1080)
		DisplayServer.window_set_size(resolution_vector)
		await get_tree().process_frame  
		UIManager.set_resolution_scale(Vector2(1,1))
		UIManager.view_port_container.size = DisplayServer.window_get_size()
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		resolutions = [[1920,1080],[1280,720],[640,360]]
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
