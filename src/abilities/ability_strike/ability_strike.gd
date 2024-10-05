extends Ability

func _ready() -> void:
	ability_name = "strike"
	ability_range = 1
	damage = 1

	connect("targetting",_on_ability_targetting)
	connect("stopped_targetting",_on_ability_stopped_targetting)
	
func apply_effect(target):
	super(target)
	if !is_instance_valid(target):
		return
	if target is Entity:
		target.hit.emit(damage)
	
func _on_ability_targetting(ability:Ability) -> void:
	host.highlight_attack_range_tiles(ability.ability_range)
	host.state = Unit.STATE.TARGETTING

func _on_ability_stopped_targetting(ability:Ability) -> void:
	WorldManager.grid.clear_all_highlights()
	host.state = Unit.STATE.SELECTED
