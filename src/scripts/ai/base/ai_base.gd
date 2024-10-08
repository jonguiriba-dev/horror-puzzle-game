extends Node
class_name AI

@onready var host:Unit = self.get_parent()
var possible_tiles = []
var path_to_nearest_target
var threat
var tile_labels:Array = []
func _ready():
	host.turn_start.connect(_on_turn_start)
	host.move_end.connect(_on_host_move_end)
	
func _on_turn_start(entity:Entity):
	var team_turn = WorldManager.team_turn
	if threat:
		attack_target()
		
	if team_turn == host.team:
		
		for l in tile_labels:
			l.queue_free()
		tile_labels = []
		
		analyze_tiles()
		if possible_tiles.size()  == 0:
			return
			
		for t in possible_tiles:
			var l = Label.new()
			l.text = str(t.value)
			WorldManager.grid.prop_layer.add_child(l)
			l.position = WorldManager.grid.map_to_local(t.position) + Vector2(-8,-8)
			l.set("theme_override_font_sizes/font_size", 12)
			tile_labels.push_front(l)
		host.move_to_selected_tile(possible_tiles[0].position)

		
func _on_host_move_end():
	highlight_target()
	host.turn_end.emit(host)
	
func highlight_target():
	for ability in host.get_abilities():
		var reachable_tiles = host.get_reachable_tiles(ability.ability_range)
		for target in get_tree().get_nodes_in_group(C.TARGETS):
			var target_map_pos = WorldManager.grid.local_to_map(target.position)
			if reachable_tiles.has(target_map_pos):
				threat = {"tile":target_map_pos, "ability":ability, "target":target}
				WorldManager.grid.set_highlight(target_map_pos,Grid.HIGHLIGHT_COLORS.RED)
				WorldManager.grid.threat_tiles.push_front(threat.tile)

func attack_target():
	threat.ability.apply_effect(threat.target) 
	threat = null
	
func analyze_tiles():
	possible_tiles = []
	var nearest = Util.get_nearest_in_group(host.position, C.GROUPS_TARGETS)
	if !nearest:
		return
	
	path_to_nearest_target = WorldManager.grid.get_nearest_path(
		WorldManager.grid.local_to_map(host.position), 
		WorldManager.grid.local_to_map(nearest.position)
	)
	
	if path_to_nearest_target.size() == 0:
		path_to_nearest_target = WorldManager.grid.get_nearest_path(
			WorldManager.grid.local_to_map(host.position), 
			WorldManager.grid.local_to_map(nearest.position),
			false
		)
	
	for tile in host.get_moveable_tiles(host.move_range):
		possible_tiles.push_front({
			"position": tile,
			"value": get_tile_value(tile)
		})
	possible_tiles.sort_custom(
		func(a,b):
			return a.value > b.value
	)
func get_tile_value(tile_pos:Vector2i)->int:
	var value = 0
	
	for ability in host.get_abilities():
		for target in get_tree().get_nodes_in_group(C.TARGETS):
			var target_map_pos = WorldManager.grid.local_to_map(target.position)
			
			value += _get_attack_score(tile_pos,target_map_pos,ability.ability_range)
			#value += _get_location_score(tile_pos)
			
			print("location score",_get_location_score(tile_pos))
	
	print("path_to_nearest_target> ", path_to_nearest_target, " tile_pos: ",tile_pos)
	if path_to_nearest_target.has(tile_pos):
		var host_map_pos = WorldManager.grid.local_to_map(host.position)
		value += 5 + host_map_pos.distance_to(tile_pos)
	else:
		value += _get_location_score(tile_pos)
		
	if WorldManager.grid.threat_tiles.has(tile_pos):
		value -= 15
	return value

func _get_attack_score(source_tile:Vector2i,target_map_pos:Vector2, ability_range:int, ):
	var distance_to_target = source_tile.distance_to(target_map_pos)
	if distance_to_target <= ability_range and distance_to_target != 0:
		return	10
	return 0

func _get_location_score(target_map_pos:Vector2i)->int: 
	var boundary_rect:Rect2i = WorldManager.grid.tiles_layer.get_used_rect()
	var distance_from_center = target_map_pos.distance_to(((boundary_rect.position + boundary_rect.size) / 2))
	return (distance_from_center / 2) * -1
