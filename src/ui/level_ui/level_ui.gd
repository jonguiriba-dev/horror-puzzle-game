extends Control
class_name UI


enum STATE{
	INACTIVE,
	SELECTING_TARGET
}

@onready var ability_container := $Action/AbilityContainer
@onready var undo_move := $UndoMove
@onready var end_turn := $ActionContainer/Endturn
@onready var turn_order := $ActionContainer/TurnOrder
@onready var strategy_dropdown_button := $ActionContainer/StrategyDropDown
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
@onready var context_menu :ContextMenu= $ContextMenu
@onready var strategy_node := $StrategyMenu
@onready var strategy_container := $StrategyMenu/VBoxContainer
@onready var event_options := $EventOptions
var strategy_node_prev_pos #to prevent mouse event being taken unwantedly
@onready var menu_button := $MenuButton
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
	visible = true
	clear_context()
	
	overlays.clicked.connect(func():
		if overlays.is_visible_in_tree():
			overlay_clicked.emit()
	)
	clear_context()
	hide_strategies()
	
	for child in strategy_container.get_children():
		child.pressed.connect(_on_strategy_selected.bind(child.get_meta("strategy")))
	
	menu_button.pressed.connect(_on_menu_button_pressed)

func show_ability_icons():
	ability_container.show()

func hide_ability_icons():
	ability_container.hide()

func set_context(_context:Entity):
	context = _context
	show_context_menu(context)
		
func clear_context():
	context = null
	hide_portrait()
	hide_context_menu()
	hide_ability_icons()
	
func hide_portrait():
	portrait_container.hide()
	
func show_portrait():
	pass
	#portrait_container.show()


func show_context_menu(host:Entity):
	context_menu.update_with_entity_abilities(host)
	
	#context_menu.global_position = (host.global_position * 2) + Vector2(36,-240)
	print(">> ",SettingsManager.get_ui_game_resolution_multiplier())
	#context_menu.global_position = (
			#host.global_position * SettingsManager.get_ui_game_resolution_multiplier()
	#) + Vector2(50,-280) 
	
	context_menu.global_position = host.context_menu_point.global_position * SettingsManager.get_ui_game_resolution_multiplier()
	
	if SettingsManager.resolution_scale.x < 0.7:
		context_menu.scale = Vector2(0.7,0.7)
		
	context_menu.show()
	context_menu.animate()
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



func show_event_options(events):
		for child in event_options.get_children():
			child.queue_free()
		
		var event_option_list = []
		for event in events:
			var event_option : EventOption = load(C.SCENES.UI.LEVEL.EVENT_OPTION).instantiate()
			event_option.size_flags_horizontal = Control.SIZE_EXPAND + Control.SIZE_SHRINK_CENTER
			event_option.size_flags_vertical = Control.SIZE_EXPAND + Control.SIZE_SHRINK_CENTER
			event_options.add_child(event_option)
			event_option_list.push_front(event_option)
			event_option.set_rewards_list(event.rewards)
			event_option.location_name.text = event.name
			event_option.set_meta("event",event)
			event_option.pressed.connect(func():
				print("EVENT CLICKED ",event)
				for e_option in event_option_list:
					e_option.queue_free()
				WorldManager.level.load_handler.unload_units()
				await get_tree().process_frame
				SceneManager.change_scene(event.scene)
			, CONNECT_ONE_SHOT)
		return event_option_list
			#event_option.scale = SettingsManager.get_ui_game_resolution_multiplier()
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

func _on_menu_button_pressed() -> void:
	var menu_node = preload(Menu.MENU_TSCN).instantiate()
	menu_node = menu_node as Control
	add_child(menu_node)
	menu_node.global_position = DisplayServer.window_get_size()/2	

	
func _unhandled_input(event: InputEvent) -> void:
			
	if event.is_action_pressed("console"):
		if debug.visible:
			debug.hide()
		else:
			debug.show()
