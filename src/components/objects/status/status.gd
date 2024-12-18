extends Node
class_name Status

var status_props: StatusProps
var duration:int = 0
var host:Entity
var status_icon_tscn = preload("res://src/components/objects/status/StatusIcon.tscn")
signal status_finished(status:Status)
var icon 

func _init(_status_props:StatusProps, _duration:int):
	status_props = _status_props
	duration = _duration

func register_entity(_host:Entity):
	host = _host
	host.turn_start.connect(_on_host_turn_start)
	apply_modifiers()
	icon = status_icon_tscn.instantiate()
	host.status_bar.add_child(icon)
	icon.duration.text = str(duration)
	icon.sprite.sprite_frames = status_props.icon
	
func tick():
	duration -= 1
	if duration <= 0:
		status_finished.emit(self)
		remove_modifiers()
		icon.queue_free()
		queue_free()
	if icon:
		icon.duration.text = str(duration)
		if duration == 0:
			icon.duration.text = ""
			
func apply_modifiers():
	for modifier in status_props.modifiers:
		var value = host.get(modifier.target)
		if value:
			if modifier.mode == "add": 
				host.set(modifier.target,value + modifier.value)
	
func remove_modifiers():
	for modifier in status_props.modifiers:
		var value = host.get(modifier.target)
		if value:
			if modifier.mode == "add": 
				host.set(modifier.target,value - modifier.value)
	
func _on_host_turn_start():
	tick()
