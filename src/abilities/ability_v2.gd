extends Resource
class_name AbilityV2

enum STATE{
	INACTIVE,
	TARGET_SELECT
}

var host:Entity
signal stat_changed(key:String,value)

@export var state = STATE.INACTIVE
@export var has_ui = true
@export var data:AbilityData

var can_target_entities:bool:
	get:
		if data.tile_exclude_flag == Grid.TILE_EXCLUDE_FLAGS.EXCLUDE_ALL_PROPS:
			return false
		return true
	

signal target_select
signal stopped_targetting
signal applied(ability:AbilityV2)
signal used(ability:AbilityV2)

func setup(_host:Entity) -> void:
	self.host = _host
	if !target_select.is_connected(_on_target_select):
		target_select.connect(_on_target_select)
	if !stopped_targetting.is_connected(_on_stopped_targetting):
		stopped_targetting.connect(_on_stopped_targetting)
	if !used.is_connected(_on_used):
		used.connect(_on_used)
	if !host.turn_end.is_connected(_on_host_turn_end):
		host.turn_end.connect(_on_host_turn_end)
		
	if !host.registered.is_connected(_on_host_registered):
		host.registered.connect(_on_host_registered)

	for trigger in data.triggers:
		if trigger.source == AbilityTrigger.SOURCE_TYPES.HOST:
			if trigger.type == AbilityTrigger.TRIGGER_TYPES.SIGNAL:
				if host.has_signal(trigger.key):
					if trigger.target == AbilityTrigger.TARGET_TYPES.SELF:
						host.connect(trigger.key,func():
							use(host.map_position)	
						)
			elif trigger.type == AbilityTrigger.TRIGGER_TYPES.PROPERTY:
				host.stat_changed.connect(func(key,value):
					if key == trigger.key and value == trigger.value:
						if trigger.target == AbilityTrigger.TARGET_TYPES.SELF:
							use(host.map_position)	
				)
		if trigger.source == AbilityTrigger.SOURCE_TYPES.ABILITY:
			stat_changed.connect(func(key,value):
				if key == trigger.key and value == trigger.value:
					if trigger.target == AbilityTrigger.TARGET_TYPES.SELF:
						use(host.map_position)	
			)
	
	
	
	refresh_charges()
	
func use(target_map_position:Vector2i, options:Dictionary={}):
	print("Ability ",data.ability_name, " used on ", target_map_position)

	if !is_valid_target(target_map_position) and !options.get('absolute',false):
		stopped_targetting.emit()
		print("%s.%s[host.ability.use()]: no valid target found for pos %s"%[host.data.entity_name,data.ability_name,target_map_position])
		return
		
	await _play_animation(target_map_position)
	
	var direction = Util.get_direction(host.map_position,target_map_position)
	
	var origin = target_map_position
	
	if data.use_host_as_origin:
		origin = host.map_position + direction
	
	await apply_effect_to_tiles(target_map_position)
	
	used.emit(self)
	
	stopped_targetting.emit()
	
func highlight_target_tiles():
	WorldManager.level.grid.clear_all_highlights(Grid.HIGHLIGHT_LAYERS.ABILITY)
	
	var target_tiles
	
	target_tiles = get_target_tiles(host.map_position,data.ability_range)

	
	for pos in target_tiles:
		WorldManager.level.grid.set_highlight(
			pos,
			data.highlight_color,
			Grid.HIGHLIGHT_LAYERS.ABILITY
		)

func _get_tile_target(map_pos:Vector2i):
	var entities = WorldManager.level.get_tree().get_nodes_in_group(C.GROUPS_ENTITIES).filter(func(e):
		return e.map_position == map_pos
	)
	if entities.size() > 0:
		return entities[0]
	return null

func apply_effect_to_tiles(target_map_position:Vector2i):	
	var direction = Util.get_direction(host.map_position,target_map_position)
	
	var origin = target_map_position
	
	if data.use_host_as_origin:
		origin = host.map_position + direction
		
	var affected_tiles = TilePattern.get_callable(data.aoe_pattern).call(
		origin,
		data.ability_range,
		direction
	)
	
	var self_damage_effects = data.effects.filter(
		func(e): return e.effect_type == AbilityEffect.EFFECT_TYPES.SELF_DAMAGE
	)
	for self_damage_effect in self_damage_effects:
		host.hit.emit(self_damage_effect.value)
		
	
	for affected_tile in affected_tiles:
		var target_entity = _get_tile_target(affected_tile)
		
		if is_instance_valid(target_entity):
			apply_entity_effect(target_entity,data.effects)
		
		if data.effects.filter(
			func(e): return e.effect_type == AbilityEffect.EFFECT_TYPES.SUMMON
		).size() > 0:
			await apply_summon_effect(affected_tile,data.effects)
			
		
func apply_entity_effect(target:Entity, effects:Array[AbilityEffect]):
	for effect in effects:
		if effect.effect_type == AbilityEffect.EFFECT_TYPES.DAMAGE:
			target.hit.emit(effect.value)
		elif effect.effect_type == AbilityEffect.EFFECT_TYPES.KNOCKBACK:
			target.knockback.emit(effect.value, WorldManager.level.grid.local_to_map(host.position))
		elif effect.effect_type == AbilityEffect.EFFECT_TYPES.STATUS:
			var status = Status.new(effect.status_prop,effect.value)
			target.apply_status.emit(status)		
	applied.emit(self)

func apply_summon_effect(target_map_position:Vector2i, effects:Array[AbilityEffect]):
	for effect in effects:
		var summon_entity = EntityManager.create_entity(
			load(EntityManager.ENTITY_PRESETS[effect.entity_type])
		)
		EntityManager.spawn_entity(
			WorldManager.level.grid.map_to_local(target_map_position), 
			summon_entity
		)
		
func apply_move_effect(target_map_position:Vector2i):
	var path = WorldManager.level.grid.astar_grid.get_id_path(
		host.map_position, 
		target_map_position
	)
	if path.size() > 0:
		path.remove_at(0)
		path = path.filter(func(e):
			for ally in host.get_allies():
				if WorldManager.level.grid.local_to_map(ally.position) == e:
					return false
			return true
		)
	
	var tween = host.create_tween()
	for tile in path:
		tween.tween_property(
			host,
			"position",
			WorldManager.level.grid.map_to_local(tile),
			0.1
		)	
		tween.tween_interval(0.1)
	tween.play()
	SfxManager.play("step-2")
	await tween.finished
	host.data.move_counter -= 1

func _play_animation(target_map_position:Vector2i):
	AnimationManager.increment_animation_counter()
	if data.animation_script:
		await load(data.animation_script).play(host,target_map_position)
	else:	
		await Util.wait(0.3)

	AnimationManager.decrement_animation_counter()

func set_state(_state:STATE):
	if _state == state:
		return
	if state == STATE.TARGET_SELECT:
		target_select.emit()
	
	state = _state
	
#can potentially moved to strategy pattern if more diverse scenarios come
func get_target_tiles(
	map_pos:Vector2i=host.map_position,
	_range:int=data.ability_range,
)->Array[Vector2i]:
	var target_tiles = []
	if data.target_strategy == AbilityData.TARGET_STRATEGIES.DEFAULT:
		var possible_tiles = WorldManager.level.grid.get_possible_tiles(
			host.data.team,
			data.tile_exclude_flag
		)
		if data.tile_include_self:
			possible_tiles.push_front(map_pos)
			
		target_tiles = TilePattern.get_callable(data.range_pattern).call(map_pos,_range).filter(func(e):
			return possible_tiles.has(e)	
		)
	elif data.target_strategy == AbilityData.TARGET_STRATEGIES.NAVIGATION:
		target_tiles = WorldManager.level.grid.get_navigatable_tiles(
			host.map_position,
			data.ability_range,
			host.data.team,
			Grid.TILE_EXCLUDE_FLAGS.EXCLUDE_ALL_PROPS
		)

	
	return target_tiles

func get_valid_targets(map_pos:Vector2i=Vector2i.ZERO)->Array[Entity]:
	if map_pos == Vector2i.ZERO:
		map_pos = host.map_position
	
	var targets:Array[Entity]=[]
	var reachable_tiles = get_target_tiles(map_pos,data.ability_range)
	
	if can_target_entities:
		for entity in host.get_enemies():
			if reachable_tiles.has(entity.map_position) :
				if entity != host:
					targets.push_front(entity)
	return targets
	

func get_threat_tiles(
	source_map_pos:Vector2i=Vector2i.ZERO,
	target_map_pos:Vector2i=Vector2i.ZERO
)->Array:
	var direction = Util.get_direction(source_map_pos,target_map_pos)
	var threat_tiles = []
	
	#var prev_tile = source_map_pos
	
	var affected_tiles = TilePattern.get_callable(data.aoe_pattern).call(
		target_map_pos,
		data.ability_range,
		direction
	)
	
	if data.ability_name == "Timed Explosive":
		print("affected_tiles",affected_tiles)
	#for i in range(ability_range):
		#prev_tile += direction
		#threat_tiles.push_front(prev_tile)
	
	#for tile in affected_tiles:
		#prev_tile += direction
		#threat_tiles.push_front(prev_tile)
	return affected_tiles	

func is_valid_target(map_pos:Vector2i):
	var target_tiles = get_target_tiles(host.map_position,data.ability_range)
	if target_tiles.has(map_pos):
		return true
	return false

func is_usable():
	if data.max_charges == 0:
		return true
	elif data.charges > 0:
		return true
	return false

func refresh_charges():
	data.countdown = data.initial_countdown
	data.charges = data.max_charges
	
func _on_target_select() -> void:
	print("MOVE TARGET SELECT ",host.data.entity_name)
	if host.data.action_counter == 0:
		return 
	set_state(STATE.TARGET_SELECT)
	host.set_meta("targetting_ability",self)
	host.add_to_group(C.GROUPS_TARGETTING_ABILITY)
	WorldManager.level.grid.is_ability_select = true
	highlight_target_tiles()

func _on_stopped_targetting() -> void:
	host.set_meta("targetting_ability",null)
	host.remove_from_group(C.GROUPS_TARGETTING_ABILITY)
	WorldManager.level.grid.clear_all_highlights(Grid.HIGHLIGHT_LAYERS.ABILITY)
	state = STATE.INACTIVE
	WorldManager.level.grid.is_ability_select = false

func _on_used(ability:AbilityV2):
	if data.charges < 0:
		return
	data.charges -=1
	
func _on_host_turn_end():
	data.decrement_countdown()
	stat_changed.emit("countdown",data.countdown)
	
	if data.threat_strategy == AbilityData.THREAT_STRATEGIES.ALWAYS:
		host.set_threat(host.map_position,self)
	
func _on_host_registered():
	if data.threat_strategy == AbilityData.THREAT_STRATEGIES.ALWAYS:
		host.set_threat(host.map_position,self)
	
	
	
