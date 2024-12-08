extends Node2D
class_name Vfx

var particles : GPUParticles2D

func _ready() -> void:
	if has_node("GPUParticles2D"):
		particles = $GPUParticles2D
