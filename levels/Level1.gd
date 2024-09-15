extends Node2D

@onready var tilemap : TileMapLayer = $TileMapLayer
@onready var player_unit := $TileMapLayer/Unit
@onready var unit2 := $TileMapLayer/Unit2
func _ready() -> void:
	tilemap.set_cell(Vector2i(0,0),8,Vector2i(0,0))
	WorldManager.active_tilemap = tilemap
	
func _unhandled_input(event: InputEvent) -> void:
	if(event.is_action_pressed("click")):
		var map_pos = get_global_mouse_position()
		player_unit.move_to(map_pos)
		
	if(event.is_action_pressed("alt-click")):
		var mouse_pos = WorldManager.active_tilemap.get_local_mouse_position()
		var local_pos = WorldManager.active_tilemap.local_to_map(mouse_pos)
		print("mouse_pos ",mouse_pos)
		print("local_pos ",local_pos)
		var unit_pos = unit2.global_position
		print("unit_pos ",unit_pos)
		WorldManager.active_tilemap.add_test(local_pos)
		
		#WorldManager.active_tilemap.set_cell(local_pos,8,Vector2i(0,0))
		#
		#print("WorldManager.active_tilemap.tile_set.tile_size.x ",WorldManager.active_tilemap.tile_set.tile_size.x)
	#
		##var sprite_pos = Vector2(WorldManager.active_tilemap.tile_set.tile_size.x * local_pos.x	,WorldManager.active_tilemap.tile_set.tile_size.y* local_pos.y)
		#var sprite_pos = WorldManager.active_tilemap.map_to_local(local_pos)
		#var offset_vector = Vector2(0,-12)
		#var entity = preload("res://entities/Entity/Entity.tscn").instantiate()
		#entity.position = sprite_pos
		#entity.sprite_texture = preload("res://assets/obstacle.png")
		#WorldManager.active_tilemap.add_child(entity)
		#
		#entity.add_to_group(C.TARGETS)
