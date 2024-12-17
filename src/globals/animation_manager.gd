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
