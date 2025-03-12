extends Control

@onready var current := $Current
@onready var max := $Max

func set_current(value:int):
	current.text = str(value)

func set_max(value:int):
	max.text = str(value)
