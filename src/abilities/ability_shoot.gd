extends Ability
class_name AbilityShoot
func _ready() -> void:
	super()
	texture = preload("res://assets/ui/ability_frame_crossbow_shoot.png")
	ability_name = "shoot"
	ability_range = 5
	knockback_distance = 1
	damage = 1
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
