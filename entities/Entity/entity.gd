extends Node2D
class_name Entity

@onready var sprite := $Sprite2D
@export var sprite_texture:CompressedTexture2D= preload("res://assets/player.png")

func _ready() -> void:
	print("sprite",sprite)
	sprite.texture = sprite_texture
