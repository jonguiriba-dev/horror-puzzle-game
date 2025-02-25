extends Control
class_name EventOption

@onready var location_name := $LocationName
@onready var type_of_action := $TypeOfAction
@onready var rewards := $Rewards

signal pressed

func set_rewards_list(list:Array):
	for child in rewards.get_children():
		child.queue_free()
	
	for item in list:
		var icon = ColorRect.new()
		if item.type == EventGenerator.EVENT_REWARD_TYPES.GOLD:
			icon.modulate = Color.GOLD
		elif item.type == EventGenerator.EVENT_REWARD_TYPES.ABILITY:
			icon.modulate = Color.LIGHT_BLUE
		elif item.type == EventGenerator.EVENT_REWARD_TYPES.ITEM:
			icon.modulate = Color.LIGHT_SLATE_GRAY
		elif item.type == EventGenerator.EVENT_REWARD_TYPES.UNIT:
			icon.modulate = Color.CORAL
		elif item.type == EventGenerator.EVENT_REWARD_TYPES.VARIABLE:
			icon.modulate = Color.BLACK
		icon.custom_minimum_size = Vector2(30,30)
		rewards.add_child(icon)
			


func _on_texture_button_pressed() -> void:
	pressed.emit()
