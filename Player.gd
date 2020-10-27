extends KinematicBody2D
#Physics
export var SPEED=150
export var DASHSPEED=300
export var GRAVITY=20
export var MAXFALLSPEED=1000
export var JUMPFORCE=-500
const FLOOR=Vector2(0,-1)
#Input&Facing
var input_vector=Vector2.ZERO
var velocity=Vector2.ZERO
var face_right
var actual_facing
var can_jump
var can_shoot
var charge=0;

#preload scene to shoot bullet
const BULLET=preload("res://Bullet.tscn")
const FIRSTCHARGE=preload("res://FirstCharge.tscn")
const MAXCHARGE=preload("res://MaxCharge.tscn")


enum{
	IDLE,
	SPAWN,
	MOVE,
	JUMP,
	FALL,
	DASH,
	FIRE
}

#OnReady Var
onready var animationPlayer=$AnimationPlayer
onready var fireTimer=$Firing
onready var state=SPAWN
onready var lastState=state
onready var bullet
var jumpState=MOVE
var currentAnimation=0.0

func _ready():
	$Sprite.scale.x*=-1
	$IdleFire.position.x*=-1
	$RunFire.position.x*=-1
	$JumpFire.position.x*=-1
	$DashFire.position.x*=-1
	face_right=true
	actual_facing=true

func _physics_process(_delta):
	if state!=SPAWN:
		#GetInput
		input_vector=Vector2.ZERO
		input_vector.x=Input.get_action_strength("ui_right")-Input.get_action_strength("ui_left")
		#Move
		if input_vector!=Vector2.ZERO&&state!=JUMP&&state!=DASH&&state!=FALL&&state!=FIRE:
			state=MOVE
			lastState=MOVE
			jumpState=MOVE
		#Idle
		if input_vector==Vector2.ZERO&&state!=JUMP&&state!=DASH&&state!=FALL&&state!=FIRE:
			state=IDLE
			lastState=IDLE
			jumpState=IDLE
		#Charge
		if Input.is_action_pressed("Attack"):
			charge+=1
		#ChargeEffect
		if charge>49:
			$FirstCharge.emitting=true
			$FirstCharge.visible=true
		if charge>145:
			if charge>150:
				charge=150
			$FirstCharge.emitting=false
			$FirstCharge.visible=false
			$MaxCharge.emitting=true
			$MaxCharge.visible=true
		#ChargedShot
		if Input.is_action_just_released("Attack")&&can_shoot&&charge>50:
			fire()
		#NormalShot
		if Input.is_action_just_pressed("Attack")&&can_shoot:
			charge=0
			shootBullet()
		#Dash
		if Input.is_action_just_pressed("Dash")&&state!=JUMP&&state!=FALL&&state!=FIRE&&(Input.is_action_pressed("ui_left")||Input.is_action_pressed("ui_right")):
			state=DASH
			lastState=DASH
			jumpState=DASH
		#Jump
		if can_jump&&Input.is_action_just_pressed("Jump"):
			state=JUMP
			lastState=JUMP
			velocity.y=JUMPFORCE
		#AnimationState
		match state:
			JUMP:
				animationPlayer.play("Jump")
				jump()
			FALL:
				lastState=FALL
				jump()
			FIRE:
				shoot()
				if is_on_floor()&&animationPlayer.current_animation=="JumpFire":
					state=MOVE
				if input_vector==Vector2.ZERO&&animationPlayer.current_animation=="RunFire":
					shot_ended()
			DASH:
				animationPlayer.play("Dash")
				dash()
			MOVE:
				animationPlayer.play("Run")
				move()
			IDLE:
				animationPlayer.play("Idle")
				idle()
				
		#Facing
		if face_right!=actual_facing:
			$Sprite.scale.x*=-1
			$IdleFire.position.x*=-1
			$RunFire.position.x*=-1
			$JumpFire.position.x*=-1
			$DashFire.position.x*=-1
			actual_facing=face_right
		velocity = move_and_slide(velocity,FLOOR)
		#Detect Fall(+exceptions)
		if velocity.y>60&&state==FIRE:
			lastState=FALL
		if state!=DASH&&state!=FIRE:
			if !is_on_floor()&&velocity.y>40:
				state=FALL
				animationPlayer.play("Jump")
				animationPlayer.seek(0.8)
				can_jump=false
			if is_on_floor():
				state=MOVE
				can_jump=true
		#Gravity
		if !is_on_floor():
			velocity.y+=GRAVITY
			if(velocity.y>MAXFALLSPEED):
				velocity.y=MAXFALLSPEED
	else:
		_spawn()

func fire():
	$ShotTimer.start(0.5)
	$FirstCharge.emitting=false
	$FirstCharge.visible=false
	$MaxCharge.emitting=false
	$MaxCharge.visible=false
	can_shoot=false
	state=FIRE
	fireTimer.start(0.4)
	if charge>50&&charge<150:
		bullet=FIRSTCHARGE.instance()
	if charge>144:
		bullet=MAXCHARGE.instance()
	if face_right==true:
		bullet.set_direction(1)
	else:
		bullet.set_direction(-1)
	get_parent().add_child(bullet)
	bulletPosition()
	charge=0

func bulletPosition():
	match lastState:
		IDLE:
			bullet.position=$IdleFire.global_position
		MOVE:
			bullet.position=$RunFire.global_position
		JUMP:
			bullet.position=$JumpFire.global_position
		FALL:
			bullet.position=$JumpFire.global_position
		DASH:
			bullet.position=$DashFire.global_position

func shootBullet():
	$ShotTimer.start(0.1)
	$FirstCharge.emitting=false
	$FirstCharge.visible=false
	$MaxCharge.emitting=false
	$MaxCharge.visible=false
	can_shoot=false
	fireTimer.start(0.3)
	state=FIRE
	bullet=BULLET.instance()
	if face_right==true:
		bullet.set_direction(1)
	else:
		bullet.set_direction(-1)
	get_parent().add_child(bullet)
	bulletPosition()

func shoot():
	currentAnimation=animationPlayer.current_animation_position
	match lastState:
		IDLE:
			animationPlayer.play("IdleFire")
			if charge==0:
				animationPlayer.seek(0)
			if input_vector!=Vector2.ZERO:
				shot_ended()
			idle()
		MOVE:
			animationPlayer.play("RunFire")
			animationPlayer.seek(currentAnimation)
			move()
		JUMP:
			animationPlayer.play("JumpFire")
			animationPlayer.seek(currentAnimation)
			jump()
		FALL:
			animationPlayer.play("JumpFire")
			animationPlayer.seek(0.8)
			jump()	
		DASH:
			animationPlayer.play("DashFire")
			animationPlayer.seek(currentAnimation)
			dash()

func move():
	currentAnimation=animationPlayer.current_animation_position
	#input(Left/Right)
	if input_vector.x>0:
		face_right=true
		if state==MOVE||state==FIRE:
			velocity.x=SPEED
	elif input_vector.x<0:
		face_right=false
		if state==MOVE||state==FIRE:
			velocity.x=-SPEED

func idle():
	velocity.x=0

func jump():
	can_jump=false
	if input_vector.x>0:
		face_right=true
		if jumpState==MOVE:
			velocity.x=SPEED
		if jumpState==DASH:
			velocity.x=DASHSPEED
	elif input_vector.x<0:
		face_right=false
		if jumpState==MOVE:
			velocity.x=-SPEED
		if jumpState==DASH:
			velocity.x=-DASHSPEED
	if input_vector!=Vector2.ZERO&&jumpState!=DASH:
		jumpState=MOVE

func dash():
	if actual_facing==true:
		velocity.x=DASHSPEED
	else:
		velocity.x=-DASHSPEED
	if Input.is_action_just_released("Dash"):
		state=MOVE
	lastState=DASH

func _spawn():
	if !is_on_floor():
		animationPlayer.play("SpawnFall")
		velocity.y=500
		velocity = move_and_slide(velocity,FLOOR)
	else :
		animationPlayer.play("Spawn")

func _Spawned():
	state=MOVE
	lastState=MOVE
	animationPlayer.play("Idle")
	can_shoot=true

func dash_over():
	state=MOVE
	velocity.x=0
	velocity = move_and_slide(velocity,FLOOR)

func shot_ended():
	currentAnimation=animationPlayer.current_animation_position
	match lastState:
		IDLE:
			animationPlayer.play("Idle")
			state=IDLE
		MOVE:
			animationPlayer.play("Run")
			animationPlayer.seek(currentAnimation)
			state=MOVE
		JUMP:
			animationPlayer.play("Jump")
			animationPlayer.seek(currentAnimation)
			state=JUMP
		FALL:
			animationPlayer.play("Jump")
			animationPlayer.seek(0.8)
			state=FALL
		DASH:
			animationPlayer.play("Dash")
			animationPlayer.seek(currentAnimation)
			state=DASH
		
func _on_Firing_timeout():
	shot_ended()

func _on_ShotTimer_timeout():
	can_shoot=true
