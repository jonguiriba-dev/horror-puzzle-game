extends Entity
class_name Unit

func _ready() -> void:
	super()
	add_to_group(C.GROUPS_UNITS)
