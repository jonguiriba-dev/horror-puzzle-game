extends Node

var current_scene

func change_scene(name:String)->void:
	current_scene = load("res://src/screens/%s/%s.tscn"%[name,name]).instantiate()
	print(get_tree().root.get_child_count())
	if(get_tree().root.get_child_count()-1 > 0):
		var prev_scene = get_tree().root.get_child(get_tree().root.get_child_count()-1)
		prev_scene.queue_free()

	get_tree().root.add_child.call_deferred(current_scene)
