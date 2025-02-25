extends Node

var scene_node #node to insert changeable scene nodes
var current_scene_path
const SCENES :={
	"MAP" : "res://src/screens/map/Map.tscn",
	"MAIN_MENU" : "res://src/screens/main_menu/MainMenu.tscn",
	"CAVE" : "res://src/levels/cave/Cave.tscn",
	"MENU_PAGE" : "res://src/ui/menu/menu.tscn",
}

var preload_list := {
	SCENES.MAP : preload(SCENES.MAP).instantiate(),
	#SCENES.CAVE : preload(SCENES.CAVE).instantiate(),
	SCENES.MENU_PAGE : preload(SCENES.MENU_PAGE).instantiate(),
}

var scene_list := {} #keeps track of scenes to swap
var main_menu

signal game_node_registered

func _ready() -> void:
	SaveManager.game_loaded.connect(_on_game_loaded)
	#game_node_registered.connect(func():
		#for i in preload_list:
			#scene_node.add_child(preload_list[i])
			#preload_list[i].queue_free()
	#)
		
func register_game_node(_scene_node:Control):
	Util.sysprint("SceneManager","scene_node registered")
	scene_node = _scene_node
	game_node_registered.emit()


func change_scene(scene_path:String,keep_prev_scene:=false)->void:
	keep_prev_scene = false
	Util.sysprint("SceneManager", "changing scene... %s"%[scene_path])
	
	
	var prev_scene:Node
	if(scene_node.get_child_count() > 0):
		prev_scene = scene_node.get_child(scene_node.get_child_count()-1)
		if keep_prev_scene:
			Util.sysprint("SceneManager","storing prev_scene: %s"%[prev_scene.name])
			scene_list[prev_scene.scene_file_path] = prev_scene
			scene_node.remove_child(prev_scene)
		else:
			Util.sysprint("SceneManager","freeing prev_scene: %s"%[prev_scene.name])
			scene_list[prev_scene.scene_file_path] = null
			prev_scene.queue_free()
	
	var new_scene
	if scene_list.get(scene_path):
		Util.sysprint("SceneManager","scene in cache...")
		#scene_list[SCENES.MAP].get_parnt().remove_child(scene_list[SCENES.MAP])
		#scene_list[SCENES.MAP].show()
		new_scene = scene_list[scene_path]
	else:
		Util.sysprint("SceneManager","instantiating scene...")
		new_scene =  load(scene_path).instantiate()
	

	new_scene.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	new_scene.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	scene_node.add_child(new_scene)
	current_scene_path = scene_path
	print("scene_path",scene_path)
	var save_exclude_list = [SCENES.MAIN_MENU]
	if !save_exclude_list.has(scene_path):
		SaveManager.save_data("scene_manager",to_save_data())
		SaveManager.save_game()

func load_scene(new_scene):

	new_scene.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	new_scene.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	scene_node.add_child(new_scene)
	current_scene_path = new_scene.file_path
	print("scene_path",current_scene_path)
	var save_exclude_list = [SCENES.MAIN_MENU]
	if !save_exclude_list.has(current_scene_path):
		SaveManager.save_data("scene_manager",to_save_data())
		SaveManager.save_game()	
	

func _on_game_loaded():
	var path = SaveManager.get_loaded("scene_manager","current_scene_path",current_scene_path)
	Util.sysprint("SceneManager","game loaded; screen - %s"%[path])
	if path:
		change_scene(path)

func to_save_data():
	return {
		#"scene_list":scene_list,
		"current_scene_path":current_scene_path,
	}
