extends Object
class_name LevelTurnHandler

var level:Level
var turn_order:=[C.TEAM.ALLY,  C.TEAM.PLAYER]

var team_turn:C.TEAM
var ai_turn_queue = []
var current_ai_entity_in_action: Entity

signal turn_changed
signal turn_start(team: C.TEAM)
signal turn_end(team: C.TEAM)


func _init(_level:Level):
	level = _level

func _on_turn_end():
	Util.sysprint("Level","end_turn: from %s to %s"%[
		C.TEAM.keys()[turn_order[0]],
		C.TEAM.keys()[turn_order[1]],
	])
	
	UIManager.level_ui.clear_context()
	turn_changed.emit()
	#turn_end.emit(team_turn)
	turn_order.push_front(turn_order.pop_back())
	team_turn = turn_order[0]
	#turn_start.emit(team_turn)
	level.player_input_handler.waiting_on_ability = false
	
func _on_player_turn_state_entered():
	Util.sysprint("_start_player_turn","start")
	level.player_input_handler.input_enabled = true
	for player_entity in level.get_tree().get_nodes_in_group(C.GROUPS.PLAYER_ENTITIES):
		player_entity.turn_start.emit()
	
func _start_ally_turn():
	Util.sysprint("_start_ally_turn","start")
	
	if level.strategy_changed:
		var random_ally = level.get_tree().get_nodes_in_group(C.GROUPS_ALLIES).pick_random()
		DialogueManager.speak(random_ally.global_position,
		DialogueManager.get_scenario_text("to_strategy_%s"%[C.STRATEGIES.keys()[level.strategy].to_lower()])
		,1)
		await AnimationManager.squeeze(random_ally)

		level.strategy_changed = false
		
	ai_turn_queue = level.get_tree().get_nodes_in_group(C.GROUPS_ALLIES)
	if ai_turn_queue.size() > 0:
		var entity = ai_turn_queue.pop_front()
		entity.turn_start.emit()
		Util.sysprint("WorldManager._start_ally_turn","entity turn start: %s"%[entity.data.entity_name])
	else:
		level.state_chart.send_event("ai_turn_done")

		
func _start_enemy_turn():
	Util.sysprint("_start_enemy_turn","start")
	ai_turn_queue = level.get_tree().get_nodes_in_group(C.GROUPS_ENEMIES)
	if ai_turn_queue.size() > 0:
		var entity = ai_turn_queue.pop_front()
		entity.turn_start.emit()
		Util.sysprint("WorldManager._start_enemy_turn","entity turn start: %s"%[entity.data.entity_name])
	else:
		level.state_chart.send_event("ai_turn_done")
		
func _on_ai_turn_state_entered():
	Util.sysprint("_start_ai_turn","start")
	
	if level.strategy_changed:
		var random_ally = level.get_tree().get_nodes_in_group(C.GROUPS_ALLIES).pick_random()
		DialogueManager.speak(random_ally.global_position,
		DialogueManager.get_scenario_text("to_strategy_%s"%[C.STRATEGIES.keys()[level.strategy].to_lower()])
		,1)
		await AnimationManager.squeeze(random_ally)

		level.strategy_changed = false
		
	ai_turn_queue = level.get_tree().get_nodes_in_group(C.GROUPS_ALLIES)
	ai_turn_queue.append_array(level.get_tree().get_nodes_in_group(C.GROUPS_ENEMIES))
	
	ai_turn_queue.shuffle() #temp
	
	if ai_turn_queue.size() > 0:
		var entity = ai_turn_queue.pop_front()
		entity.turn_start.emit()
		Util.sysprint("WorldManager._start_ai_turn","entity turn start: %s"%[entity.data.entity_name])
	else:
		level.state_chart.send_event("ai_turn_done")

func _on_end_turn_pressed():
	Util.sysprint("Level:_on_end_turn_pressed","start")
	if team_turn == C.TEAM.PLAYER:
		UIManager.level_ui.end_turn.disabled = true
		for entity in level.get_tree().get_nodes_in_group(C.GROUPS.ENTITIES):
			entity.turn_end.emit()
			level.state_chart.send_event("ai_turn_done")
		level.state_chart.send_event("player_turn_done")
	
func _on_ai_unit_turn_end():
	Util.sysprint("Level:_on_ai_unit_turn_end","ai_turn_queue:%s"%[ai_turn_queue.size()])

	#filter for valid entities to take their turn
	ai_turn_queue = ai_turn_queue.filter(func(entity):
		return is_instance_valid(entity)
	)
	if is_instance_valid(level.turn_handler.current_ai_entity_in_action):
		level.turn_handler.current_ai_entity_in_action.clear_sprite_material()
	level.turn_handler.current_ai_entity_in_action = null
	if (
		ai_turn_queue.size() == 0 
		and (team_turn == C.TEAM.ENEMY or team_turn == C.TEAM.ALLY)
	):
		_on_all_ai_done()
	else:
		#keep looping to find a valid ai_entity that could take its turn
		while ai_turn_queue.size() > 0:
			var ai_entity = ai_turn_queue.pop_front()
			await Util.wait(0.1)
			if is_instance_valid(ai_entity):
				print("my turn: ", ai_entity.data.entity_name)
				current_ai_entity_in_action = ai_entity
				if Debug.highlight_entity_in_action:
					current_ai_entity_in_action.sprite.material = preload("res://src/shaders/outline/selected_highlight_material.tres")
				ai_entity.turn_start.emit()
				break
			

func _on_all_ai_done():
	Util.sysprint("Level turn system: ","all ai turn done")
	UIManager.level_ui.end_turn.disabled = false
	#		state_chart.send_event("ai_turn_done")
	level.state_chart.send_event("ai_turn_done")

func _on_turn_order_pressed():
	if team_turn == C.TEAM.PLAYER:
		if level.order_labels.size()>0:
			hide_turn_order()
		else:
			show_turn_order()
			

func show_turn_order():
	var i=1
	for enemy in level.get_tree().get_nodes_in_group(C.GROUPS_ENEMIES):
		var label = Label.new()
		enemy.add_child(label)
		label.position = Vector2(8,-32)
		label.text = str(i)
		label.set('theme_override_colors/font_color',Color('#cc2f44'))
		label.set('theme_override_colors/font_outline_color',Color('#121212'))
		label.set('theme_override_constants/outline_size',12)
		label.set('theme_override_font_sizes/font_size',10)
		i+=1
		level.order_labels.push_front(label)

	i=1
	for enemy in level.get_tree().get_nodes_in_group(C.GROUPS_ALLIES):
		var label = Label.new()
		enemy.add_child(label)
		label.position = Vector2(8,-32)
		label.text = str(i)
		label.set('theme_override_colors/font_color',Color('#2fb7cc'))
		label.set('theme_override_colors/font_outline_color',Color('#121212'))
		label.set('theme_override_constants/outline_size',12)
		label.set('theme_override_font_sizes/font_size',10)
		i+=1
		level.order_labels.push_front(label)
		
func hide_turn_order():
	for i in range(level.order_labels.size()):
		level.order_labels.pop_front().queue_free()
