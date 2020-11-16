extends "res://MegaManX/StateMachineX.gd"

func _enter_state():
	if MMX.velocity.y<0:
		MMX.velocity.y=0
	if MMX.lastState=="WallGrab":
		var position=MMX.animationPlayer.get_current_animation_position()
		MMX.animationPlayer.seek(position)
	else:
		MMX.animationPlayer.play("WallGrab")
	MMX.lastState="WallGrab"
	
		
func _handle_input():

	#GetInput
	MMX.input_vector=Vector2.ZERO
	MMX.input_vector.x=Input.get_action_strength("ui_right")-Input.get_action_strength("ui_left")
	if MMX.face_right==true&&MMX.input_vector.x>0:
		MMX.velocity.x=MMX.SPEED
	if MMX.face_right==false&&MMX.input_vector.x<0:
		MMX.velocity.x=-MMX.SPEED
	if MMX.face_right==true&&MMX.input_vector.x<=0:
		MMX.lastState="Fall"
		return "Fall"
	elif MMX.face_right==false&&MMX.input_vector.x>=0:
		MMX.lastState="Fall"
		return "Fall"
	if MMX.is_on_floor():
		MMX.lastState="Idle"
		return "Idle"
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
	if Input.is_action_just_pressed("Jump"):
		if MMX.face_right==true:
			MMX.velocity.x=-MMX.SPEED*1.5
			MMX.velocity.y=MMX.JUMPFORCE
			MMX.velocity=MMX.move_and_slide(MMX.velocity,MMX.FLOOR)
			return "WallKick"
		if MMX.face_right==false:
			MMX.velocity.x=MMX.SPEED*1.5
			MMX.velocity.y=MMX.JUMPFORCE
			MMX.velocity=MMX.move_and_slide(MMX.velocity,MMX.FLOOR)
			return "WallKick"
	MMX.velocity=MMX.move_and_slide(MMX.velocity,MMX.FLOOR)
