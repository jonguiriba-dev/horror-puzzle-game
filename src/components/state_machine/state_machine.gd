extends Node
class_name StateMachine


var state = null
var previous_state = null
var states = {}
var is_enabled := true

@onready var host := get_parent()

signal state_changed(state_id:String)

func _ready() -> void:
	host.ready.connect(_on_host_ready)

func _on_host_ready():
	for child in get_children():
		add_state(child)
		if state == null:
			set_state(child.state_id)

func _unhandled_input(event: InputEvent) -> void:
	if state != null:
		states[state]._on_unhandled_input(event)

func _physics_process(delta):
	if !is_enabled:
		return
	
	if state != null:
		process(state,delta)
		_update_sprite()
		var transition = _transition()
		
		if transition != null:
			print("SETTING STATE ",transition)
			set_state(transition)
			
func process(curr_state, delta):
	if curr_state != null and states[curr_state] is State:
		_state_logic(delta)
		var parent_state = states[state].get_parent()
		if parent_state is State:
			process(parent_state, delta)
			

func _state_logic(delta):
	states[state]._state_logic(delta)


func _exit_state(old_state, new_state):
	states[state]._exit_state(old_state, new_state)


func _enter_state(old_state, new_state):
	states[state]._enter_state(old_state, new_state )

func _update_sprite():
	states[state]._update_sprite()

func _transition():
	var next_state = states[state]._transition()
	
	return next_state

func get_state():
	return states[state]

func set_state(new_state):
	previous_state = state

	if previous_state != null and previous_state != new_state:
		_exit_state(previous_state, new_state)

	state = new_state
	if new_state != null:
		state_changed.emit(new_state)
		_enter_state(previous_state, new_state )
	
func add_state(state: State):
	state.host = host
	states[state.state_id] = state
	state.configured.emit()
	#host.ready.connect(state._on_host_ready)
