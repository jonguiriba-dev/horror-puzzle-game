extends Control
class_name RewardOverlay
@onready var hbox = $HBoxContainer
var hovered_card

signal selected_card(reward_card)

func populate_with_abilities(ability_props:Array[AbilityProp]):
	for child in hbox.get_children():
		child.queue_free()
	
	for ability_prop in ability_props:
		var reward_card = preload("res://src/ui/reward_card/RewardCard.tscn").instantiate()
		hbox.add_child(reward_card)
		reward_card.card_name.text = ability_prop.ability_name
		reward_card.description.text = ability_prop.description
		reward_card.mouse_entered.connect(_on_reward_card_mouse_entered.bind(reward_card))
		reward_card.mouse_exited.connect(_on_reward_card_mouse_exited)
		print("reward_card.set_meta>>> ",ability_prop)
		reward_card.set_meta("data",ability_prop)
		
func _on_reward_card_mouse_entered(reward_card):
	print("_on_reward_card_mouse_entered>>> ",reward_card.get_meta("data").ability_name)
	hovered_card = reward_card
func _on_reward_card_mouse_exited():
	print("_on_reward_card_mouse_exit>>>")
	hovered_card = null

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		if hovered_card:
			print("clicked ",hovered_card)
			selected_card.emit(hovered_card)
