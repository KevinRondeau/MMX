extends "res://MegaManX/StateMachineX.gd"

func _enter_state():
	MMX.currentAnimation=MMX.animationPlayer.current_animation_position
	MMX.animationPlayer.play("Jump")
	if MMX.lastState=="Shoot":
		MMX.animationPlayer.seek(MMX.currentAnimation)
	if MMX.lastState=="Dash":
		MMX.velocity.y=0
		MMX.velocity.y+=MMX.JUMPFORCE
	MMX.velocity=MMX.move_and_slide(MMX.velocity,MMX.FLOOR)
		
func _handle_input():
	#GetInput
	MMX.input_vector=Vector2.ZERO
	MMX.input_vector.x=Input.get_action_strength("ui_right")-Input.get_action_strength("ui_left")
	
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
	#Shoot
	if Input.is_action_just_released("Attack")&&MMX.can_shoot&&MMX.charge>50:
		MMX.lastState="Jump"
		MMX.fire()
		return "Shoot"
		#NormalShot
	if Input.is_action_just_pressed("Attack")&&MMX.can_shoot:
		MMX.lastState="Jump"
		MMX.fire()
		MMX.charge=0
		return "Shoot"
		
	MMX.animationPlayer.play("Jump")
	MMX.can_jump=false
	if MMX.input_vector.x>0:
		MMX.face_right=true
		if MMX.jumpState=="Move":
			MMX.velocity.x=MMX.SPEED
		if MMX.jumpState=="Dash":
			MMX.velocity.x=MMX.DASHSPEED
	elif MMX.input_vector.x<0:
		MMX.face_right=false
		if MMX.jumpState=="Move":
			MMX.velocity.x=-MMX.SPEED
		if MMX.jumpState=="Dash":
			MMX.velocity.x=-MMX.DASHSPEED
	if MMX.input_vector!=Vector2.ZERO&&MMX.jumpState!="Dash":
		MMX.jumpState="Move"
	
	MMX.velocity=MMX.move_and_slide(MMX.velocity,MMX.FLOOR)
	
	if MMX.velocity.y>100:
		MMX.lastState="Fall"
		return "Fall"
