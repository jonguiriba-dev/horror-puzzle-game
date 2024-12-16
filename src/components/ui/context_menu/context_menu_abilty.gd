extends Control

@onready var label := $Label
@onready var bg := $Bg
var ability:Ability


func _on_mouse_entered() -> void:
	bg.texture = preload("res://src/components/ui/context_menu/context_menu_abilty_gradient_active.tres")
	UIManager.ability_hovered = ability
	
func _on_mouse_exited() -> void:
	bg.texture = preload("res://src/components/ui/context_menu/context_menu_abilty_gradient_inactive.tres")
	UIManager.ability_hovered = null

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		if UIManager.ability_hovered:
			UIManager.ability_hovered.target_select.emit()
			UIManager.ability_hovered = null
			UIManager.ui.hide_context_menu()
