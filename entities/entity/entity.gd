extends Node2D
class_name Entity

@onready var sprite := $Sprite2D
@export var sprite_texture:CompressedTexture2D= preload("res://assets/player.png")

func _ready() -> void:
	print("sprite",sprite)
	sprite.texture = sprite_texture


func _on_area_2d_mouse_entered() -> void:
	add_to_group(C.HOVERED_ENTITIES)


func _on_area_2d_mouse_exited() -> void:
	remove_from_group(C.HOVERED_ENTITIES)
