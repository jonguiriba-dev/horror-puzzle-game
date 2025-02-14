extends Control
class_name RewardOverlay
@onready var hbox = $HBoxContainer
var hovered_card

signal selected_card(reward_card)

func populate_with_abilities(ability_presets:Array[AbilityData]):
	for child in hbox.get_children():
		child.queue_free()
	
	for ability_preset in ability_presets:
		var reward_card = preload("res://src/ui/reward_card/RewardCard.tscn").instantiate()
		hbox.add_child(reward_card)
		reward_card.card_name.text = ability_preset.ability_name
		reward_card.description.text = ability_preset.description
		reward_card.mouse_entered.connect(_on_reward_card_mouse_entered.bind(reward_card))
		reward_card.mouse_exited.connect(_on_reward_card_mouse_exited)
		
		var rng = randi_range(1,3)
		var entity
		if rng == 1:
			entity = PlayerManager.get_units_by_name(EntityManager.PRESET_ELYANA.entity_name)[0]
			reward_card.bg.color = Color.YELLOW
		if rng == 2:
			entity = PlayerManager.get_units_by_name(EntityManager.PRESET_LAYLA.entity_name)[0]
			reward_card.bg.color = Color.MEDIUM_PURPLE
		if rng == 3:
			entity = PlayerManager.get_units_by_name(EntityManager.PRESET_TALYA.entity_name)[0]
			reward_card.bg.color = Color.LIGHT_SKY_BLUE
			
		reward_card.set_meta("data",ability_preset)
		reward_card.set_meta("target_entity",entity)
		
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
