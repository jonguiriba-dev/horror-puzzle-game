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
		for possible_tile in possible_tiles:
			if possible_tile.value > 0:
				host.move_to_selected_tile(possible_tile.position)
				
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
	for tile in host.get_reachable_tiles(host.move_range):
		possible_tiles.push_front({
			"position": tile,
			"value": get_tile_value(tile)
		})
		
func get_tile_value(tile_pos:Vector2)->int:
	var value = 0
	
	for ability in host.get_abilities():
		for target in get_tree().get_nodes_in_group(C.TARGETS):
			var target_map_pos = WorldManager.grid.local_to_map(target.position)
			var distance = tile_pos.distance_to(target_map_pos)
			if distance <= ability.ability_range and distance != 0:
				value = +10
	return value
