extends Node

#const file_path := "user://saves/save1.tres"
const file_path := "res://src/scripts/save/save1.tres"
var save_file = load("res://src/scripts/save/save.tres")
var loaded_data: SaveData

enum SCREENS {
	MAP,
	LEVEL
}

signal game_loaded

func save_game():
	Util.sysprint("SaveManager","saving file to %s"%[file_path])
	var persist_dir := DirAccess.open("user://")
	if persist_dir:
		if persist_dir.dir_exists("saves"):
			pass
		else:
			persist_dir.make_dir("saves")
	
	var res = ResourceSaver.save(save_file,file_path)

func save_data(key,data):
	Util.sysprint("SaveManager","save data %s - %s"%[key,data])
	save_file.set(key,data)

func load_data():
	print("loading data ")
	loaded_data = ResourceLoader.load(file_path,"SaveData")
	if loaded_data:
		for key in loaded_data.to_dict():
			save_data(key,loaded_data[key])
	print("loaded current_scene ", loaded_data.scene_manager.current_scene_path)
	game_loaded.emit()

func get_loaded(resource:String, key:String="", default=null):
	
	if loaded_data:
		var loaded_resource = loaded_data.get(resource)
		if loaded_resource != null:
			if key == "":
				return loaded_resource
			if loaded_resource.get(key) != null:
				return loaded_resource.get(key)
	return default
