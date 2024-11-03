extends Control
class_name UI

enum STATE{
	INACTIVE,
	SELECTING_TARGET
}

@onready var ability_container := $Action/AbilityContainer
@onready var undo_move := $UndoMove
@onready var end_turn := $EndTurn
@onready var debug_label := $Debug/Label
@onready var portrait_container := $Portrait
@onready var portrait := $Portrait/image
@onready var display_name := $Portrait/name
@onready var game_start_overlay := $Overlays/GameStart
@onready var victory_overlay := $Overlays/Victory

var state := STATE.INACTIVE
var context

signal end_turn_pressed
signal undo_move_pressed

func _ready() -> void:
	game_start_overlay.hide()
	victory_overlay.hide()
	
func generate_ability_icons(abilities:Array[Ability]):
	for child in ability_container.get_children():
		child.queue_free()
		
	for ability in abilities:
		if ability.has_ui:
			var control = Control.new()
			control.custom_minimum_size = Vector2(64,48)
			var clickable_sprite:ClickableSprite = load("res://src/components/ui/clickable_sprite/ClickableSprite.tscn").instantiate()
			clickable_sprite.texture = ability.texture
			clickable_sprite.connect("pressed",func():ability.target_select.emit())
			control.add_child(clickable_sprite)
			ability_container.add_child(control)


func show_ability_icons():
	ability_container.show()

func hide_ability_icons():
	ability_container.hide()

func set_context(_context:Entity):
	context = _context
	display_name.text = context.entity_name
	show_ability_icons()
	generate_ability_icons(context.get_abilities())
	portrait.texture = context.portrait_image
	show_portrait()
		
func clear_context():
	hide_portrait()
	hide_ability_icons()
	
func hide_portrait():
	portrait_container.hide()
func show_portrait():
	portrait_container.show()
	
func enable_undo_move_button():
	undo_move.disabled = false
	undo_move.modulate = Color.GREEN
	
func disable_undo_move_button():
	undo_move.disabled = true
	undo_move.modulate = Color(180,180,180)

func _on_end_turn_pressed() -> void:
	print("end turn pressed")
	end_turn_pressed.emit()


func _on_undo_move_pressed() -> void:
	undo_move_pressed.emit()
