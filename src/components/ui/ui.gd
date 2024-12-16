extends Control
class_name UI

enum STATE{
	INACTIVE,
	SELECTING_TARGET
}

@onready var ability_container := $Action/AbilityContainer
@onready var undo_move := $UndoMove
@onready var end_turn := $EndTurn
@onready var turn_order := $TurnOrder
@onready var debug_label := $Debug/Label
@onready var portrait_container := $Portrait
@onready var portrait := $Portrait/image
@onready var display_name := $Portrait/name
@onready var game_start_overlay := $Overlays/GameStart
@onready var victory_overlay := $Overlays/Victory
@onready var turn_start_overlay := $Overlays/TurnStart
@onready var turn_start_overlay_background := $Overlays/TurnStart/Background
@onready var turn_start_overlay_label := $Overlays/TurnStart/Label
@onready var overlays := $Overlays
@onready var context_menu := $ContextMenu
@onready var context_menu_name_container := $ContextMenu/Name
@onready var context_menu_name := $ContextMenu/Name/Label
@onready var context_menu_ability_list := $ContextMenu/AbilityList/VBoxContainer
@onready var context_menu_ability_bar := $ContextMenu/Frame/Bar

var state := STATE.INACTIVE
var context

signal end_turn_pressed
signal undo_move_pressed
signal turn_order_pressed

func _ready() -> void:
	game_start_overlay.hide()
	victory_overlay.hide()
	overlays.visible = true
	clear_context()
	UIManager.registerUI(self)
	
func generate_ability_icons(abilities:Array[Ability]):
	for child in ability_container.get_children():
		var conns = child.get_signal_connection_list("pressed")
		for conn in conns:
			child.pressed.disconnect(conn["callable"])
		for child2 in child.get_children():
			child2.queue_free()
	
	var i = 1
	for ability in abilities:
		if ability.has_ui:
			var clickable_sprite:ClickableSprite = load("res://src/components/ui/clickable_sprite/ClickableSprite.tscn").instantiate()
			clickable_sprite.texture = ability.texture
			clickable_sprite.connect("pressed",func():ability.target_select.emit())
			ability_container.get_node("AbilityFrame%s"%[i]).add_child(clickable_sprite)
			i+=1


func show_ability_icons():
	ability_container.show()

func hide_ability_icons():
	ability_container.hide()

func set_context(_context:Entity):
	context = _context
	show_context_menu(context)
	#display_name.text = context.entity_name
	#show_ability_icons()
	#generate_ability_icons(context.get_abilities())
	#portrait.texture = context.portrait_image
	#show_portrait()
		
func clear_context():
	hide_portrait()
	hide_context_menu()
	hide_ability_icons()
	
func hide_portrait():
	portrait_container.hide()
func show_portrait():
	pass
	#portrait_container.show()

func show_context_menu(host:Entity):
	context_menu_name.text = host.entity_name
	for child in context_menu_ability_list.get_children():
		child.queue_free()
	
	var ability_count = 0
	for ability in host.get_abilities():
		if ability.ability_name == "move":
			continue
		ability_count+=1
		var ability_node = preload("res://src/components/ui/context_menu/context_menu_abilty.tscn").instantiate()
		context_menu_ability_list.add_child(ability_node)
		ability_node.label.text = ability.ability_name
		ability_node.ability = ability
	
	context_menu.global_position = (host.global_position * 2) + Vector2(52,-230)
	context_menu_ability_bar.size = Vector2(3,100)
	context_menu_ability_bar.size += Vector2(0,70 * (ability_count - 1))
	context_menu_name_container.position = Vector2(16,180)
	context_menu_name_container.position += Vector2(0,-70 * (ability_count - 1))
	context_menu.show()

func hide_context_menu():
	context_menu.hide()

func move_context_menu(entity_global_position:Vector2):
	context_menu.global_position = (entity_global_position * 2) + Vector2(52,-230) 

func enable_undo_move_button():
	undo_move.disabled = false
	undo_move.modulate = Color.GREEN

func present_turn_start_overlay(team:String):
	turn_start_overlay_label.text = team + " Start".to_upper()
	turn_start_overlay.show()
	turn_start_overlay.modulate.a = 0
	var _modulate = turn_start_overlay.modulate
	var tween = create_tween()
	tween.tween_property(turn_start_overlay,'modulate',Color(_modulate.r,_modulate.g,_modulate.b,1),0.15)
	await Util.wait(0.5)
	var tween2 = create_tween()
	tween2.tween_property(turn_start_overlay,'modulate',Color(_modulate.r,_modulate.g,_modulate.b,0),0.3)
	await Util.wait(0.3)
	turn_start_overlay.hide()
	
func disable_undo_move_button():
	undo_move.disabled = true
	undo_move.modulate = Color(180,180,180)

func _on_end_turn_pressed() -> void:
	end_turn_pressed.emit()

func _on_turn_order_pressed() -> void:
	turn_order_pressed.emit()
		
func _on_undo_move_pressed() -> void:
	undo_move_pressed.emit()
