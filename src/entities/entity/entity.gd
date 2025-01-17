extends Node2D
class_name Entity
# use shader https://godotshaders.com/shader/highlight-canvasitem/ for highlighting icons
@onready var sprite :AnimatedSprite2D= $EntitySprite
@onready var shadow :Sprite2D= $Shadow
@onready var rescue_text := $EntitySprite/RescueText
@onready var healthbar := $Healthbar
@onready var status_bar := $StatusBar

@export var preset:EntityPreset

var move_speed = 55
var portrait_image
var entity_name := ""
var max_health := 1
var health := 1
var team :C.TEAM = C.TEAM.PLAYER
var move_range := 3
var can_move := false
var move_counter := 1
var action_counter := 1
var max_move_counter := 1
var max_action_counter := 1
var animation_counter := 0
var map_position:Vector2i:
	get:
		return WorldManager.level.grid.local_to_map(position)
var flip_h:=false
var threat = null
var status_effects:Array[Status] = []

signal hit(damage:int)
signal knockback(distance:int,source_pos:Vector2)
signal knockback_animation_finished(distance:int,source_map_pos:Vector2i,prev_map_position:Vector2i)
signal apply_status(status:Status)
signal death
signal move_end
signal turn_end
signal turn_start
signal selected
signal threat_updated

func _ready() -> void:
	load_preset(preset)
	add_to_group(C.GROUPS_ENTITIES)
	death.connect(_on_death)
	hit.connect(_on_hit)
	knockback.connect(_on_knockback)
	knockback_animation_finished.connect(_on_knockback_animation_finished)
	turn_end.connect(_on_turn_end)
	turn_start.connect(_on_turn_start)
	selected.connect(_on_selected)
	apply_status.connect(_on_apply_status)

	if team == C.TEAM.ENEMY:
		add_to_group(C.GROUPS_ENEMIES)
	else:
		add_to_group(C.GROUPS_TARGETS)
		if team == C.TEAM.PLAYER:
			add_to_group(C.GROUPS_PLAYER_ENTITIES)
		elif team == C.TEAM.ALLY:
			add_to_group(C.GROUPS_ALLIES)
	
	if sprite:
		sprite.play("idle")
	
	for ability in get_abilities():
		if ability.ability_name == "move":
			continue
		ability.used.connect(_on_ability_used)
	
	#WorldManager.level.register_entity(self)
	
	
func load_preset(_preset:EntityPreset):
	Util.sysprint("Entity:loading_preset", "loading_preset")
	if !_preset:
		return
	entity_name = _preset.entity_name
	Util.sysprint("Entity:loading_preset", "name: "+entity_name)
	set_max_health(_preset.max_health)
	team = _preset.team
	move_range = _preset.move_range
	
	for ability in _preset.get_abilities():
		add_child(ability)
	
	add_child(_preset.get_state_machine())
	
	if preset.sprite_frames:
		sprite.sprite_frames = preset.sprite_frames
	
	if preset.portrait_image:
		portrait_image = load(preset.portrait_image)
	
	sprite.position += _preset.sprite_offset
	shadow.position += _preset.shadow_offset
	
func set_max_health(_max_health:int):
	max_health = _max_health
	healthbar.max_value = max_health
	health = max_health
	healthbar.value = health
	

func show_detail(detail_name:String):
	if(detail_name == "rescue"):
		rescue_text.show()
	
func check_overlap(map_pos:Vector2i):
	for entity in get_tree().get_nodes_in_group(C.GROUPS_CIVILIANS):
		var civilian_tile_pos = WorldManager.level.grid.local_to_map(entity.position)
		if civilian_tile_pos == map_pos:
			entity.rescued.emit()


func get_abilities()->Array[Ability]:
	var abilities:Array[Ability]= []
	for child in get_children():
		if child is Ability:
			var ability = child as Ability
			abilities.append(ability)
		
	return abilities
	
func get_ability(ability_name:String)->Ability:
	for ability in get_abilities():
		if ability.ability_name == ability_name:
			return ability
	return null
func hide_all_details():
	rescue_text.hide()
	

func get_enemies()->Array[Entity]:
	var enemies:Array[Entity] = []
	for entity in get_tree().get_nodes_in_group(C.GROUPS_ENTITIES):
		if entity.team != team:
			if C.ALLIED_TEAMS[C.TEAM.keys()[team]].has(entity.team):
				continue
			enemies.push_front(entity as Entity)
				

	return enemies 
	
func get_allies()->Array[Entity]:
	var allies:Array[Entity] = []
	for entity in get_tree().get_nodes_in_group(C.GROUPS_ENTITIES):
		if entity.team == team:
			allies.push_front(entity as Entity)
		elif C.ALLIED_TEAMS[C.TEAM.keys()[team]].has(entity.team):
			allies.push_front(entity as Entity)
	return allies 
	
func undo_move(initial_position:Vector2):
	WorldManager.level.grid.set_map_cursor(initial_position)
	position = initial_position
	move_counter = 1
	
func clear_sprite_material():
	sprite.material = null
	
func set_orientation(vertical:bool):
	sprite.flip_h = vertical
	
func clear_threat():
	threat = null
	threat_updated.emit()
	
func _on_turn_start():
	move_counter = max_move_counter
	action_counter = max_action_counter
	Util.sysprint("%s.Entity._on_turn_start"%[entity_name],"counter refresh done")
	
func _on_turn_end():
	pass
	
func _on_mouse_entered() -> void:
	add_to_group(C.HOVERED_ENTITIES)
	
func _on_mouse_exited() -> void:
	remove_from_group(C.HOVERED_ENTITIES)

	
func _on_knockback(distance:int, source_map_pos:Vector2i):
	if health == 0:
		return
	
	var prev_position = map_position
	var direction = Util.get_direction(source_map_pos,map_position)
	#change direction to away from the source 
	var target_pos = map_position + direction * distance 
	if !WorldManager.level.grid.is_within_bounds(target_pos):
		return
	if !WorldManager.level.grid.get_possible_tiles().has(target_pos):
		return
	
	WorldManager.level.increment_animation_counter(1) 
	animation_counter+=1
	var tween = create_tween()
	tween.tween_property(self, "position", WorldManager.level.grid.map_to_local(target_pos), 0.3)
	await tween.finished.connect(func():
		knockback_animation_finished.emit(distance,source_map_pos,prev_position)
		animation_counter -= 1
		WorldManager.level.increment_animation_counter(-1) 
	)
	
	
func _on_area_2d_mouse_entered() -> void:
	add_to_group(C.GROUPS_HOVERED_ENTITIES)

func _on_area_2d_mouse_exited() -> void:
	remove_from_group(C.GROUPS_HOVERED_ENTITIES)

func _on_hit(damage:int) -> void:
	health -= damage
	healthbar.value = health
	
	if health <= 0:
		health = 0
		death.emit()
	
	VfxManager.flash(sprite,Color.DARK_RED,0.15)
	VfxManager.spawn("hit-spark-1",self,{"offset":Vector2(randi_range(-12,12),randi_range(-12,4))})
	
	
func _on_death() -> void:
	for group in get_groups():
		remove_from_group(group)
		
	if team == C.TEAM.ENEMY:
		WorldManager.level.check_player_victory()

	print("animation_counter ", animation_counter)
	if animation_counter != 0:
		WorldManager.level.increment_animation_counter(animation_counter * -1)
	
	clear_threat()
	queue_free()
		
func _on_selected():
	if team == C.TEAM.PLAYER:
		WorldManager.level.selected_entity = self
		#UIManager.ui.set_context(self)
		WorldManager.level.input_waiting_on_ability = false
		sprite.material = preload("res://src/shaders/outline/selected_highlight_material.tres")
	else:
		print("sprite.material = null")
		clear_sprite_material()
		UIManager.ui.clear_context()

		
func _on_ability_used(ability:Ability):
	WorldManager.level.clear_entity_moved_history()
	action_counter -= ability.action_cost
	if ability.is_action:
		move_counter = 0

func _on_apply_status(status:Status):
	Util.sysprint("%s.Entity._on_apply_status"%[entity_name],"applying status: %s"%[status.status_props.status_name])
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
		
