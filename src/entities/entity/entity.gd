extends Node2D
class_name Entity

@export var entity_name := ""
@export var team :C.TEAM = C.TEAM.PLAYER

@onready var sprite :AnimatedSprite2D= $EntitySprite
@onready var rescue_text := $EntitySprite/RescueText

var move_speed = 55
var move_range = 3
var can_move := false
var health = 1
var target_position=null
var path=null
var move_counter = 1
var action_counter = 1

signal hit(damage:int)
signal move_target_set(map_position:Vector2i)
signal death
signal move_end
signal turn_end(entity:Entity)
signal turn_start(entity:Entity)

func _ready() -> void:
	add_to_group(C.ENTITIES)
	
	move_target_set.connect(_on_move_target_set)
	death.connect(_on_death)
	hit.connect(_on_hit)
	
	if team == C.TEAM.ENEMY:
		add_to_group(C.GROUPS.ENEMIES)
		turn_end.connect(WorldManager._on_enemy_unit_turn_end)
		turn_start.connect(WorldManager._on_enemy_unit_turn_start)
	else:
		add_to_group(C.GROUPS.TARGETS)
	
	WorldManager.turn_end.connect(_on_turn_end)
	WorldManager.turn_start.connect(_on_turn_start)
	
	for ability in get_abilities():
		ability.applied.connect(_on_ability_applied)
	
	if sprite:
		sprite.play("idle")

func _physics_process(delta: float) -> void:
	if target_position != null and path.size() > 0:
		move(delta)
	
func move(delta: float)->void:
	var curr_tile = WorldManager.grid.local_to_map(position)
	var next_local_pos = WorldManager.grid.map_to_local(path[0])
	var new_position = position.lerp(next_local_pos,0.4)

	position += (new_position - position) * delta * 45
	
	var distance = position - new_position
	if abs(distance.x) < 0.1 and abs(distance.y) < 0.1:
		position = next_local_pos
	if position == next_local_pos:
		path.remove_at(0)
	if path.size() == 0:
		target_position = null
		check_overlap(curr_tile)
		move_end.emit()

	
func check_overlap(map_pos:Vector2i):
	for entity in get_tree().get_nodes_in_group(C.GROUPS.ENTITIES):
		if entity is Civilian:
			var civilian_tile_pos = WorldManager.grid.local_to_map(entity.position)
			if civilian_tile_pos == map_pos:
				entity.rescued.emit()

func _on_area_2d_mouse_entered() -> void:
	add_to_group(C.HOVERED_ENTITIES)

func _on_area_2d_mouse_exited() -> void:
	remove_from_group(C.HOVERED_ENTITIES)

func show_detail(detail_name:String):
	if(detail_name == "rescue"):
		rescue_text.show()
	
func _on_hit(damage:int) -> void:
	health -= damage
	print("took damage", damage, " health ", health )
	if health <= 0:
		health = 0
		death.emit()
		print("death.emit")

func _on_death() -> void:
	print("death ",self)
	queue_free()
	remove_from_group(C.GROUPS.ENTITIES)
	remove_from_group(C.GROUPS.UNITS)
	remove_from_group(C.GROUPS.CIVILIANS)
	remove_from_group(C.GROUPS.TARGETS)

func _on_move_target_set(map_position:Vector2i)->void:
	move_to_selected_tile(map_position)
	
func move_to_selected_tile(target_pos:Vector2i):
	var curr_tile = WorldManager.grid.local_to_map(position)
	path = WorldManager.grid.astar_grid.get_id_path(curr_tile, target_pos)
	if path.size() > 0:
		path.remove_at(0)
	target_position = target_pos
	
	for tile in path:
		WorldManager.grid.set_highlight(tile, Grid.HIGHLIGHT_COLORS.ORANGE)
	move_counter -= 1
func hide_all_details():
	rescue_text.hide()
	
func _on_turn_start(team_turn:C.TEAM):
	pass
	
func _on_turn_end(team_turn: C.TEAM):
	pass
	
func _on_mouse_entered() -> void:
	add_to_group(C.HOVERED_ENTITIES)
	
func _on_mouse_exited() -> void:
	remove_from_group(C.HOVERED_ENTITIES)

func get_abilities()->Array[Ability]:
	var abilities:Array[Ability]= []
	for child in get_children():
		if child.name.contains("Ability_"):
			var ability = child as Ability
			abilities.append(ability)
		
	return abilities

func _on_ability_applied(ability:Ability):
	action_counter -= 1
