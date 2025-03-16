extends Node2D
class_name Entity

const ENTITY_TSCN := preload("res://src/entities/entity/Entity.tscn") 

@onready var sprite :AnimatedSprite2D= $EntitySprite
@onready var shadow :Sprite2D= $Shadow
@onready var rescue_text := $EntitySprite/RescueText
@onready var healthbar := $Healthbar
@onready var numeric_health := $Healthbar/FractionRange
@onready var status_bar := $StatusBar
@onready var context_menu_point := $ContextMenuPoint
@export var preset:EntityData
@export var data:EntityData

var animation_counter := 0
var map_position:Vector2i:
	get:
		if WorldManager.level:
			return WorldManager.level.grid.local_to_map(position)
		return Vector2i.ZERO

var flip_h:=false
var threat = null
var status_effects:Array[Status] = []
var is_turn_done:= false
var is_alive:= true

signal hit(damage:int,source)
signal stat_changed(key:String, value)
signal knockback(distance:int,source_pos:Vector2)
signal knockback_animation_finished(distance:int,source_map_pos:Vector2i,prev_map_position:Vector2i)
signal apply_status(status:Status)
signal death
signal move_end
signal turn_end
signal turn_start
signal selected
signal threat_updated
signal registered
signal stun

func _ready() -> void:
	if preset:
		preset.apply_node_data(self)

	add_to_group(C.GROUPS_ENTITIES)
	death.connect(_on_death)
	hit.connect(_on_hit)
	knockback.connect(_on_knockback)
	knockback_animation_finished.connect(_on_knockback_animation_finished)
	turn_end.connect(_on_turn_end)
	turn_start.connect(_on_turn_start)
	selected.connect(_on_selected)
	apply_status.connect(_on_apply_status)
	stun.connect(_on_stun)
	
	if data.team == C.TEAM.ENEMY:
		add_to_group(C.GROUPS_ENEMIES)
	elif data.team == C.TEAM.PROP:
		add_to_group(C.GROUPS.PROPS)
	else:
		add_to_group(C.GROUPS_TARGETS)
		if data.team == C.TEAM.PLAYER:
			add_to_group(C.GROUPS.PLAYER_ENTITIES)
		elif data.team == C.TEAM.ALLY:
			add_to_group(C.GROUPS_ALLIES)
	if sprite:
		sprite.play("idle")
	
	for ability in get_abilities():
		if ability.data.ability_name == "move":
			continue
		ability.setup(self)
		ability.used.connect(_on_ability_used)
	
	scale = Vector2(0.75,0.75)
	
func set_max_health(_max_health:int):
	data.max_health = _max_health
	data.health = _max_health
	#healthbar.max_value = max_health
	#healthbar.value = health
	

func show_detail(detail_name:String):
	if(detail_name == "rescue"):
		rescue_text.show()
	
func check_overlap(map_pos:Vector2i):
	for entity in get_tree().get_nodes_in_group(C.GROUPS_CIVILIANS):
		var civilian_tile_pos = WorldManager.level.grid.local_to_map(entity.position)
		if civilian_tile_pos == map_pos:
			entity.rescued.emit()


#func get_abilities()->Array[Ability]:
	#var abilities:Array[Ability]= []
	#for child in get_children():
		#if child is Ability:
			#var ability = child as Ability
			#abilities.append(ability)
		#
	#return abilities
	
func get_abilities()->Array[Ability]:
	return data.abilities
	
func get_ability(ability_name:String)->Ability:
	for ability in get_abilities():
		if ability.data.ability_name.to_lower() == ability_name.to_lower():
			return ability
	return null
func hide_all_details():
	rescue_text.hide()
	

func get_enemies()->Array[Entity]:
	var enemies:Array[Entity] = []
	for entity in get_tree().get_nodes_in_group(C.GROUPS_ENTITIES):
		if entity.data.team != data.team:
			if C.ALLIED_TEAMS[C.TEAM.keys()[data.team]].has(entity.data.team):
				continue
			if entity.data.team == C.TEAM.PROP:
				continue
			enemies.push_front(entity as Entity)
				

	return enemies 
	
func get_allies()->Array[Entity]:
	var allies:Array[Entity] = []
	for entity in get_tree().get_nodes_in_group(C.GROUPS_ENTITIES):
		if entity.data.team == data.team:
			allies.push_front(entity as Entity)
		elif C.ALLIED_TEAMS[C.TEAM.keys()[data.team]].has(entity.data.team):
			allies.push_front(entity as Entity)
	return allies 
	
func undo_move(initial_position:Vector2):
	WorldManager.level.grid.set_map_cursor(initial_position)
	position = initial_position
	data.move_counter = 1
	
func clear_sprite_material():
	sprite.material = null
	
func set_orientation(vertical:bool):
	sprite.flip_h = vertical
	
func clear_threat():
	threat = null
	threat_updated.emit()

func add_ability(ability_data:AbilityData):
	Util.sysprint("%s.Entity.add_ability"%[data.entity_name],"%s"%[ability_data.ability_name])
	var ability = Ability.new()
	ability.data = ability_data
	ability.setup(self)
	data.abilities.push_front(ability) 

func remove_ability(ability_name:String):
	Util.sysprint("%s.Entity.remove_ability"%[data.entity_name],"%s"%[ability_name])
	var index := data.abilities.find(func(e):
		return e.ability_name == ability_name
	) 
	if index != -1:
		data.abilities.erase(index)


func _on_turn_start():
	Util.sysprint("%s.Entity._on_turn_start"%[data.entity_name],"counter refresh done")
	refresh_move_and_action_counters()
	is_turn_done = false
	
func refresh_move_and_action_counters():
	var recently_loaded = get_meta("recently_loaded",false)
	if recently_loaded:
		set_meta("recently_loaded",false)
		return
	data.move_counter = data.max_move_counter
	data.action_counter = data.max_action_counter
	
func _on_turn_end():
	Util.sysprint("%s.Entity._on_turn_end"%[data.entity_name],"saving level_entities")
	is_turn_done = true

func _on_mouse_entered() -> void:
	add_to_group(C.HOVERED_ENTITIES)
	
func _on_mouse_exited() -> void:
	remove_from_group(C.HOVERED_ENTITIES)

	
func _on_knockback(distance:int, source_map_pos:Vector2i):
	if data.health == 0:
		return
	
	var prev_position = map_position
	var direction = Util.get_direction(source_map_pos,map_position)
	#change direction to away from the source 
	var target_pos = map_position + direction * distance 
	if !WorldManager.level.grid.is_within_bounds(target_pos):
		return
	if !WorldManager.level.grid.get_possible_tiles(data.team).has(target_pos):
		return
	
	increment_animation_counter()
	var tween = create_tween()
	tween.tween_property(self, "position", WorldManager.level.grid.map_to_local(target_pos), 0.3)
	await tween.finished.connect(func():
		knockback_animation_finished.emit(distance,source_map_pos,prev_position)
		decrement_animation_counter()
	)

func increment_animation_counter():
	animation_counter+=1
	AnimationManager.increment_animation_counter() 
	
func decrement_animation_counter():
	animation_counter-=1
	AnimationManager.decrement_animation_counter() 
	
func _on_area_2d_mouse_entered() -> void:
	add_to_group(C.GROUPS_HOVERED_ENTITIES)

func _on_area_2d_mouse_exited() -> void:
	remove_from_group(C.GROUPS_HOVERED_ENTITIES)

func _on_stun():
	unset_threat()
	refresh_move_and_action_counters()

func _on_hit(damage:int, source) -> void:
	data.health -= calculate_hit_damage(damage)
	healthbar.value = data.health
	
	
	if data.health <= 0:
		data.health = 0
		death.emit()
	else:
		VfxManager.flash(sprite,Color.DARK_RED,0.15)
		VfxManager.spawn("hit-spark-1",self,{"offset":Vector2(randi_range(-12,12),randi_range(-12,4))})
	
	stat_changed.emit("health",data.health)
	
	numeric_health.set_current(data.health)
	
	Util.sysprint("Entity %s"%[data.entity_name],"health after calculation: %s"%[data.health])

func _get_stat(key:String)->int:
	var data_stat = data.get(key)
	var ability_stat = 0
	for ability in data.abilities:
		for effect in ability.data.effects:
			if effect.effect_type == AbilityEffect.EFFECT_TYPES.STAT_CHANGE:
				if effect.stat_key == key:
					ability_stat += effect.value
	return data_stat + ability_stat
	
func _on_death() -> void:
	for group in get_groups():
		remove_from_group(group)
		
	if data.team == C.TEAM.ENEMY:
		await WorldManager.level.check_player_victory()

	#if animation_counter != 0:
		#WorldManager.level.increment_animation_counter(animation_counter * -1)
	
	clear_threat()
	is_alive = false
	hit.disconnect(_on_hit)
	knockback.disconnect(_on_knockback)
	#queue_free()
		
func _on_selected():
	if data.team == C.TEAM.PLAYER:
		WorldManager.level.player_input_handler.selected_entity = self
		#UIManager.level_ui.set_context(self)
		WorldManager.level.player_input_handler.waiting_on_ability = false
		sprite.material = preload("res://src/shaders/outline/selected_highlight_material.tres")
	else:
		clear_sprite_material()
		UIManager.level_ui.clear_context()

		
func _on_ability_used(ability:Ability):
	if ability.data.ability_name.to_lower() != "move":
		WorldManager.level.clear_entity_moved_history()
	data.action_counter -= ability.data.action_cost
	if ability.data.is_action:
		data.move_counter = 0

	if data.action_counter > 0 && data.team == C.TEAM.PLAYER:
		UIManager.level_ui.set_context(self)

func _on_apply_status(status:Status):
	Util.sysprint("%s.Entity._on_apply_status"%[data.entity_name],"applying status: %s"%[status.status_data.status_name])
	status_effects.push_front(status)
	status.register_entity(self)
	status.status_finished.connect(func (e):
		status_effects.erase(e)
	,CONNECT_ONE_SHOT)

func _on_knockback_animation_finished(distance:int, source_map_pos:Vector2i, prev_position:Vector2i):
	if threat:
		var direction = Util.get_direction(source_map_pos,map_position)
		threat.tile += direction * distance 
		threat_updated.emit()

func to_save_data():
	return {
		"preset": preset.duplicate(true),
		"data" : data.to_save_data(),
		"position": position,
		"threat":threat,
		"status_effects":status_effects.duplicate(true),
		"is_turn_done": is_turn_done
	}
	
static func load_data(entity_load_data)->Entity:
	Util.sysprint("Entity","loading data.. %s"%[entity_load_data.data.entity_name])
	var entity = ENTITY_TSCN.instantiate()
	entity_load_data.preset.apply_as_preset(entity)
	for key in entity_load_data:
		entity.set(key,entity_load_data[key])
		if key == "data":
			var entity_data:EntityData= entity_load_data[key]
			entity_data.load_data(entity)
			
	return entity
	
func set_threat(target_map_position:Vector2i,ability:Ability):
	threat = {"tile":target_map_position, "ability":ability}
	Util.sysprint("Entity.%s.set_threat"%[data.entity_name],"ability:%s tile:%s"%[threat.ability.data.ability_name,str(threat.tile)])
	threat_updated.emit()

func unset_threat():
	threat = null
	Util.sysprint("Entity.%s.unset_threat"%[data.entity_name],"ok")
	threat_updated.emit()

func is_prop():
	return data.tags.has(EntityData.EntityTags.PROP)

func calculate_hit_damage(damage:int)->int:
	return damage - _get_stat("armor")
	
