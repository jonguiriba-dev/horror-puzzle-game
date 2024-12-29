extends Node


func jump(host:Entity,target_pos:Vector2):
	var tween = create_tween()
	var jump_height := 32 * -1
	var mid_position = ((host.position + target_pos) / 2) + Vector2(0,jump_height)
	var section_1 = (host.position + mid_position) / 2+ Vector2(0,jump_height/2)
	var section_2 = (target_pos + mid_position) / 2+ Vector2(0,jump_height/2)
	
	tween.tween_property(host,'position',section_1,0.2)
	tween.tween_property(host,'position',mid_position,0.1)
	tween.tween_property(host,'position',section_2,0.1)
	tween.tween_property(host,'position',target_pos,0.2)
	await tween.finished
	return

func squeeze(host:Entity):
	var tween = create_tween()
	var prev_scale = host.scale
	host.scale = Vector2(1.3,1.2)
	tween.tween_property(host,'scale',Vector2(1.2,1.3),0.2)
	tween.tween_property(host,'scale',prev_scale,0.15)
	await tween.finished
	return

func warp(host:Entity):
	host.material = preload("res://src/shaders/warp/warp_shader_material.tres")
	var tween = create_tween()
	tween.tween_property(host.material.shader_parameter,'time',1,0.2)
	tween.tween_property(host.material.shader_parameter,'time',0,0.2)
	await tween.finished
	host.material = null
	return
