extends Resource
class_name AbilityPreset

@export var ability_name := "ability_name"
@export var ability_range := 0
@export var state := Ability.STATE.INACTIVE
@export var actions:Array[AbilityAction]
@export var highlight_color := Color.ORANGE
@export var is_enemy_obstacle := false
@export var target_count := 1
#@export var knockback_distance := 0
@export var use_host_as_origin := false
@export var charges:=-1
@export var action_cost:=1
@export var range_pattern:TilePattern.PATTERNS = TilePattern.PATTERNS.DIAMOND
@export var aoe_pattern:TilePattern.PATTERNS = TilePattern.PATTERNS.POINT

#func load_preset(_preset:AbilityPreset):
	#ability_name = _preset.ability_name
	#ability_range = _preset.ability_range
	##damage = _preset.damage
	#state = _preset.state
	#actions = _preset.actions
	##has_ui = _preset.has_ui
	#highlight_color = _preset.highlight_color
	#is_enemy_obstacle = _preset.is_enemy_obstacle
	#target_count = _preset.target_count
	##knockback_distance = _preset.knockback_distance
	#range_pattern = _preset.range_pattern
	#aoe_pattern = _preset.aoe_pattern
	#use_host_as_origin = _preset.use_host_as_origin
	#charges = _preset.charges
	#action_cost = _preset.action_cost
