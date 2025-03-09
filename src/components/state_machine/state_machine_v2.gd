extends Resource
class_name StateMachineV2

# state scripts
@export var prepared_states:Array[GDScript] = []
var state = null
var previous_state = null
var is_enabled := true

#@onready var host := get_parent()
var host
signal state_changed(state_id:String)

var state_map = {}

func setup(host):
	self.host = host

	if !WorldManager.get("level"):
		Util.sysprint("StateMachine","No level found for WorldManager disabling StateMachine")
		return
		
	for prepared_state in prepared_states:
		var state = prepared_state.new()
		state.setup(host)
		state_map[state.state_id] = state
	
	set_state(state_map.values()[0])

func _unhandled_input(event: InputEvent) -> void:
	if state != null:
		state._on_unhandled_input(event)

func tick(delta):
	if !is_enabled:
		return
	
	if state != null:
		process(state,delta)
		_update_sprite()
		var next_state_id = _transition()
		if next_state_id != null:
			set_state(state_map[next_state_id])
			
func process(curr_state, delta):
	_state_logic(delta)

func _state_logic(delta):
	state._state_logic(delta)


func _exit_state(old_state, new_state):
	state._exit_state(old_state, new_state)
	state.events_active = false


func _enter_state(old_state, new_state):
	state._enter_state(old_state, new_state)
	state.events_active = true

func _update_sprite():
	state._update_sprite()

func _transition():
	var next_state = state._transition()
	return next_state

func get_state():
	return state

func set_state(new_state):
	previous_state = state

	if previous_state != null and previous_state != new_state:
		_exit_state(previous_state, new_state)

	state = new_state
	if new_state != null:
		state_changed.emit(new_state)
		_enter_state(previous_state, new_state )
	#
#func add_state(_state: StateV2):
	#_state.host = host
	##states[_state.state_id] = _state
	#_state.configured.emit()
