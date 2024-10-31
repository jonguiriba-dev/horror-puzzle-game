
extends Node
var ui: UI
signal initialized


func initialize():
	ui = preload("res://src/components/ui/Ui.tscn").instantiate()
	get_tree().get_current_scene().add_child(ui)
	initialized.emit()
	
func info(text:String):
	if ui:
		ui.debug_label.text = text

func play_game_start_sequence():
	ui.game_start_overlay.show()
	await Util.wait(2)
	ui.game_start_overlay.hide()

func show_victory_overlay():
	ui.victory_overlay.show()
