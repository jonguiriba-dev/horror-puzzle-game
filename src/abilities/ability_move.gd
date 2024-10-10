extends Ability
class_name AbilityMove

func _ready() -> void:
	super()
	highlight_color = Color.GREEN
	has_ui = false
	ability_name = "move"
	ability_range = 3
	is_enemy_obstacle = true
	actions = [
		AbilityAction.new(
			C.ABILITY_TARGET_GROUP.TILE,
			C.ABILITY_ACTION_TYPE.MOVE
		)
	]
	
func get_reachable_tiles(_range:int):
	var navigatable_tiles = []
	var possible_tiles = WorldManager.grid.get_possible_tiles()
	var map_position = WorldManager.grid.local_to_map(host.position)
	
	var queued_tiles = [map_position]
	
	var step = 0
	while !queued_tiles.is_empty():
		var pending_tiles = queued_tiles.duplicate()
		queued_tiles = []
		for direction in [Vector2i(-1,0),Vector2i(1,0),Vector2i(0,-1),Vector2i(0,1)]:
			for pending_tile in pending_tiles:
				var next_tile = pending_tile + direction
				if possible_tiles.has(next_tile):
					navigatable_tiles.push_front(next_tile)
					queued_tiles.push_front(next_tile)
		step += 1
		if step == _range:
			break
	return navigatable_tiles
