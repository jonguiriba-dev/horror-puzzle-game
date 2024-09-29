
extends Node
var ui: UI
signal initialized

func initialize():
	ui = preload("res://src/screens/ui/Ui.tscn").instantiate()
	get_tree().get_current_scene().add_child(ui)
	initialized.emit()
	
