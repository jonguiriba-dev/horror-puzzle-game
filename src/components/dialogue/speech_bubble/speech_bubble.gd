extends Node2D

@onready var text_element = $PositionNode/Text
@onready var flashing_prompt = $PositionNode/FlashingPrompt

func _ready() -> void:
	flashing_prompt.play("default")

func set_text(_text:String):
	text_element.text = _text
	
