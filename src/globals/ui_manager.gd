
extends Node

enum UI_TYPE{
	LEVEL,
	MAP
}

var ui_container
var ui: UI
var ability_hovered:AbilityV2

var level_ui = preload("res://src/ui/level_ui/Ui.tscn").instantiate()
var map_ui

signal reward_card_selected(reward_card)

func info(text:String):
	if ui:
		ui.debug_label.text = text

func play_game_start_sequence():
	ui.game_start_overlay.show()
	await Util.wait(2)
	ui.game_start_overlay.hide()

func show_victory_overlay():
	ui.victory_overlay.show()
	ui.overlays.show()
	
func hide_victory_overlay():
	ui.victory_overlay.hide()
	ui.overlays.hide()

func show_reward_overlay(ability_props:Array[AbilityProp]):
	ui.show_reward_overlay(ability_props)
	ui.overlays.show()
	ui.reward_card_selected.connect(
		func(e):
			print("almsot there ",e)
			reward_card_selected.emit(e),
		CONNECT_ONE_SHOT
	)
	
func hide_reward_overlay():
	ui.hide_reward_overlay()
	ui.overlays.hide()

func registerUI(_ui:UI):
	ui = _ui
	ui.visible = true
	ui.clear_context()

func set_ui(ui_type:UI_TYPE):
	if !ui_container:
		return
	
	if ui_container.get_child_count() > 0:
		#ui_container.get_children()[0].queue_free()
		ui_container.remove_child(ui_container.get_children()[0])
		
	var ui_node
	match ui_type:
		UI_TYPE.LEVEL: ui_node = level_ui
		UI_TYPE.MAP: ui_node = map_ui
	
	ui_container.add_child(ui_node)
	ui = ui_node
	return ui

func clear_ui():
	if ui_container.get_child_count() > 0:
		ui_container.remove_child(ui_container.get_children()[0])
	
