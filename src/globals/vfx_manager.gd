extends Node

func spawn(vfx_name:String):
	match vfx_name:
		"charge_in": return preload("res://src/components/objects/effects/charge_in/ChargeIn.tscn").instantiate()
		"laser": return preload("res://src/components/objects/effects/laser/Laser.tscn").instantiate()
	
