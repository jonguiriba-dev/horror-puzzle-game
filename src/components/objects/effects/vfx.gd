extends Node2D
class_name Vfx

var particles : GPUParticles2D
var animated_sprite : AnimatedSprite2D
@export var is_directional:=false

func _ready() -> void:
	if has_node("GPUParticles2D"):
		particles = $GPUParticles2D

	if has_node("AnimatedSprite2D"):
		animated_sprite = $AnimatedSprite2D
