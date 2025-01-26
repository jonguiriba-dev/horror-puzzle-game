extends Node

var scene_node
var current_scene

const SCENE_MAP = "res://src/screens/map/Map.tscn"

func register_game_node(_scene_node:Control):
	scene_node = _scene_node

func change_scene(scene_path:String)->void:
	var new_scene =  load(scene_path).instantiate()
	current_scene = new_scene
	if(scene_node.get_child_count() > 0):
		var prev_scene = scene_node.get_child(scene_node.get_child_count()-1)
		Util.sysprint("SceneManager","freeing prev_scene: %s"%[prev_scene.name])
		print(prev_scene)
		prev_scene.queue_free()

	new_scene.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	new_scene.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	scene_node.add_child(new_scene)
