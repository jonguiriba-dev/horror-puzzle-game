extends Node2D
class_name World

@export var dialogues:Array[Dialogue]=[]
func _ready() -> void:
	WorldManager.viewport_ready.connect(_on_viewport_ready)

func _on_viewport_ready():
	WorldManager.register_world(self)

func _unhandled_input(event: InputEvent) -> void:
	print("TEST ")
