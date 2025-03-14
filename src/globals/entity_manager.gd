extends Node


const entity_tscn := preload("res://src/entities/entity/Entity.tscn")
const PRESET_ELYANA := "res://src/entities/entity/presets/main_characters/elyana/elyana_preset.tres"
const PRESET_LAYLA := "res://src/entities/entity/presets/main_characters/layla/layla_preset.tres"
const PRESET_TALYA := "res://src/entities/entity/presets/main_characters/talya/talya_preset.tres"
#const PRESET_KNIGHT = "res://src/entities/entity/presets/allies/knight/knight_preset.tres"



enum ENTITY_TYPES{
	NONE,
	DARK_ORB,
	BOMB
}

const ENTITY_PRESETS := {
	ENTITY_TYPES.BOMB:"res://src/entities/entity/presets/prop_entities/bomb/bomb_preset.tres"
}
func spawn_entity(position:Vector2,entity:Entity):
	entity.position = position
	WorldManager.level.grid.add_child_entity(entity)
	
#returns a newly instantiated Entity
func create_entity(entity_preset:EntityData):
	var entity = entity_tscn.instantiate()
	entity_preset.apply_as_preset(entity)

	return entity
