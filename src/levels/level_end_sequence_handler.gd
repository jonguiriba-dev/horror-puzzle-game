extends Object
class_name LevelEndSequenceHandler

var level:Level

func _init(_level:Level):
	level = _level
	
func _on_end_sequence_state_entered():
	UIManager.show_victory_overlay()
	UIManager.level_ui.overlay_clicked.connect(func():
		UIManager.hide_victory_overlay()
		
		give_player_rewards()
		
		var reward_abilities = get_reward_abilities()
		UIManager.show_reward_overlay(reward_abilities)
		UIManager.reward_card_selected.connect(func(reward_card):
			var ability_preset = reward_card.get_meta("data")
			var entity = reward_card.get_meta("target_entity")
			PlayerManager.add_entity_ability(entity,ability_preset)
			UIManager.hide_reward_overlay()
			
			var events = EventGenerator.generate_events()
			var event_options = UIManager.level_ui.show_event_options(events)
			set_meta("event_options",event_options)
		
			for event_option in event_options:
				event_option.pressed.connect(func():
					print("EVENT CLICKED ",event_option)
					set_meta("next_scene",event_option.get_meta("event").scene)
					level.state_chart.send_event("unload")
				, CONNECT_ONE_SHOT)
			SaveManager.save_data("level",{})
			SaveManager.save_game()

		, CONNECT_ONE_SHOT)
		
	, CONNECT_ONE_SHOT)	


	
func give_player_rewards():
	PlayerManager.add_gold(level.level_gold)
	
func get_reward_abilities():
	var abilities :Array[AbilityData]= []
	if !level.level_preset.rewards_config:
		return abilities
	while abilities.size() < level.level_preset.rewards_config.max_rewards:
		for ability_reward in level.level_preset.rewards_config.ability_reward_pool:
			if abilities.size() >= level.level_preset.rewards_config.max_rewards:
				break
			var rng = randf_range(0.1,1.0)
			if rng < ability_reward.chance:
				abilities.push_front(ability_reward.value)
	return abilities
	
