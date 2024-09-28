extends Ability

func _ready() -> void:
	ability_name = "strike"
	ability_range = 1
	damage = 1

func apply_effect(target):
	super(target)
	if target is Unit:
		target.hit.emit(damage)
	
	
