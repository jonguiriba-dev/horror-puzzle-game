extends CharacterBody2D
class_name UnitEntity

@onready var navigation_agent := $NavigationAgent2D
@onready var sprite := $Sprite2D

@export var team :C.TEAM = C.TEAM.PLAYER
@export var sprite_texture:CompressedTexture2D= preload("res://assets/player.png")

enum STATE{
	INACTIVE,
	SELECTED,
	MOVE_SELECTION,
	MOVED,
	TARGETTING
}

var move_speed = 55
var move_range = 3
var can_move := false
var state := STATE.INACTIVE
var health = 1
signal hit(damage:int)
signal death

func _ready() -> void:
	sprite.texture = sprite_texture
	for ability in get_abilities():
		ability.connect("targetting",_on_ability_targetting)
		ability.connect("stopped_targetting",_on_ability_stopped_targetting)
		
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		if team == C.TEAM.PLAYER:
			print("state",state)
			if( is_in_group(C.HOVERED_ENTITIES) and 
				(state == STATE.INACTIVE or state == STATE.SELECTED)
			):
				highlight_moveable_tiles(move_range)
				UIManager.ui.set_context(self)
				state = STATE.MOVE_SELECTION
				print("state: MOVE_SELECTION", state)
					
			elif(event.is_action_pressed("click") and state == STATE.MOVE_SELECTION):
				if(get_reachable_tiles(move_range).has(WorldManager.active_tilemap.get_map_mouse_position())):
					var mouse_pos = WorldManager.active_tilemap.get_local_mouse_position()
					var map_pos = WorldManager.active_tilemap.local_to_map(mouse_pos)
					var local_pos = WorldManager.active_tilemap.map_to_local(map_pos) 
					var global = WorldManager.active_tilemap.to_global(local_pos)
					global -= Vector2(1,3) # wonder why this works best
					move_to(global)
					#state = STATE.MOVED
					state = STATE.SELECTED # test
				else:
					state = STATE.SELECTED
				WorldManager.active_tilemap.clear_all_highlights()
			elif(event.is_action_pressed("click") and state == STATE.TARGETTING):
				print("apply_ability")
		
func _physics_process(delta: float) -> void:
	
	if navigation_agent.target_position != null:
		navigate()

func navigate():
	var current_agent_pos = global_position
	var next_path_pos :Vector2= navigation_agent.get_next_path_position()
	var next_tile = get_next_path_tile(next_path_pos)

	#get the nearest tile except current tile
	var direction = global_position.direction_to(next_path_pos)
	print("dir",Vector2(roundi(direction.x),roundi(direction.y)))
	var map_pos = WorldManager.active_tilemap.local_to_map(WorldManager.active_tilemap.to_local(next_path_pos))
	WorldManager.active_tilemap.set_highlight(map_pos)
	var local_pos = WorldManager.active_tilemap.map_to_local(map_pos) 
	var global = WorldManager.active_tilemap.to_global(local_pos)
	global -= Vector2(1,3) # wonder why this works best
	
	var new_velocity = current_agent_pos.direction_to(global) * move_speed
	#var new_velocity = current_agent_pos.direction_to(next_path_pos) * move_speed
	
	navigation_agent.set_velocity(new_velocity)

	move_and_slide()
	
func get_next_path_tile(next_path_pos)->Vector2:
	return Vector2()
func move_to(point:Vector2)->void:
	navigation_agent.target_position = point
	var nav_path = navigation_agent.get_current_navigation_path()
	var nav_points = []
	for nav_point in nav_path:
		var mod_x = int(nav_point.x) % 32
		var mod_y = int(nav_point.y) % 32
		nav_points.append(Vector2(mod_x,mod_y))
	
func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	pass

func get_abilities()->Array[Ability]:
	var abilities:Array[Ability]= []
	for child in get_children():
		if child.name.contains("Ability_"):
			var ability = child as Ability
			abilities.append(ability)
		
	return abilities

func highlight_moveable_tiles(move_range):
	WorldManager.active_tilemap.clear_all_highlights()
	var moveable_tile_positions = get_reachable_tiles(move_range)
	for pos in moveable_tile_positions:
		WorldManager.active_tilemap.set_highlight(pos)
		
func highlight_attack_range_tiles(attack_range):
	WorldManager.active_tilemap.clear_all_highlights()
	var moveable_tile_positions = get_reachable_tiles(attack_range)
	for pos in moveable_tile_positions:
		WorldManager.active_tilemap.set_highlight(pos,CustomTileMapLayer.HIGHLIGHT_COLORS.ORANGE)
		
func map_position()->Vector2i:
	return WorldManager.active_tilemap.local_to_map(position)

func get_reachable_tiles(_range:int):
	var used_cells = WorldManager.active_tilemap.get_used_cells()
	var map_position = WorldManager.active_tilemap.local_to_map(position)
	
	var tiles = []
	for x in range(_range*-1, _range+1, 1):
		for y in range(_range*-1, _range+1, 1):
			var next_position = Vector2i(x+map_position.x, y+map_position.y)
			if(used_cells.has(next_position) and
			 WorldManager.active_tilemap.get_manhattan_distance(map_position,next_position) <= _range ):
				tiles.append(next_position)
	return tiles


func _on_mouse_entered() -> void:
	add_to_group(C.HOVERED_ENTITIES)
	
func _on_mouse_exited() -> void:
	remove_from_group(C.HOVERED_ENTITIES)
	
func _on_ability_targetting(ability:Ability) -> void:
	highlight_attack_range_tiles(ability.ability_range)
	print("STATE 3")
	state = STATE.TARGETTING

func _on_ability_stopped_targetting(ability:Ability) -> void:
	WorldManager.active_tilemap.clear_all_highlights()
	state = STATE.SELECTED
	print("STATE 2")

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
