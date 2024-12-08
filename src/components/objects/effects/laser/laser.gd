extends Vfx
class_name LaserVfx

@onready var line := $Line2D
signal finished

func _ready() -> void:
	pass
		
func start(target_position:Vector2):
	line.clear_points()
	line.add_point(Vector2(0,0))
	line.add_point(line.to_local(target_position))
	print("line ",line.points)
	var tween = create_tween()
	tween.tween_property(line, "width", 0, 0.1)
	tween.play()
	await tween.finished
	finished.emit()
	queue_free()
