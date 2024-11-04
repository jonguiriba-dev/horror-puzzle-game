extends Node2D

@onready var text_element = $Text

func set_text(_text:String):
	text_element.text = _text
