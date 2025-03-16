extends Object
class_name LevelLoadHandler


var level
var spawn_config:LevelSpawnConfig
var environment_config:LevelEnvironmentConfig

func _init(level:Level):
	self.level = level
	spawn_config = level.level_preset.spawn_config
	environment_config = level.level_preset.environment_config
	
func _on_load_state_entered():
	if SaveManager.get_loaded("level","entities",[]).size() > 0:
		await load_units(SaveManager.get_loaded("level","entities",[]))
	else:
		if spawn_config:
			await spawn_units()
			
	level.turn_handler.team_turn = level.turn_handler.turn_order[0]
	level.turn_handler.turn_order = SaveManager.get_loaded(
		"level",
		"turn_order",
		level.turn_handler.turn_order
	) as Array[C.TEAM]
	level.turn_handler.team_turn = SaveManager.get_loaded("level","team_turn",level.turn_handler.team_turn)
	
func load_units(entities_load_data):
	for entity in entities_load_data:
		var loaded_entity = Entity.load_data(entity)
		loaded_entity.set_meta("recently_loaded",true)

		EntityManager.spawn_entity(
			loaded_entity.position,
			loaded_entity
		)
		loaded_entity.refresh_move_and_action_counters()

func spawn_units():
		
	var enemy_count := 0
	var neutral_count := 0
	var prop_count := 0
	
	var all_tiles = WorldManager.level.grid.get_all_tiles()
	all_tiles.shuffle()
	while(prop_count < environment_config.max_props):
		for props_spawn in environment_config.props_spawn_pool:
			var rng = randf_range(0.1,1.0)
			if props_spawn.spawn_rate > rng:
				EntityManager.spawn_entity(
					WorldManager.level.grid.map_to_local(all_tiles.pop_front()), 
					EntityManager.create_entity(props_spawn.entity_preset)
				)
				prop_count += 1
	
	var player_spawn_tiles = WorldManager.level.grid.get_team_position_tiles(Grid.TEAM_POSITION_LAYER_FILTERS.PLAYER)
	player_spawn_tiles.shuffle()
	for player_unit in PlayerManager.units:
		EntityManager.spawn_entity(
			WorldManager.level.grid.map_to_local(player_spawn_tiles.pop_front()),
			player_unit
		)
		player_unit.refresh_move_and_action_counters()
		
	var spawn_record = {}
	var enemy_spawn_tiles = WorldManager.level.grid.get_team_position_tiles(Grid.TEAM_POSITION_LAYER_FILTERS.ENEMY)
	enemy_spawn_tiles.shuffle()
	while(enemy_count < spawn_config.max_enemies):
		for enemy_spawn in spawn_config.enemy_spawn_pool:
			if enemy_count >= spawn_config.max_enemies:
				break
			var rng = randf_range(0.1,1.0)
			if enemy_spawn.spawn_rate > rng:
				EntityManager.spawn_entity(
					WorldManager.level.grid.map_to_local(enemy_spawn_tiles.pop_front()), 
					EntityManager.create_entity(enemy_spawn.entity_preset)
				)
				var current_spawn_count = spawn_record.get_or_add(enemy_spawn.entity_preset,0)
				if current_spawn_count < enemy_spawn.max_number:
					spawn_record[enemy_spawn.entity_preset] += 1
					enemy_count += 1
	
	var neutral_spawn_tiles = WorldManager.level.grid.get_team_position_tiles(Grid.TEAM_POSITION_LAYER_FILTERS.NEUTRAL)
	neutral_spawn_tiles.shuffle()
	while(neutral_count < spawn_config.max_neutrals):
		for neutral_spawn in spawn_config.neutral_spawn_pool:
			var rng = randf_range(0.1,1.0)
			if neutral_spawn.spawn_rate > rng:
				EntityManager.spawn_entity(
					WorldManager.level.grid.map_to_local(neutral_spawn_tiles.pop_front()), 
					EntityManager.create_entity(neutral_spawn.entity_preset)
				)
				neutral_count += 1
				

func _on_unload_state_entered():
	for e_option in get_meta("event_options"):
		e_option.queue_free()
	unload_units()
	await level.get_tree().process_frame
	SceneManager.change_scene(get_meta("next_scene"))

func unload_units():
	var entities = level.get_tree().get_nodes_in_group(C.GROUPS.ENTITIES)
	for entity in entities:
		if entity.data.team == C.TEAM.PLAYER or entity.data.team == C.TEAM.ALLY:
			entity.get_parent().remove_child(entity)
		else:
			entity.free()	
