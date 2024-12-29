extends Control

@export var location_name := "location_name"
@export var location_image:CompressedTexture2D

@onready var location_name_label := $LocationName
@onready var location_image_sprite := $Control/LocationImage

func _ready() -> void:
	location_name_label.text = location_name
	
	if location_image:
		location_image_sprite.texture = location_image
