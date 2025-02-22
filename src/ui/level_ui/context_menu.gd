extends Control
class_name ContextMenu

const CONTEXT_MENU_TSCN := preload("res://src/ui/level_ui/context_menu/context_menu.tscn")

@onready var frame = $Frame
@onready var frame_bar = $Frame/Bar
@onready var frame_line = $Frame/Line2D
@onready var ability_list_container = $AbilityList/VBoxContainer
@onready var name_container := $Name
@onready var name_label := $Name/Label
@onready var ability_list := $AbilityList/VBoxContainer
@onready var ability_bar := $Frame/Bar

func animate():
	var bar_y = frame_bar.size.y
	frame_bar.size.y = 0
	var tween = create_tween().set_parallel(true)
	tween.tween_property(frame_bar,'size',Vector2(frame_bar.size.x,bar_y),0.1)
	
	var item_position = ability_list_container.position
	var item_modulate = ability_list_container.modulate
	ability_list_container.position = item_position + Vector2(150,0)
	ability_list_container.modulate = Color(0,0,0,0)
	tween.tween_property(ability_list_container,'position',item_position,0.1)
	tween.tween_property(ability_list_container,'modulate',item_modulate,0.1)

func update_with_entity_abilities(host:Entity)->ContextMenu:
	for child in ability_list.get_children():
		child.queue_free()
		
	name_label.text = host.data.entity_name

	var ability_count = 0
	for ability in host.get_abilities():
		if ability.data.is_passive:
			continue
		ability_count+=1
		var ability_node = preload(ContextMenuAbility.CONTEXT_MENU_ABILITY_TSCN).instantiate()
		ability_list.add_child(ability_node)
		ability_node.label.text = ability.data.ability_name
		ability_node.ability = ability
		if ability.data.max_charges != 0:
			ability_node.charges.text = str(ability.data.charges)
		else:
			ability_node.charges.text = ""
		if !ability.is_usable():
			ability_node.bg.texture = preload("res://src/ui/level_ui/context_menu/context_menu_abilty_gradient_unusable.tres")
	ability_bar.scale = Vector2(1,1)
	ability_bar.size = Vector2(3,40 * SettingsManager.get_ui_game_resolution_multiplier().y)
	ability_bar.size += Vector2(0,70 * SettingsManager.get_ui_game_resolution_multiplier().y * (ability_count - 2))
	
	#name_container.position = Vector2(16,180)
	#name_container.position += Vector2(0,-72 * (ability_count - 2))

	return self
	
