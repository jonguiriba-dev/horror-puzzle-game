extends Node2D
class_name Entity

enum STATE{
	INACTIVE,
	SELECTED,
	MOVE_SELECTION,
	MOVED,
	TARGETTING,
	DONE
}

@export var entity_name := ""
@export var sprite_texture:CompressedTexture2D= preload("res://assets/player.png")
@export var team :C.TEAM = C.TEAM.PLAYER

@onready var sprite := $Sprite
@onready var rescue_text := $Sprite/RescueText

var move_speed = 55
var move_range = 3
var can_move := false
var state := STATE.INACTIVE
var health = 1
var target_position=null
var path=null

signal hit(damage:int)
signal death
signal move_end

func _ready() -> void:
	add_to_group(C.ENTITIES)
	sprite.texture = sprite_texture
	hit.connect(_on_hit)
	death.connect(_on_death)
	
func _on_area_2d_mouse_entered() -> void:
	add_to_group(C.HOVERED_ENTITIES)

func _on_area_2d_mouse_exited() -> void:
	remove_from_group(C.HOVERED_ENTITIES)

func show_detail(name:String):
	if(name == "rescue"):
		rescue_text.show()
	
func _on_hit(damage:int) -> void:
	health -= damage
	print("took damage", damage, " health ", health )
	if health <= 0:
		health = 0
		death.emit()
		print("death.emit")

func _on_death() -> void:
	print("death ",self)
	queue_free()


func hide_all_details():
	rescue_text.hide()
	
