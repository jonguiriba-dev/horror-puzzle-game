extends Node

var scene_node #node to insert changeable scene nodes
var current_scene

const SCENE_MAP = "res://src/screens/map/Map.tscn"
var scene_list := {}

func register_game_node(_scene_node:Control):
	scene_node = _scene_node

func change_scene(scene_path:String,keep_prev_scene:=false)->void:
	Util.sysprint("changing scene ", scene_path)
	var new_scene
	if scene_list.get(scene_path):
		new_scene = scene_list.get(scene_path)
	else:
		new_scene =  load(scene_path).instantiate()
	
	if(scene_node.get_child_count() > 0):
		var prev_scene :Node= scene_node.get_child(scene_node.get_child_count()-1)
		if keep_prev_scene:
			Util.sysprint("SceneManager","storing prev_scene: %s"%[prev_scene.name])
			scene_list[prev_scene.scene_file_path] = prev_scene
			scene_node.remove_child(prev_scene)
		else:
			Util.sysprint("SceneManager","freeing prev_scene: %s"%[prev_scene.name])
			scene_list[prev_scene.scene_file_path] = null
			prev_scene.queue_free()

	new_scene.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	new_scene.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	scene_node.add_child(new_scene)
