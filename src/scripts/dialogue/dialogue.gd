extends Resource
class_name Dialogue

@export var title:String
@export var trigger:C.DIALOGUE_TRIGGER=C.DIALOGUE_TRIGGER.ON_START
@export_file("*.txt") var content_file
var content
var speech_bubble_tscn = preload("res://src/components/dialogue/speech_bubble/SpeechBubble.tscn")

signal input_waiting
signal input_recieved
	
func play(entities:Array[Node]):
	var file = FileAccess.open(content_file, FileAccess.READ)
	content = file.get_as_text(true).replace("\n","").split(",")
	
	for c in content:
		var entity_name = c.split(":")[0]
		var text = c.split(":")[1]
		
		var actor = entities.filter(func(e):
			return e.entity_name == entity_name
		)[0]
		var speech_bubble = speech_bubble_tscn.instantiate()
		WorldManager.grid.prop_layer.add_child(speech_bubble)
		speech_bubble.set_text(text)
		var offset = Vector2(0,-70)
		speech_bubble.position = actor.position + offset
		input_waiting.emit()
		await input_recieved
		await Util.wait(0.4)
		speech_bubble.queue_free()
