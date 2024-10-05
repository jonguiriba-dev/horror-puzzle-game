extends Control
class_name UI

enum STATE{
	INACTIVE,
	SELECTING_TARGET
}

@onready var ability_container = $AbilityContainer

var state := STATE.INACTIVE
var context

signal end_turn_pressed

func generate_ability_icons(abilities:Array[Ability]):
	for child in ability_container.get_children():
		child.queue_free()
		
	for ability in abilities:
		var control = Control.new()
		control.custom_minimum_size = Vector2(64,48)
		var clickable_sprite:ClickableSprite = load("res://src/screens/ui/clickable_sprite/ClickableSprite.tscn").instantiate()
		clickable_sprite.texture = ability.texture
		clickable_sprite.connect("pressed",ability.set_target)
		control.add_child(clickable_sprite)
		ability_container.add_child(control)
		

func show_ability_icons():
	ability_container.show()

func hide_ability_icons():
	ability_container.hide()


func set_context(ctx):
	context = ctx
	if context is Unit:
		show_ability_icons()
		generate_ability_icons(context.get_abilities())


func _on_end_turn_pressed() -> void:
	end_turn_pressed.emit()
	pass # Replace with function body.
