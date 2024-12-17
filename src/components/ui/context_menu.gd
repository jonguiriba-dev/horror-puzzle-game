extends Control

@onready var frame = $Frame
@onready var frame_bar = $Frame/Bar
@onready var frame_line = $Frame/Line2D
@onready var ability_list_container = $AbilityList/VBoxContainer

func animate():
	var bar_y = frame_bar.size.y
	frame_bar.size.y = 0
	var tween = create_tween().set_parallel(true)
	tween.tween_property(frame_bar,'size',Vector2(frame_bar.size.x,bar_y),0.1)
	
	var item_position = ability_list_container.position
	var item_modulate = ability_list_container.modulate
	ability_list_container.position = item_position + Vector2(150,0)
	ability_list_container.modulate = Color(0,0,0,0)
	tween.tween_property(ability_list_container,'position',item_position,0.1)
	tween.tween_property(ability_list_container,'modulate',item_modulate,0.1)
