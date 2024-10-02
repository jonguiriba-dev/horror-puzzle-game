extends Node
class_name AI

@onready var host:Unit = self.get_parent()
var possible_tiles = []
var threat
func _ready():
	WorldManager.turn_start.connect(_on_turn_start)
	host.move_end.connect(_on_host_move_end)
	
func _on_turn_start(team_turn:C.TEAM):
	if threat:
		attack_target()
		
	if team_turn == host.team:
		analyze_tiles()
		print("POSSIBLE TILES: ",possible_tiles)
		for t in possible_tiles:
			var l = Label.new()
			l.text = str(t.value)
			WorldManager.grid.prop_layer.add_child(l)
			l.position = WorldManager.grid.map_to_local(t.position) + Vector2(-8,-8)
			l.set("theme_override_font_sizes/font_size", 12)
		host.move_to_selected_tile(possible_tiles[0].position)
		#for possible_tile in possible_tiles:
			#if possible_tile.value > 0:
				#host.move_to_selected_tile(possible_tile.position)
				#break;
		#
		
func _on_host_move_end():
	highlight_target()
	
func highlight_target():
	for ability in host.get_abilities():
		var reachable_tiles = host.get_reachable_tiles(ability.ability_range)
		for target in get_tree().get_nodes_in_group(C.TARGETS):
			var target_map_pos = WorldManager.grid.local_to_map(target.position)
			if reachable_tiles.has(target_map_pos):
				threat = {"tile":target_map_pos, "ability":ability, "target":target}
				WorldManager.grid.set_highlight(target_map_pos,Grid.HIGHLIGHT_COLORS.RED)

func attack_target():
	threat.ability.apply_effect(threat.target) 
	threat = null
	
func analyze_tiles():
	for tile in host.get_moveable_tiles(host.move_range):
		possible_tiles.push_front({
			"position": tile,
			"value": get_tile_value(tile)
		})
	possible_tiles.sort_custom(
		func(a,b):
			return a.value > b.value
	)
func get_tile_value(tile_pos:Vector2)->int:
	var value = 0
	
	for ability in host.get_abilities():
		for target in get_tree().get_nodes_in_group(C.TARGETS):
			var target_map_pos = WorldManager.grid.local_to_map(target.position)
			
			value += _get_attack_score(tile_pos,target_map_pos,ability.ability_range)
			value += _get_location_score(tile_pos)
			print("location score",_get_location_score(tile_pos))
	return value

func _get_attack_score(source_tile:Vector2i,target_map_pos:Vector2, ability_range:int, ):
	var distance_to_target = source_tile.distance_to(target_map_pos)
	if distance_to_target <= ability_range and distance_to_target != 0:
		return	5
	return 0

func _get_location_score(target_map_pos:Vector2i)->int: 
	var targets = get_tree().get_nodes_in_group(C.GROUPS.TARGETS) 
	var boundary_rect:Rect2i = WorldManager.grid.tiles_layer.get_used_rect()
	
	var targets_distance = targets.map(
		func (target):
			var map_position = WorldManager.grid.tiles_layer.local_to_map(target.position)
			return map_position.distance_to(target_map_pos)
	)
	var sum = targets_distance.reduce(
		func(acc,num): 
			return acc + num,
		0
	)
	var avg = (sum / (targets.size() * 1.0)) * -1

	return int(avg)
