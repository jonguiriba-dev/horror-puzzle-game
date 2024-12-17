extends Ability
class_name AbilityVault

func _ready() -> void:
	super()
	ability_name = "Vault"
	ability_range = 3
	target_count = 1
	actions = []
	highlight_color = Color.GREEN
	range_pattern = TilePattern.PATTERNS.LINE
	use_host_as_origin = true
	action_cost = 0
	tile_exclude_flag = Grid.TILE_EXCLUDE_FLAGS.EXCLUDE_OBSTACLES_EMPTY
	tile_exclude_self = true
	max_charges = 2
	is_action = false
	refresh_charges()
	
func _play_animation(target_map_position:Vector2i):
	AnimationManager.jump(host,WorldManager.grid.map_to_local(target_map_position))
	SfxManager.play("grunt-girl-1")
	
func get_target_tiles(
	map_pos:Vector2i=host.map_position,
	_range:int=ability_range,
)->Array[Vector2i]:
	var target_tiles:Array[Vector2i] = super(map_pos,_range)
	var possible_tiles:Array[Vector2i] = []
	for tile in target_tiles:
		possible_tiles.push_front(tile + Util.get_direction(map_pos,tile))
			
	return possible_tiles.filter(func (e): return WorldManager.grid.is_empty_tile(e))
