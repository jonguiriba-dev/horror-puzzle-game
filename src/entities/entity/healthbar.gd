extends TextureProgressBar

func _on_value_changed(_value:float):
	print("TextureProgressBar ",_value)
	match(int(_value)):
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
