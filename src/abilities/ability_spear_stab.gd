extends Ability
class_name AbilitySpearStab
func _ready() -> void:
	super()
	texture = preload("res://assets/ui/ability_frame_spear.png")
	ability_name = "spear_stab"
	ability_range = 2
	knockback_distance = 1
	damage = 1
	target_count = 2
	actions = [
		AbilityAction.new(
			AbilityAction.TARGET_TYPES.ENEMY,
			AbilityAction.ACTION_TYPES.DAMAGE
		),
		AbilityAction.new(
			AbilityAction.TARGET_TYPES.ENEMY,
			AbilityAction.ACTION_TYPES.KNOCKBACK
		)
	]
func get_target_tiles(map_pos:Vector2i=host.map_position,_range:int=ability_range)->Array[Vector2i]:
	var tiles:Array[Vector2i]= []
	for x in range(_range*-1, _range+1):
		for y in range(_range*-1, _range+1):
			var next_position = Vector2i(x+map_pos.x, y+map_pos.y)
			if abs(Util.get_manhattan_distance(map_pos,next_position)) <= _range:
				tiles.append(next_position)
	
	return tiles
