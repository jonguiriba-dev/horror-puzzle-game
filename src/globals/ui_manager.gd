
extends Node

enum UI_TYPE{
	LEVEL
}

var ui_container
var ui: UI
var ability_hovered:Ability

var level_ui = preload("res://src/ui/level_ui/Ui.tscn").instantiate()

func info(text:String):
	if ui:
		ui.debug_label.text = text

func play_game_start_sequence():
	ui.game_start_overlay.show()
	await Util.wait(2)
	ui.game_start_overlay.hide()

func show_victory_overlay():
	ui.victory_overlay.show()

func registerUI(_ui:UI):
	ui = _ui
	ui.visible = true
	ui.clear_context()

func set_ui(ui_type:UI_TYPE):
	if !ui_container:
		return
	
	if ui_container.get_child_count() > 0:
		ui_container.get_children()[0].queue_free()
		
	var ui_node
	match ui_type:
		UI_TYPE.LEVEL: ui_node = level_ui
	
	ui_container.add_child(ui_node)
	ui = ui_node
	return ui
	
