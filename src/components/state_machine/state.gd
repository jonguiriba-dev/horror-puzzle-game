extends Node
class_name State

signal configured
signal entered
signal exited

var host
var state_id :C.STATE
var events_active = false

@onready var _SM:StateMachine = get_parent()
func _init():
	pass

func _ready() -> void:
	configured.connect(_on_configured)

func set_state(_state_id):
	_SM.set_state(_state_id)

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
