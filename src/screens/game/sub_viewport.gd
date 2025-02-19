extends SubViewport

func _ready() -> void:
	handle_input_locally = true
	UIManager.view_port = self
