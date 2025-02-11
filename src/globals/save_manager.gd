extends Node

#const file_path := "user://saves/save1.tres"
const file_path := "res://src/scripts/save/save1.tres"
var save_file = load("res://src/scripts/save/save.tres")
const config_file_path := "user://game.cfg"
var config_file
var config_file_key = "d0nt_h4ck!"
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

func set_config(section,key,data):
	Util.sysprint("SaveManager","save config data %s - %s"%[key,data])
	if !config_file:
		config_file = ConfigFile.new()
	
	config_file.set_value(section,key,data)
	config_file.save_encrypted_pass(config_file_path,config_file_key)
	
func get_config(section,key):
	Util.sysprint("SaveManager","load config %s - %s"%[key])
	if !config_file:
		config_file = config_file.load_encrypted_pass(config_file_path,config_file_key)
		if !config_file:
			return
	
	config_file.get_value(section,key)
	
func load_data():
	print("loading data ")
	loaded_data = SafeResourceLoader.load(file_path,"SaveData")
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
