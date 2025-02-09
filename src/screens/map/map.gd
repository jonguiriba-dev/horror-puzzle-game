extends Control

@onready var map := $Map
@onready var select_view := $SelectView
var active_regions := []

enum REGIONS {
	SHOP_TOWN,
	GOOD_CASTLE,
	MT_RED,
	DARK_FOREST,
	PORTSIDE,
	LAKE_TOWN,
	BAD_CASTLE
}

@onready var region_config :Dictionary= {
	[REGIONS.SHOP_TOWN] :  {"node":$Shoptown,"level":1},
	[REGIONS.GOOD_CASTLE] :  {"node":$GoodCastle,"level":1},
	[REGIONS.MT_RED] :  {"node":$MtRed,"level":1},
	[REGIONS.DARK_FOREST] : {"node":$DarkForest,"level":1},
	[REGIONS.PORTSIDE] : {"node":$Portside,"level":1},
	[REGIONS.LAKE_TOWN] : {"node":$LakeTown,"level":1},
	[REGIONS.BAD_CASTLE] : {"node":$BadCastle,"level":1},
}
var active_region_sprites = []

func _ready() -> void:
	WorldManager.level_complete.connect(_on_WorldManager_level_complete)
	randomize_active_regions()
	for child in get_children():
		if child is Region:
			child.area.mouse_entered.connect(_on_region_area_entered.bind(child))
			child.area.mouse_exited.connect(_on_region_area_exited.bind(child))
			child.randomize_active_location()
	select_view.hide()
	PlayerManager.save_data_to_storage()
	
func randomize_active_regions():
	active_regions = region_config.values()
	active_regions.shuffle()
	active_regions.pop_front()
	active_regions.pop_front()
	
	print("active_regions ",active_regions)
	
	active_region_sprites = []
	
	for region in active_regions:
		var label = Label.new()
		region.node.add_child(label)
		label.text = "ACTIVE_REGION"
		label.global_position = region.node.select_anchor.global_position
		active_region_sprites.push_front(label)
		
func _on_party_button_pressed() -> void:
	SceneManager.change_scene("res://src/screens/manage_roster/ManageRoster.tscn")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		var region = get_tree().get_first_node_in_group(C.GROUPS_HOVERED_REGIONS)
		print(">region>> ",region)
		if region:
			print(">>> ",active_regions.map(func (e): return e.node))
			if active_regions.map(func (e): return e.node).has(region):
				SceneManager.change_scene(region.scene,true)
				
				select_view.hide()
				region.remove_from_group(C.GROUPS_HOVERED_REGIONS)
				active_region_sprites.map(func (e): e.queue_free())
				for region_conf in region_config.values():
					if active_regions.has(region_conf):
						region_conf.level += 1
				
				print("region_config",region_config)
func _on_region_area_entered(region:Region) -> void:
	Util.sysprint("Map","region hovered:%s"%[region.name])
	
	if region.label.text == "Gateway":
		return
	if !active_regions.map(func(e):return e.node).has(region):
		return
		
	region.add_to_group(C.GROUPS_HOVERED_REGIONS)
	region.label.position += Vector2(0,-10) 
	
	
	select_view.global_position = region.select_anchor.global_position
	select_view.location_name.text = region.active_location.location_name
	select_view.show()
	
func _on_region_area_exited(region) -> void:
	region.label.position += Vector2(0,10) 
	Util.sysprint("Map","region exited:%s"%[region.name])
	region.remove_from_group(C.GROUPS_HOVERED_REGIONS)
	
	if !get_tree().get_first_node_in_group(C.GROUPS_HOVERED_REGIONS):
		select_view.hide()

func _on_area_2d_area_entered(area: Area2D) -> void:
	print("sadfasdfasd") # Replace with function body.


func _on_area_2d_mouse_entered() -> void:
	print("123") # Replace with function body.
	pass # Replace with function body.


func _on_area_2d_mouse_exited() -> void:
	print("456") # Replace with function body.
	pass # Replace with function body.

func _on_WorldManager_level_complete() -> void:
	randomize_active_regions()
	SaveManager.save_data("screen",SaveManager.SCREENS.MAP)
	SaveManager.save_data("map",to_save_data())
	SaveManager.save_data("level",null)
	PlayerManager.save_data_to_storage()
func to_save_data():
	return {
		"active_regions":active_regions
	}
