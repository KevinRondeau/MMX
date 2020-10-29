extends "res://MegaManX/StateMachineX.gd"

func _enter_state():
	pass
func _handle_input():
	#GetInput
	MMX.input_vector=Vector2.ZERO
	MMX.input_vector.x=Input.get_action_strength("ui_right")-Input.get_action_strength("ui_left")
	#input(Left/Right)
	if MMX.input_vector.x>0:
		MMX.face_right=true
		if MMX.lastState=="Move"||MMX.jumpState=="Move":
			MMX.velocity.x=MMX.SPEED
		if MMX.lastState=="Dash"||MMX.jumpState=="Dash":
			MMX.velocity.x=MMX.DASHSPEED
	elif MMX.input_vector.x<0:
		MMX.face_right=false
		if MMX.lastState=="Move"||MMX.jumpState=="Move":
			MMX.velocity.x=-MMX.SPEED
		if MMX.lastState=="Dash"||MMX.jumpState=="Dash":
			MMX.velocity.x=-MMX.DASHSPEED
	if MMX.face_right!=MMX.actual_facing:
		MMX.sprite.scale.x*=-1
		MMX.IdleFire.position.x*=-1
		MMX.RunFire.position.x*=-1
		MMX.JumpFire.position.x*=-1
		MMX.DashFire.position.x*=-1
		MMX.actual_facing=MMX.face_right
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
		MMX.fire()
		#NormalShot
	if Input.is_action_just_pressed("Attack")&&MMX.can_shoot:
		MMX.shootBullet()
	
	#Jump
	if MMX.can_jump&&Input.is_action_just_pressed("Jump"):
		MMX.velocity.y+=MMX.JUMPFORCE
		MMX.can_jump=false
		MMX.lastState="Jump"
		return "Jump"
	MMX.shoot()
	
	if MMX.is_on_floor()&&MMX.animationPlayer.current_animation=="JumpFire":
		MMX.lastState="Shoot"
		return "Move"
	if MMX.input_vector==Vector2.ZERO&&MMX.animationPlayer.current_animation=="RunFire":
		MMX.shot_ended() 
		
	MMX.velocity=MMX.move_and_slide(MMX.velocity,MMX.FLOOR)

	if MMX.velocity.y>60:
			MMX.lastState="Fall"

