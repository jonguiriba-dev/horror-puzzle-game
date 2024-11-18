extends Control
class_name Game

@export_file() var game_scene
@onready var root = $SubViewportContainer/SubViewport/Root

func _ready():
	if game_scene:
		var node = load(game_scene).instantiate()
		node.size_flags_vertical = SIZE_SHRINK_CENTER
		node.size_flags_horizontal = SIZE_SHRINK_CENTER
		root.add_child(node)
