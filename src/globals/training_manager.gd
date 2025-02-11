extends Node


func train_health(instructor:Entity, entity:Entity)->bool:
	entity.max_health += 1
	return true

func train_experience(instructor:Entity, entity:Entity)->bool:
	entity.exp += 2
	return true

func train_ability(instructor:Entity, student:Entity)->bool:
	var rng = randf_range(0.1,1.0)
	var success_chance = 0.4
	
	if rng > success_chance:
		var valid_abilities = instructor.get_abilities().filter(
			func (instructor_ability):
				var student_ability_names = student.get_abilities().map(
					func (e): return e.ability_name
				)
				if !student_ability_names.has(instructor_ability.data.ability_name):
					return instructor_ability 
		)
		
		student.add_ability(valid_abilities.pick_random().ability_props)
		return true
	return false
	
