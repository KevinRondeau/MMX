extends "res://MegaManX/StateMachineX.gd"

func _enter_state():
	MMX.animationPlayer.play("WallKick")
		
func _handle_input():
	#Charge
	if Input.is_action_pressed("Attack"):
		MMX.charge+=1
	#ChargeEffect
	if MMX.charge>49:
		MMX.FirstParticle.emitting=true
		MMX.FirstParticle.visible=true
	if MMX.charge>145:
		if MMX.charge>150:
			MMX.charge=150
		MMX.FirstParticle.emitting=false
		MMX.FirstParticle.visible=false
		MMX.FullParticle.emitting=true
		MMX.FullParticle.visible=true
	MMX.velocity=MMX.move_and_slide(MMX.velocity,MMX.FLOOR)
	if MMX.animationPlayer.get_current_animation_position()>0.18:
		MMX.lastState="Fall"
		return "Fall"
