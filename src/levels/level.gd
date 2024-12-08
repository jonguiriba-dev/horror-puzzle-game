extends Control
class_name World

@export var dialogues:Array[Dialogue]=[]
@export var orientation:=C.ORIENTATION.HORIZONTAL

func _ready() -> void:
	WorldManager.viewport_ready.connect(_on_viewport_ready)

func _on_viewport_ready():
	WorldManager.register_world(self)
