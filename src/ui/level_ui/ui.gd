extends Control
class_name UI

enum STATE{
	INACTIVE,
	SELECTING_TARGET
}

@onready var ability_container := $Action/AbilityContainer
@onready var undo_move := $UndoMove
@onready var end_turn := $Endturn
@onready var turn_order := $TurnOrder
@onready var debug := $Debug
@onready var debug_label := $Debug/Label
@onready var portrait_container := $Portrait
@onready var portrait := $Portrait/image
@onready var display_name := $Portrait/name
@onready var game_start_overlay := $Overlays/GameStart
@onready var victory_overlay := $Overlays/Victory
@onready var turn_start_overlay := $Overlays/TurnStart
@onready var reward_overlay :RewardOverlay= $Overlays/RewardOverlay
@onready var turn_start_overlay_background := $Overlays/TurnStart/Background
@onready var turn_start_overlay_label := $Overlays/TurnStart/Label
@onready var overlays := $Overlays
@onready var context_menu := $ContextMenu
@onready var context_menu_name_container := $ContextMenu/Name
@onready var context_menu_name := $ContextMenu/Name/Label
@onready var context_menu_ability_list := $ContextMenu/AbilityList/VBoxContainer
@onready var context_menu_ability_bar := $ContextMenu/Frame/Bar
@onready var strategy_node := $StrategyMenu
@onready var strategy_container := $StrategyMenu/VBoxContainer
var strategy_node_prev_pos #to prevent mouse event being taken unwantedly
@onready var strategy_dropdown_button := $StrategyDropDown
var state := STATE.INACTIVE
var context

signal end_turn_pressed
signal undo_move_pressed
signal turn_order_pressed
signal strategy_changed
signal overlay_clicked
signal reward_card_selected(reward_card)

func _ready() -> void:
	game_start_overlay.hide()
	victory_overlay.hide()
	reward_overlay.hide()
	overlays.hide()
	overlays.clicked.connect(func():
		if overlays.is_visible_in_tree():
			overlay_clicked.emit()
	)
	clear_context()
	hide_strategies()
	
	for child in strategy_container.get_children():
		child.pressed.connect(_on_strategy_selected.bind(child.get_meta("strategy")))
	
	UIManager.registerUI(self)
	
func show_ability_icons():
	ability_container.show()

func hide_ability_icons():
	ability_container.hide()

func set_context(_context:Entity):
	context = _context
	show_context_menu(context)
		
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
	context_menu_name.text = host.data.entity_name
	for child in context_menu_ability_list.get_children():
		child.queue_free()
	
	var ability_count = 0
	for ability in host.get_abilities():
		if ability.data.ability_name == "move":
			continue
		ability_count+=1
		var ability_node = preload("res://src/ui/level_ui/context_menu/context_menu_abilty.tscn").instantiate()
		context_menu_ability_list.add_child(ability_node)
		ability_node.label.text = ability.data.ability_name
		ability_node.ability = ability
		if ability.data.max_charges != 0:
			ability_node.charges.text = str(ability.data.charges)
		else:
			ability_node.charges.text = ""
		if !ability.is_usable():
			ability_node.bg.texture = preload("res://src/ui/level_ui/context_menu/context_menu_abilty_gradient_unusable.tres")

	context_menu.global_position = (host.global_position * 2) + Vector2(36,-240)
	context_menu_ability_bar.size = Vector2(3,100)
	context_menu_ability_bar.size += Vector2(0,70 * (ability_count - 1))
	context_menu_name_container.position = Vector2(16,180)
	context_menu_name_container.position += Vector2(0,-72 * (ability_count - 1))
	context_menu.animate()
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
	tween.tween_property(turn_start_overlay,'modulate',Color(_modulate.r,_modulate.g,_modulate.b,1),0.5)
	await Util.wait(1)
	var tween2 = create_tween()
	tween2.tween_property(turn_start_overlay,'modulate',Color(_modulate.r,_modulate.g,_modulate.b,0),0.3)
	await Util.wait(0.3)
	turn_start_overlay.hide()
	
func disable_undo_move_button():
	undo_move.disabled = true
	undo_move.modulate = Color(180,180,180)

var is_strategies_showing := false

func hide_strategies():
	#for child in strategy_container.get_children():
		#if child == strategy_dropdown_button:
			#continue	
		#child.hide()
	strategy_node_prev_pos = strategy_node.position
	strategy_node.position = Vector2(2000,2000)
	strategy_node.hide()
	is_strategies_showing = false
	
func show_strategies():
	#for child in strategy_container.get_children():
		#child.show()
	strategy_node.show()
	strategy_node.position = strategy_node_prev_pos
	is_strategies_showing = true

#limit to 3
func show_reward_overlay(ability_presets:Array[AbilityData]):
	reward_overlay.populate_with_abilities(ability_presets)
	reward_overlay.show()
	reward_overlay.selected_card.connect(
		func(e):
			print("SELECTED CARD",e)
			reward_card_selected.emit(e),
		CONNECT_ONE_SHOT
	)
func hide_reward_overlay():
	reward_overlay.hide()
	
func _on_strategy_selected(strategy:C.STRATEGIES):
	if strategy != WorldManager.level.strategy:
		strategy_changed.emit()
		
	WorldManager.level.strategy = strategy
	strategy_dropdown_button.button_label.text = C.STRATEGIES.keys()[WorldManager.level.strategy].to_pascal_case()
	hide_strategies()
		
func _on_strategy_drop_down_pressed():
	if !is_strategies_showing:
		show_strategies()
	else:
		hide_strategies()
func _on_end_turn_pressed() -> void:
	Util.sysprint("UI.end_turn","pressed")
	end_turn_pressed.emit()

func _on_turn_order_pressed() -> void:
	turn_order_pressed.emit()
		
func _on_undo_move_pressed() -> void:
	undo_move_pressed.emit()
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("console"):
		if debug.visible:
			debug.hide()
		else:
			debug.show()
