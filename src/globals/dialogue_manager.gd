extends Node
var speech_bubble_tscn := preload("res://src/components/dialogue/speech_bubble/SpeechBubble.tscn")

var SCENARIO_TO_TEXT = {
	"to_strategy_retreat": ["Retreat!"],
	"to_strategy_forward": ["Push through!"],
	"to_strategy_spread": ["Spread out!"],
	"to_strategy_together": ["As one!"],
	"to_strategy_nearest": ["Strike them down!"],
}

func get_scenario_text(scenario:String):
	if SCENARIO_TO_TEXT.has(scenario):
		return SCENARIO_TO_TEXT[scenario].pick_random()

func speak(global_position,text,wait):
	var speech_bubble = speech_bubble_tscn.instantiate()
	WorldManager.grid.prop_layer.add_child(speech_bubble)
	speech_bubble.set_text(text)
	speech_bubble.global_position = global_position + Vector2(6,-30)
	var curr_modulate = speech_bubble.modulate
	speech_bubble.modulate.a = 0
	
	var tween = create_tween()
	tween.tween_property(speech_bubble,"modulate",curr_modulate,0.3)
	await tween.finished
	await Util.wait(wait)
	curr_modulate.a = 0
	var tween2 = create_tween()
	tween2.tween_property(speech_bubble,"modulate",curr_modulate,0.3)
	await tween2.finished
	speech_bubble.queue_free()
