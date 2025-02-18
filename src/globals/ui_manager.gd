extends Node

enum UI_TYPE{
	LEVEL,
	MAP
}

var ui_container:Control
var level_ui: UI
var map_ui: MapUI
var ability_hovered:AbilityV2

var level_ui_node = preload("res://src/ui/level_ui/Ui.tscn")
var map_ui_node = preload("res://src/ui/map_ui/map_ui.tscn")

signal reward_card_selected(reward_card)

func info(text:String):
	if level_ui:
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

func registerUI(_ui:UI):
	level_ui = _ui
	level_ui.visible = true
	level_ui.clear_context()

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
		
	ui_container.add_child(ui_node)

func clear_ui():
	for child in ui_container.get_children():
		child.queue_free()
