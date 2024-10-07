extends Sprite2D
class_name ClickableSprite

signal pressed

func _on_button_pressed() -> void:
	pressed.emit()
