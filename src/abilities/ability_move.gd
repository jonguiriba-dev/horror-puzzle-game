extends Ability

func _ready() -> void:
	super()
	ability_name = "move"
	ability_range = 3

func apply_effect(target):
	super(target)
	if !is_instance_valid(target):
		return
	if target is Entity:
		target.hit.emit(damage)
	
func _on_ability_targetting(ability:Ability) -> void:
	host.highlight_attack_range_tiles(ability.ability_range)

func _on_ability_stopped_targetting(ability:Ability) -> void:
	WorldManager.grid.clear_all_highlights()
