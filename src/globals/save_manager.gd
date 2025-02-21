extends Node

#const file_path := "res://src/scripts/save/save1.tres"
var save_file = load("res://src/scripts/save/save.tres")
const config_file_path := "user://game.cfg"
var config_file:ConfigFile
var config_file_key = "d0nt_h4ck!"
var loaded_data: SaveData

#const FILE_PATH_1 = "user://saves/save1.tres"
#const FILE_PATH_2 = "user://saves/save2.tres"
const FILE_PATH_1 = "res://src/scripts/save/save1.tres"
const FILE_PATH_2 = "res://src/scripts/save/save2.tres"
const default_file_path := FILE_PATH_1
var save_file_path := ""

enum SCREENS {
	MAP,
	LEVEL
}

signal game_loaded

func _ready() -> void:
	var save_dir := DirAccess.open("user://")
	if save_dir:
		if save_dir.dir_exists("saves"):
			pass
		else:
			save_dir.make_dir("saves")
			
	if !config_file:
		config_file = ConfigFile.new()
		config_file.load_encrypted_pass(config_file_path,config_file_key)
	
	#for toggling between save_file_path 1 and 2; which is for corruption protection
	var current_file_path = get_config("save_manager","current_file_path","")
	if !current_file_path:
		save_file_path = default_file_path
	else:
		save_file_path = current_file_path
	
	Util.sysprint("SaveManager","file_path %s"%[save_file_path])
	Util.sysprint("SaveManager","config_file %s"%[config_file])

func save_game():
	Util.sysprint("SaveManager","saving file to %s"%[save_file_path])
	var res = ResourceSaver.save(
		save_file,
		save_file_path,
		ResourceSaver.FLAG_RELATIVE_PATHS
	)

func save_data(key,data):
	Util.sysprint("SaveManager","save data %s - %s"%[key,data])
	save_file.set(key,data)
	
func reset_save_data():
	
	save_file.reset()
func set_config(section,key,data):
	Util.sysprint("SaveManager","save config data %s - %s"%[key,data])
	
	config_file.set_value(section,key,data)
	config_file.save_encrypted_pass(config_file_path,config_file_key)
	
func get_config(section, key, default=null):
	Util.sysprint("SaveManager","load config %s - %s"%[section,key])
	
	return config_file.get_value(section,key,default)
	
func load_data():
	print("loading data ", save_file_path)
	#TODO: switch to SafeResourceLoader when using user folder
	var temp_loaded_data = ResourceLoader.load(save_file_path,'',ResourceLoader.CACHE_MODE_IGNORE)
	loaded_data = temp_loaded_data.duplicate()
	temp_loaded_data.unreference()
	if loaded_data:
		for key in loaded_data.to_dict():
			save_file.set(key,loaded_data[key])
	print("loaded current_scene ", loaded_data.scene_manager.current_scene_path)
	
	#loaded_data.unreference()
	game_loaded.emit()
	
	var current_file_path = get_config("save_manager","current_file_path")
	
	if current_file_path == FILE_PATH_1:
		save_file_path = FILE_PATH_2
	else:
		save_file_path = FILE_PATH_1
	set_config("save_manager","current_file_path",save_file_path)
	
func get_loaded(resource:String, key:String="", default=null):
	
	if loaded_data:
		var loaded_resource = loaded_data.get(resource)
		print("loaded_resource ",loaded_resource)
		if loaded_resource != null:
			if key == "":
				return loaded_resource
			if loaded_resource.get(key) != null:
				return loaded_resource.get(key)
	
	print("key ",key,"returning default ",default)
	return default
