extends Control
class_name ContextMenuAbility

@onready var bg := $Bg
@onready var label := $HBoxContainer/AbilityName
@onready var charges := $HBoxContainer/Control/Charges
var ability:Ability
	
func _on_mouse_entered() -> void:
	if ability.is_usable():
		bg.texture = preload("res://src/ui/level_ui/context_menu/context_menu_abilty_gradient_active.tres")
		UIManager.ability_hovered = ability
	
func _on_mouse_exited() -> void:
	if ability.is_usable():
		bg.texture = preload("res://src/ui/level_ui/context_menu/context_menu_abilty_gradient_inactive.tres")
		UIManager.ability_hovered = null

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		if UIManager.ability_hovered and ability.is_usable():
			var targetting_ability := get_tree().get_first_node_in_group(C.GROUPS_TARGETTING_ABILITY) as Ability
			if targetting_ability:
				targetting_ability.stopped_targetting.emit()
			UIManager.ability_hovered.target_select.emit()
			UIManager.ability_hovered = null
			UIManager.ui.hide_context_menu()