extends ColorRect

signal send_hide()
signal send_show()

func shadow_hide():
	$AnimationPlayer.play("hide")
	
func shadow_show():
	$AnimationPlayer.play("show")

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "hide":
		emit_signal("send_hide")
	if anim_name == "show":
		emit_signal("send_show")
		
