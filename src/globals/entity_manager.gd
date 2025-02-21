extends Node


const entity_tscn := preload("res://src/entities/entity/Entity.tscn")
#const PRESET_ELYANA := preload("res://src/entities/entity/presets/main_characters/elyana/elyana_preset.tres")
#const PRESET_LAYLA := preload("res://src/entities/entity/presets/main_characters/layla/layla_preset.tres")
#const PRESET_TALYA := preload("res://src/entities/entity/presets/main_characters/talya/talya_preset.tres")
#const PRESET_KNIGHT = preload("res://src/entities/entity/presets/allies/knight/knight_preset.tres")



enum ENTITY_TYPES{
	DARK_ORB
}

func spawn_entity(position:Vector2,entity:Entity):
	entity.position = position
	WorldManager.level.grid.add_child_entity(entity)

#returns a newly instantiated Entity
func create_entity(entity_preset:EntityData):
	var entity = entity_tscn.instantiate()
	entity_preset.apply_as_preset(entity)

	return entity
