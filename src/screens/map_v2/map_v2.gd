extends Control

@onready var location_layer := $LocationLayer
@onready var connection_node := $LocationLayer/ConnectionNode
@onready var temp_location_layer = location_layer.duplicate()

const NODE_VARIATION = 20
const MIN_LOCATION_COUNT := 16
const MAX_CONNECTION_DISTANCE = 100
const MIN_CONNECTIONS = 1
const MAX_CONNECTIONS = 4
#const MIN_LOCATION_COUNT := 3
var locations := []
var connections := []

func _ready():
	generate_map()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		generate_map()
	if event.is_action_pressed("alt-click"):
		if location_layer.get_used_cells().size() != 0:
			for tile in location_layer.get_used_cells():
				location_layer.set_cell(tile)
		else:
			for tile in temp_location_layer.get_used_cells():
				location_layer.set_cell(tile,0,Vector2i(0,0))
				
func generate_map():
	locations = []
	connections = []
	for child in location_layer.get_children():
		if child is Sprite2D:
			child.queue_free()
	generate_locations(location_layer.duplicate())
	connection_node.connections = generate_connections()
	connection_node.queue_redraw()
	set_start_location()

func set_start_location():
	var processed_locations = locations.map(func(e):
		var centralized_pos =(  DisplayServer.window_get_size() - Vector2i(abs(e.position.x),abs(e.position.y))) 
		centralized_pos = (centralized_pos.x + centralized_pos.y) / 2
		return {"centralized_pos":centralized_pos,"location":e}
	)
	
	processed_locations.sort_custom(func(a,b):
		return a.centralized_pos > b.centralized_pos
	)
	
	processed_locations.map(func(e):
		print(e.centralized_pos, " " , e.location.position)
	)
	#var start_location = processed_locations[abs(processed_locations.size() / 2)].location
	var start_location = processed_locations[0].location
	print("start",start_location)
	
	start_location.sprite.modulate = Color.BLUE

	
	return start_location
		

func generate_locations(tilemap_layer:TileMapLayer):
	for i in range(MIN_LOCATION_COUNT):
		if tilemap_layer.get_used_cells().size() == 0:
			break		
		var random_cell :Vector2i= tilemap_layer.get_used_cells().pick_random()
		print(random_cell)
		tilemap_layer.set_cell(random_cell)
		
		var delete_count = 9
		for x in range(-1,2):
			for y in range(-1,2):
				if delete_count == 0:
					break
				delete_count -= 1
				tilemap_layer.set_cell(random_cell+Vector2i(x,y))
				print("delete node ",random_cell+Vector2i(x,y))
				
		
		var sprite := Sprite2D.new()
		sprite.texture = load("res://assets/etc/node_2.png")
		location_layer.add_child(sprite)
		sprite.position = tilemap_layer.map_to_local(random_cell)
		sprite.position += Vector2(randi_range(-NODE_VARIATION,NODE_VARIATION),randi_range(-NODE_VARIATION,NODE_VARIATION))
		
		
		var max_connections = 2
		if randf_range(0,1) > 0.5:
			max_connections += 1
		if randf_range(0,1) > 0.25:
			max_connections += 1
		
		locations.push_front({
			"position":sprite.position,
			"max_connections":max_connections,
			"sprite":sprite
		})
		print(sprite.position)
		
		var in_point = Vector2.ZERO
		var out_point = Vector2.ZERO
		#
		#if locations.size() > 1:
			#var source_location = locations[locations.size() - 1]
			#var midpoint = (source_location + sprite.position) / 2
			#
			#in_point = midpoint + Vector2(randi_range(-3,3),randi_range(-3,3))
			#out_point = midpoint + Vector2(randi_range(-3,3),randi_range(-3,3))
			##in_point = midpoint 
			##out_point = midpoint 
			#connection_node.points.push_front({
				#"point": midpoint,
				#"in_point": in_point,
				#"out_point": out_point,
			#})
			#
func  generate_connections():
	connections = []
	var used_locations := []
	for i in range(locations.size()-1):
		var current_location = locations[i]
		used_locations.push_front(current_location)
		var available_locations = locations.filter(
			func (e): return e != current_location
		)
		#var available_locations = locations.filter(
			#func(e): return !used_locations.has(locations)
		#)
		
		var location_distances = []
		for location in available_locations:
			var distance = Util.get_manhattan_distance(current_location.position,location.position)
			location_distances.push_front({"distance":distance,"location":location})
	
		location_distances.sort_custom(func (a,b): return a.distance < b.distance)		
		
		for k in range(current_location.max_connections):
			var location_distance = location_distances[k]
			var target_connections = connections.filter(
				func (e): 
					return e.source == location_distance.location or e.target == location_distance.location
			)
			if target_connections.size() > location_distance.location.max_connections-1:
				break
			
			var source_connections = connections.filter(
				func (e): 
					return e.source == current_location or e.target == current_location
			)
			if source_connections.size() > current_location.max_connections-1:
				if source_connections.size() >= MIN_CONNECTIONS:
					break
				
			print("connecting ", current_location, " to ", location_distance.location.position)
			connections.push_front({
				"source":current_location,
				"target":location_distance.location,
			})
	return connections

	
