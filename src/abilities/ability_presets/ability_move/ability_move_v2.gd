extends AbilityV2

var path=[]
var initial_position
var target_position=null
var play_animation = false
signal move_target_set(map_position:Vector2i)

func setup(host:Entity) -> void:
	super(host)
	has_ui = false
	data.ability_range = host.data.move_range
	
func use(target_map_position:Vector2i, options:Dictionary={}):
	print("Moving... ", target_map_position)
	if !is_valid_target(target_map_position) and !options.get('absolute',false):
		stopped_targetting.emit()
		print("%s.%s[host.ability.use()]: no valid target found for pos %s"%[host.data.entity_name,data.ability_name,target_map_position])
		return
	path = WorldManager.level.grid.astar_grid.get_id_path(host.map_position, target_map_position)
	if path.size() > 0:
		path.remove_at(0)
		
		path = path.filter(func(e):
			for ally in host.get_allies():
				if WorldManager.level.grid.local_to_map(ally.position) == e:
					return false
			return true
		)
	
	var tween = host.create_tween()
	for tile in path:
		tween.tween_property(
			host,
			"position",
			WorldManager.level.grid.map_to_local(tile),
			0.1
		)	
		tween.tween_interval(0.1)
	tween.play()
	SfxManager.play("step-2")
	await tween.finished
	#initial_position = host.position
	#if target_map_position == host.map_position:
		#host.move_end.emit()
	#else:
		#target_position = target_map_position
	super(target_map_position)

		
func show_path_highlight():
	for tile in path:
		WorldManager.level.grid.set_highlight(tile, Grid.HIGHLIGHT_COLORS.ORANGE,Grid.HIGHLIGHT_LAYERS.DEBUG)
	
func _on_used(ability:AbilityV2):
	super(ability)
	host.data.move_counter -= 1
	if host.data.team == C.TEAM.PLAYER:
		WorldManager.level.entity_moved_history.push_front({"entity":host,"prev_map_position":initial_position})
		UIManager.ui.enable_undo_move_button()
