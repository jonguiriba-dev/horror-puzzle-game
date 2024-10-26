extends TextureProgressBar

func _on_value_changed(value:float):
	print("TextureProgressBar ",value)
	match(int(value)):
		0:
			texture_progress = preload("res://assets/ui/healthbar/health_progress_1.png")
		1:
			texture_progress = preload("res://assets/ui/healthbar/health_progress_1.png")
		2:
			texture_progress = preload("res://assets/ui/healthbar/health_progress_2.png")
		3:
			texture_progress = preload("res://assets/ui/healthbar/health_progress_3.png")
		_:
			texture_progress = preload("res://assets/ui/healthbar/health_progress_3.png")
