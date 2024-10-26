extends Node2D
class_name Entity
# use shader https://godotshaders.com/shader/highlight-canvasitem/ for highlighting icons
@onready var sprite :AnimatedSprite2D= $EntitySprite
@onready var rescue_text := $EntitySprite/RescueText
@onready var healthbar := $Healthbar

@export var preset:EntityPreset

var move_speed = 55

var portrait_image
var entity_name := ""
var max_health = 1
var health = 1
var team :C.TEAM = C.TEAM.PLAYER
var move_range = 3
var can_move := false
var move_counter = 1
var action_counter = 1
var max_move_counter = 1
var max_action_counter = 1
var initial_position:Vector2i
var map_position:Vector2i:
	get:
		return WorldManager.grid.local_to_map(position)

signal hit(damage:int)
signal knockback(distance:int,source_pos:Vector2)
signal death
signal move_end
signal turn_end
signal turn_start
signal selected

func _ready() -> void:
	load_preset(preset)
	add_to_group(C.GROUPS_ENTITIES)
	death.connect(_on_death)
	hit.connect(_on_hit)
	knockback.connect(_on_knockback)
	turn_end.connect(_on_turn_end)
	turn_start.connect(_on_turn_start)
	
	if team == C.TEAM.ENEMY:
		add_to_group(C.GROUPS_ENEMIES)
		sprite.set_modulate(Color.RED)
	else:
		add_to_group(C.GROUPS_TARGETS)
		if team == C.TEAM.PLAYER:
			add_to_group(C.GROUPS_PLAYER_ENTITIES)
	
	for ability in get_abilities():
		ability.applied.connect(_on_ability_applied)
	
	if sprite:
		sprite.play("idle")
	
	WorldManager.register_entity(self)
	
func load_preset(_preset:EntityPreset):
	if !_preset:
		return
	entity_name = _preset.entity_name
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
	
func set_max_health(_max_health:int):
	max_health = _max_health
	healthbar.max_value = max_health
	health = max_health
	healthbar.value = health
	

func show_detail(detail_name:String):
	if(detail_name == "rescue"):
		rescue_text.show()
	
func check_overlap(map_pos:Vector2i):
	for entity in get_tree().get_nodes_in_group(C.GROUPS_ENTITIES):
		if entity is Civilian:
			var civilian_tile_pos = WorldManager.grid.local_to_map(entity.position)
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
	
func _move_position(_position:Vector2):
	position = _position
	WorldManager.grid.set_map_cursor(WorldManager.grid.local_to_map(position))

func get_enemies()->Array[Entity]:
	var enemies:Array[Entity] = []
	for entity in get_tree().get_nodes_in_group(C.GROUPS_ENTITIES):
		if entity.team == C.TEAM.ENEMY and team == C.TEAM.PLAYER:
			enemies.push_front(entity as Entity)
		elif entity.team != C.TEAM.ENEMY and team == C.TEAM.ENEMY:
			enemies.push_front(entity as Entity)
	return enemies 
	
func undo_move():
	if move_counter < max_move_counter:
		_move_position(initial_position)
		move_counter += 1
		
func _on_turn_start():
	move_counter = max_move_counter
	action_counter = max_action_counter
	initial_position = position
	
func _on_turn_end():
	pass
	
func _on_mouse_entered() -> void:
	add_to_group(C.HOVERED_ENTITIES)
	
func _on_mouse_exited() -> void:
	remove_from_group(C.HOVERED_ENTITIES)

func _on_ability_applied(ability:Ability):
	if ability.ability_name == "move":
		return
	action_counter -= 1
	move_counter = 0
	
func _on_knockback(distance:int, source_map_pos:Vector2i):
	var direction = Util.get_direction(source_map_pos,WorldManager.grid.local_to_map(position))
	#change direction to away from the source 
	var target_pos = WorldManager.grid.local_to_map(position) + direction * -1 * distance 
	if !WorldManager.grid.is_within_bounds(target_pos):
		return
	if !WorldManager.grid.get_possible_tiles().has(target_pos):
		return
	var tween = create_tween()
	tween.tween_property(self, "position", WorldManager.grid.map_to_local(target_pos), 0.3)

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

func _on_death() -> void:
	for group in get_groups():
		remove_from_group(group)
	queue_free()
		
