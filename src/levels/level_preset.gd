extends Resource
class_name LevelPreset

@export var orientation:=C.ORIENTATION.HORIZONTAL
@export var spawn_config: LevelSpawnConfig
@export var rewards_config: LevelRewardsConfig
@export_file() var tilemap_node
