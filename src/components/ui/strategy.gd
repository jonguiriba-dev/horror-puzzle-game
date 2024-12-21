extends Control

@onready var container := $VBoxContainer

func _ready() -> void:
	var strategies = C.STRATEGIES.values()
	
	for strategy in strategies:
		var node = preload("res://src/components/ui/SpriteButton.tscn").instantiate()
		container.add_child(node)
		node.button_label.text = C.STRATEGIES.keys()[strategy].to_pascal_case()	
		node.set_meta("strategy",strategy)
		
