extends Resource
class_name Modifier

enum MODES{
	ADD,
	SUB
}

@export var mode := MODES.ADD
@export var target_property := ""
@export var value := 0
@export_file() var ability_data
