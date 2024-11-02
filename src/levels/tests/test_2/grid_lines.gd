extends Node2D

var can_draw = false
func _ready() -> void:
	draw.connect(draw_grid_lines)
	
func draw_grid_lines() -> void:
	print("drawing")
	var rect = WorldManager.grid.tiles_layer.get_used_rect()
	print('rect',rect)
	#draw_multiline([Vector2i(0,0),Vector2i(100,100)],Color.AQUA)
	draw_multiline([Vector2i(0,0),Vector2i(0,32)],Color.AQUA)
	draw_multiline([Vector2i(0,32),Vector2i(32,32)],Color.AQUA)
	
