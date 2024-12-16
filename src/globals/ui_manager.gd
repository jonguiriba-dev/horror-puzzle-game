
extends Node
var ui: UI
var ability_hovered:Ability

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
