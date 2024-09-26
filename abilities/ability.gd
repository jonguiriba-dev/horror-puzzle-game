extends Node
class_name Ability

enum STATE{
	INACTIVE,
	TARGETTING
}
@onready var host:UnitEntity = get_parent()
var ability_name = "ability_name"
var texture = preload("res://assets/ui/ability_frame.png")
var ability_range = 0
var damage = 0
var state = STATE.INACTIVE
signal targetting
signal stopped_targetting

func target():
	print("targeting")
	targetting.emit(self)
	state = STATE.TARGETTING
	
func _unhandled_input(event: InputEvent) -> void:
	if(event.is_action_pressed("click") and state == STATE.TARGETTING):
		var target:UnitEntity = get_tree().get_first_node_in_group(C.HOVERED_ENTITIES)
		if target != null:
			if WorldManager.active_tilemap.is_within_range(host.map_position(),target.map_position(),ability_range):
				apply_effect(target)
		print("target ",target)
		state = STATE.INACTIVE
		stopped_targetting.emit(self)
func apply_effect(target):
	print("apply_effect ", ability_name, " target ",target)