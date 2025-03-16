extends Control

@onready var current := $Current
@onready var max_value := $Max

func set_current(value:int):
	current.text = str(value)

func set_max(value:int):
	max_value.text = str(value)
