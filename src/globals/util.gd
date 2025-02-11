extends Node

signal input_recieved
var DIRECTIONS = {
	"NORTH"=Vector2i(0,-1),
	"WEST"=Vector2i(-1,0),
	"EAST"=Vector2i(1,0),
	"SOUTH"=Vector2i(0,1)
}

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		input_recieved.emit()

func wait_for_input():
	await input_recieved

func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout

func sysprint(source_text:String,info_text:String):
	print_rich("[color=#ad9842]"+source_text+"[/color] : [color=#cec465]"+info_text+"[/color]")

func get_nearest(pos:Vector2,nodes:Array):
	nodes.filter(func(e):
		if is_instance_valid(e):
			return true
		return false
	)

	if nodes.size() <= 0:
		return null
	
	var nearest = nodes[0]
	for node in nodes:
		if node is Entity:
			var entity = node as Entity
			var new_distance = pos.distance_to(entity.position)
			var old_distance = pos.distance_to(nearest.position)
			if new_distance < old_distance:
				nearest = entity
	return nearest

func get_direction(source:Vector2i,target:Vector2i)->Vector2i:
	var direction = (target - source)
	if abs(direction.x) > abs(direction.y):
		if direction.x > 0: 
			direction.x = 1 
		else:
			direction.x = -1
		direction.y = 0
	else:
		if direction.y > 0: 
			direction.y = 1 
		else:
			direction.y = -1
		direction.x = 0
		
	return direction
	
func get_manhattan_distance(a:Vector2,b:Vector2):
	var y_distance = Vector2(0,a.y).distance_to(Vector2(0,b.y))
	var x_distance = Vector2(a.x,0).distance_to(Vector2(b.x,0))
	return abs(y_distance) + abs(x_distance)

func get_pathfinding_distance(team:C.TEAM,a:Vector2,b:Vector2,grid:Grid):
	grid.get_possible_tiles(team,7)
	var path = grid.astar_grid.get_id_path(a, b)
	return path.size()

func get_global_from_local(local_position:Vector2,source_node:Node2D):
	var node = Node2D.new()
	source_node.add_child( node )
	node.position = local_position
	var global_pos = node.global_position
	node.queue_free()
	return global_pos

func get_meta_from_node(node:Node,key:String):
	if is_instance_valid(node):
		if node.has_meta(key):
			return node.get_meta(key)
		return null
