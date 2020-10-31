extends "res://MegaManX/StateMachineX.gd"

func _enter_state():
	MMX.currentAnimation=MMX.animationPlayer.current_animation_position
	MMX.animationPlayer.play("Dash")
	if MMX.lastState=="Shoot":
		MMX.animationPlayer.seek(MMX.currentAnimation)
		
func _handle_input():
	#GetInput
	MMX.input_vector=Vector2.ZERO
	MMX.input_vector.x=Input.get_action_strength("ui_right")-Input.get_action_strength("ui_left")
	#Jump
	if MMX.can_jump&&Input.is_action_just_pressed("Jump"):
		MMX.lastState="Jump"
		MMX.velocity.y+=MMX.JUMPFORCE
		MMX.can_jump=false
		MMX.jumpState="Dash"
		return "Jump"
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
		
	if Input.is_action_just_released("Attack")&&MMX.can_shoot&&MMX.charge>50:
		MMX.lastState="Dash"
		MMX.fire()
		return "Shoot"
		#NormalShot
	if Input.is_action_just_pressed("Attack")&&MMX.can_shoot:
		MMX.lastState="Dash"
		MMX.fire()
		MMX.charge=0
		return "Shoot"
		
	MMX.animationPlayer.play("Dash")
	
	if MMX.face_right==true:
		MMX.velocity.x=MMX.DASHSPEED
	if MMX.face_right==false:
		MMX.velocity.x=-MMX.DASHSPEED
	if Input.is_action_just_released("Dash"):
		MMX.lastState="Move"
		MMX.can_dash=true
		return "Move"
		
	MMX.velocity=MMX.move_and_slide(MMX.velocity,MMX.FLOOR)
	
	if MMX.velocity.y>60:
		MMX.lastState="Fall"
		return "Fall"
	if MMX.is_on_floor():
		MMX.can_jump=true
	
