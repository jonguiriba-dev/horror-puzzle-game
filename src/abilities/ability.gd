extends Resource
class_name Ability

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
signal applied(ability:Ability)
signal used(ability:Ability)
signal setup_finished(ability:Ability)

func use(target_map_position:Vector2i, options:Dictionary={}):
	print("Ability ",data.ability_name, " used on ", target_map_position)

	if !is_valid_target(target_map_position) and !options.get('absolute',false):
		stopped_targetting.emit()
		print("%s.%s[host.ability.use()]: no valid target found for pos %s"%[host.data.entity_name,data.ability_name,target_map_position])
		return
		
	await _play_animation(target_map_position)
	
	var direction = Util.get_direction(host.map_position,target_map_position)
	
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
		data.aoe_range,
		direction
	)	
	
	var self_damage_effects = data.effects.filter(
		func(e): return e.effect_type == AbilityEffect.EFFECT_TYPES.SELF_DAMAGE
	)
	for self_damage_effect in self_damage_effects:
		host.hit.emit(self_damage_effect.value,host)
		
	var move_effects = data.effects.filter(
		func(e): return e.effect_type == AbilityEffect.EFFECT_TYPES.MOVE
	)
	for move_effect in move_effects:
		await apply_move_effect(target_map_position,move_effect)
	
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
		var fail_rate = 1.0 - effect.success_rate
		var rand := randf_range(0.0,1.0)
		if rand < fail_rate:
			continue
			
		if effect.effect_type == AbilityEffect.EFFECT_TYPES.DAMAGE:
			if target == host and !effect.tags.has(AbilityEffect.TAGS.SELF_DAMAGE):
				pass
			else:
				target.hit.emit(effect.value,host)
		elif effect.effect_type == AbilityEffect.EFFECT_TYPES.KNOCKBACK:
			target.knockback.emit(effect.value, WorldManager.level.grid.local_to_map(host.position))
		elif effect.effect_type == AbilityEffect.EFFECT_TYPES.CANCEL_THREAT:
			target.unset_threat()
		elif effect.effect_type == AbilityEffect.EFFECT_TYPES.STATUS:
			var status = Status.new(
				load(Status.STATUS_DATA[effect.status_type]),
				effect.value
			)
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
		
func apply_move_effect(target_map_position:Vector2i, effect:AbilityEffect):
	var animation_speed = 0.1
	
	var exclude_flag = Grid.TILE_EXCLUDE_FLAGS.EXCLUDE_OBSTACLES_ALLIES
	if effect.tags.has(AbilityEffect.TAGS.PASS_THROUGH):
		exclude_flag = Grid.TILE_EXCLUDE_FLAGS.EXCLUDE_NONE
	
	var path = WorldManager.level.grid.get_nearest_path(
		host.data.team, 
		host.map_position,
		target_map_position, 
		exclude_flag
	)
	
	var tween = host.create_tween()
	if tween:
		for tile in path:
			tween.tween_property(
				host,
				"position",
				WorldManager.level.grid.map_to_local(tile),
				animation_speed
			)	
			#tween.tween_interval(0.05)
		tween.play()
		SfxManager.play("step-2")
	await tween.finished
	host.data.move_counter -= 1


func _play_animation(target_map_position:Vector2i):
	AnimationManager.increment_animation_counter()
	if data.animation_script:
		await load(data.animation_script).play(host,target_map_position)
	else:	
		await Util.wait(0.05)

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
	
	if data.use_host_as_origin:
		target_map_pos = host.map_position
	
	var affected_tiles = TilePattern.get_callable(data.aoe_pattern).call(
		target_map_pos ,
		data.aoe_range,
		direction
	)

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
	WorldManager.set_meta("player_targetting_ability",self)
	highlight_target_tiles()

func _on_stopped_targetting() -> void:
	host.set_meta("targetting_ability",null)
	WorldManager.set_meta("player_targetting_ability",null)
	WorldManager.level.grid.clear_all_highlights(Grid.HIGHLIGHT_LAYERS.ABILITY)
	state = STATE.INACTIVE

func _on_used(ability:Ability):
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
		if trigger.source == AbilityTrigger.SOURCE_TYPES.ALLY:
			if trigger.type == AbilityTrigger.TRIGGER_TYPES.SIGNAL:
				if host.has_signal(trigger.key):
					if trigger.target == AbilityTrigger.TARGET_TYPES.ENEMY:
						for enemy in WorldManager.get_tree().get_nodes_in_group(C.GROUPS.ENEMIES):
							#trigger only when the hit source is from an ally and not the host 
							if trigger.key == "hit":
								enemy.connect(trigger.key,func(value,source):
									if source != host:
										use(enemy.map_position)	
								)
							else:
								enemy.connect(trigger.key,func(a=null,b=null,c=null):
									use(enemy.map_position)	
								)
	
	
	refresh_charges()
	
	
