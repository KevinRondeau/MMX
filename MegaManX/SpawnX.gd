extends "res://MegaManX/StateMachineX.gd"

func _ready():
	pass

func _enter_state():
	pass
	
func _handle_input():
	if !MMX.is_on_floor():
		MMX.animationPlayer.play("SpawnFall")
		MMX.velocity.y=500
		MMX.velocity = MMX.move_and_slide(MMX.velocity,MMX.FLOOR)
	if MMX.is_on_floor():
		MMX.animationPlayer.play("Spawn")
