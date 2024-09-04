extends CharacterBody2D

@onready var navigation_agent := $NavigationAgent2D

var move_speed = 55
var can_move := false
func _unhandled_input(event: InputEvent) -> void:
	if(event.is_action_pressed("action2")):
		can_move = !can_move
		print("can_move",can_move)
		
func _physics_process(delta: float) -> void:
	#if(can_move):
	navigation_agent.target_position = get_global_mouse_position()
	var current_agent_pos = global_position
	var next_path_pos = navigation_agent.get_next_path_position()
	var new_velocity = current_agent_pos.direction_to(next_path_pos) * move_speed
	
	navigation_agent.set_velocity(new_velocity)

	move_and_slide()


func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	#velocity = safe_velocity
	pass
