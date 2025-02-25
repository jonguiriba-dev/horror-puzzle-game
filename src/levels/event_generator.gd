extends Node
class_name EventGenerator

const EVENT_COUNT = 3
const EVENT_PRESETS = [
	{
		"name":"To Caves",
		"type":EVENT_TYPES.COMBAT,
		"rewards":[
			{"type":EVENT_REWARD_TYPES.GOLD},
			{"type":EVENT_REWARD_TYPES.ABILITY}
		],
		"scene": C.SCENES.LEVELS.CAVE,
	},
	{
		"name":"To Gardens",
		"type":EVENT_TYPES.COMBAT,
		"rewards":[
			{"type":EVENT_REWARD_TYPES.GOLD},
			{"type":EVENT_REWARD_TYPES.ABILITY}
		],
		"scene": C.SCENES.LEVELS.FOREST,
	},
	{
		"name":"Look around",
		"type":EVENT_TYPES.COMBAT,
		"rewards":[
			{"type":EVENT_REWARD_TYPES.GOLD},
			{"type":EVENT_REWARD_TYPES.ABILITY},
			{"type":EVENT_REWARD_TYPES.UNIT}
		],
		"scene": C.SCENES.LEVELS.LAKE,
	},
	{
		"name":"Setup Camp",
		"type":EVENT_TYPES.COMBAT,
		"rewards":[
			{"type":EVENT_REWARD_TYPES.GOLD},
			{"type":EVENT_REWARD_TYPES.ABILITY},
		],
		"scene": C.SCENES.LEVELS.FOREST,
	}
]


enum EVENT_TYPES{
	COMBAT,
	TREASURE,
	TRAINING,
	ELITE,
	SHOP,
}

enum EVENT_REWARD_TYPES{
	GOLD,
	ABILITY,
	ITEM,
	UNIT,
	VARIABLE
}
static func generate_events():
	var event_count = EVENT_COUNT + randi_range(-1,1)
	var events = []
	
	for i in range(event_count):
		var random_event = generate_random_event()
		events.push_front(random_event)
		
	return events
static func generate_random_event():
	var event = {
		"name":"",
		"type":EVENT_TYPES.COMBAT,
		"rewards":[],
		"scene":""
	}
		
	event = EVENT_PRESETS.pick_random()
	
	return event
