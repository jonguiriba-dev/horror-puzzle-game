extends Control

signal clicked
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		clicked.emit()
