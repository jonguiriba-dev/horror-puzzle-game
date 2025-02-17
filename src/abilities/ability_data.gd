extends Resource
class_name AbilityData

enum TARGET_STRATEGIES{
	DEFAULT,
	NAVIGATION
}

@export var ability_name := "ability_name"
@export var ability_range := 0
@export var effects:Array[AbilityEffect]
@export var highlight_color := Grid.HIGHLIGHT_COLORS.GREEN
@export var is_enemy_obstacle := false
@export var target_count := 1
@export var use_host_as_origin := false
@export var max_charges:=0
@export var action_cost:=1
@export var range_pattern:TilePattern.PATTERNS = TilePattern.PATTERNS.DIAMOND
@export var aoe_pattern:TilePattern.PATTERNS = TilePattern.PATTERNS.POINT
@export var tile_exclude_flag:Grid.TILE_EXCLUDE_FLAGS=Grid.TILE_EXCLUDE_FLAGS.EXCLUDE_OBSTACLES_ALLIES
@export var tile_exclude_self:=false
@export var is_action:=true
@export var description:="ability description"
@export var target_strategy := TARGET_STRATEGIES.DEFAULT
@export var is_passive := false
@export_file("*gd") var animation_script
@export_file("*gd") var custom_ability_script
var charges:=0
