extends Object
class_name StateV2

signal configured
signal entered
signal exited

var host
var state_id := ""
var events_active = false


func setup(host):
	self.host = host

func _state_logic(delta):
	pass
func _on_unhandled_input(event: InputEvent) -> void:
	pass
func _transition():
	pass
func _enter_state(old_state, new_state):
	pass
func _exit_state(old_state, new_state):
	pass
func _update_sprite():
	pass
func _on_configured():
	pass
