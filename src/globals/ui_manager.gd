extends Node

enum UI_TYPE{
	LEVEL,
	MAP
}

var ui_container:Control
var ability_hovered:Ability
var view_port:SubViewport
var view_port_container:SubViewportContainer
var resolution_scale := Vector2(1,1)


var level_ui_node = preload("res://src/ui/level_ui/LevelUi.tscn")
var map_ui_node = preload("res://src/ui/map_ui/MapUi.tscn")
var level_ui: UI
var map_ui: MapUI
var current_ui: Control

signal reward_card_selected(reward_card)


func info(text:String):
	if is_instance_valid(level_ui):
		level_ui.debug_label.text = text

func play_game_start_sequence():
	level_ui.game_start_overlay.show()
	await Util.wait(2)
	level_ui.game_start_overlay.hide()

func show_victory_overlay():
	level_ui.victory_overlay.show()
	level_ui.overlays.show()
	
func hide_victory_overlay():
	level_ui.victory_overlay.hide()
	level_ui.overlays.hide()

func show_reward_overlay(ability_presets:Array[AbilityData]):
	level_ui.show_reward_overlay(ability_presets)
	level_ui.overlays.show()
	level_ui.reward_card_selected.connect(
		func(e):
			print("almsot there ",e)
			reward_card_selected.emit(e),
		CONNECT_ONE_SHOT
	)
	
func hide_reward_overlay():
	level_ui.hide_reward_overlay()
	level_ui.overlays.hide()



func set_ui(ui_type:UI_TYPE):
	if !ui_container:
		return
		
	await clear_ui()

	var ui_node
	match ui_type:
		UI_TYPE.LEVEL: 
			ui_node = level_ui_node.instantiate()
			level_ui = ui_node
			map_ui = null
		UI_TYPE.MAP: 
			ui_node = map_ui_node.instantiate()
			map_ui = ui_node
			level_ui = null
	
	current_ui = ui_node
	ui_container.add_child(ui_node)
	
	call_deferred("set_resolution",
		SettingsManager.current_resolution,
		SettingsManager.resolution_scale
	)
func clear_ui():
	for child in ui_container.get_children():
		child.queue_free()

func show_menu():
	var menu_node = preload(Menu.MENU_TSCN).instantiate()
	menu_node = menu_node as Control
	ui_container.add_child(menu_node)
	menu_node.global_position = DisplayServer.window_get_size()/2	

func set_resolution(resolution:Vector2,scale:Vector2):
	if current_ui:
		Util.sysprint("UIManager","set resolution:(%s,%s), scale:(%s,%s), %s"%
			[resolution.x, resolution.y, scale.x, scale.y, current_ui.name]
		)
		current_ui.scale = scale
	view_port_container.set_deferred("size",resolution)
