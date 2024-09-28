extends Node2D
class_name Entity

@export var entity_name := ""
@export var sprite_texture:CompressedTexture2D= preload("res://assets/player.png")
@export var team :C.TEAM = C.TEAM.PLAYER

@onready var sprite := $Sprite
@onready var rescue_text := $Sprite/RescueText

func _ready() -> void:
	add_to_group(C.ENTITIES)
	sprite.texture = sprite_texture

func _on_area_2d_mouse_entered() -> void:
	add_to_group(C.HOVERED_ENTITIES)

func _on_area_2d_mouse_exited() -> void:
	remove_from_group(C.HOVERED_ENTITIES)

func show_detail(name:String):
	if(name == "rescue"):
		rescue_text.show()
	

func hide_all_details():
	rescue_text.hide()
	
