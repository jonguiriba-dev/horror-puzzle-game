extends Node
class_name Status


enum STATUS_TYPES{
	NONE,
	HASTE,
	STUN
}

const STATUS_DATA := {
	STATUS_TYPES.HASTE:"res://src/components/objects/status/haste/haste.tres",
	STATUS_TYPES.STUN:"res://src/components/objects/status/stun/stun.tres"
}

var status_data: StatusData
var duration:int = 0
var host:Entity
var status_icon_tscn = preload("res://src/components/objects/status/StatusIcon.tscn")
signal status_finished(status:Status)
var icon 

func _init(_status_data:StatusData, _duration:int):
	status_data = _status_data
	duration = _duration

func register_entity(_host:Entity):
	host = _host
	host.turn_start.connect(_on_host_turn_start)
	apply_modifiers()
	icon = status_icon_tscn.instantiate()
	host.status_bar.add_child(icon)
	icon.duration.text = str(duration)
	icon.sprite.sprite_frames = status_data.icon
	
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
	for modifier in status_data.modifiers:
		var value = host.data.get(modifier.target)
		if value != null:
			if modifier.mode == Modifier.MODES.ADD: 
				host.data.set(modifier.target,value + modifier.value)
			elif modifier.mode == Modifier.MODES.SUB: 
				host.data.set(modifier.target,value - modifier.value)
		
		if status_data.status_name == "Stun":
			host.stun.emit()
			
func remove_modifiers():
	for modifier in status_data.modifiers:
		var value = host.data.get(modifier.target)
		if value != null:
			if modifier.mode == Modifier.MODES.ADD: 
				host.data.set(modifier.target,value - modifier.value)
			elif modifier.mode == Modifier.MODES.SUB: 
				host.data.set(modifier.target,value + modifier.value)
	
func _on_host_turn_start():
	tick()
