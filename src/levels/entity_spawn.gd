extends Resource
class_name EntitySpawn

@export var entity_preset:EntityData
@export var max_number := 3
@export_range (0.1, 1.0) var spawn_rate := 1.0
