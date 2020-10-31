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
var can_dash;
var charge=0;
#preload scene to shoot bullet
const BULLET=preload("res://MegaManX/Bullet.tscn")
const FIRSTCHARGE=preload("res://MegaManX/FirstCharge.tscn")
const MAXCHARGE=preload("res://MegaManX/MaxCharge.tscn")

onready var States={
	"Spawn": $StateMachineX/SpawnX,
	"Idle" : $StateMachineX/IdleX,
	"Move" : $StateMachineX/MoveX,
	"Dash" : $StateMachineX/DashX,
	"Jump" : $StateMachineX/JumpX,
	"Fall" : $StateMachineX/FallX,
	"Shoot": $StateMachineX/ShootX,
	"Dead" : $StateMachineX/DeadX
}
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
onready var currentState=States.Spawn
onready var lastState="Idle"
onready var bullet
onready var jumpState="Move"
onready var currentAnimation=0.0
onready var FirstParticle=$FirstCharge
onready var FullParticle=$MaxCharge
onready var sprite=$Sprite
onready var IdleFire=$IdleFire
onready var RunFire=$RunFire
onready var JumpFire=$JumpFire
onready var DashFire=$DashFire
onready var DashTimer=$DashTimer

func _ready():
	sprite.scale.x*=-1
	IdleFire.position.x*=-1
	RunFire.position.x*=-1
	JumpFire.position.x*=-1
	DashFire.position.x*=-1
	face_right=true
	actual_facing=true
	can_dash=true
	currentState._enter_state()

func _physics_process(_delta):
	var update_state=currentState._handle_input()
	if update_state!=null:
		change_state(update_state);
		currentState._enter_state()
		#Facing
	if face_right!=actual_facing:
		sprite.scale.x*=-1
		IdleFire.position.x*=-1
		RunFire.position.x*=-1
		JumpFire.position.x*=-1
		DashFire.position.x*=-1
		actual_facing=face_right
	if !is_on_floor():
		velocity.y+=GRAVITY
		if(velocity.y>MAXFALLSPEED):
			velocity.y=MAXFALLSPEED


func change_state(new_state):
	currentState=States[new_state]
	

func fire():
	$FirstCharge.emitting=false
	$FirstCharge.visible=false
	$MaxCharge.emitting=false
	$MaxCharge.visible=false
	can_shoot=false
	fireTimer.start(0.3)
	if charge<50:
		$ShotTimer.start(0.1)
		bullet=BULLET.instance()
	if charge>=50&&charge<150:
		$ShotTimer.start(0.5)
		bullet=FIRSTCHARGE.instance()
	if charge>=144:
		$ShotTimer.start(0.5)
		bullet=MAXCHARGE.instance()
	if face_right==true:
		bullet.set_direction(1)
	else:
		bullet.set_direction(-1)
	bulletPosition()
	get_parent().add_child(bullet)
	charge=0

func bulletPosition():
	match lastState:
		"Idle":
			bullet.position=$IdleFire.global_position
		"Move":
			bullet.position=$RunFire.global_position
		"Jump":
			bullet.position=$JumpFire.global_position
		"Fall":
			bullet.position=$JumpFire.global_position
		"Dash":
			bullet.position=$DashFire.global_position

func shoot():
	currentAnimation=animationPlayer.current_animation_position
	match lastState:
		"Idle":
			animationPlayer.play("IdleFire")
			if charge==0:
				animationPlayer.seek(0)
			if input_vector!=Vector2.ZERO:
				shot_ended()
		"Move":
			animationPlayer.play("RunFire")
			animationPlayer.seek(currentAnimation)
		"Jump":
			animationPlayer.play("JumpFire")
			animationPlayer.seek(currentAnimation)
		"Fall":
			animationPlayer.play("JumpFire")
			animationPlayer.seek(0.8)
		"Dash":
			animationPlayer.play("DashFire")
			animationPlayer.seek(currentAnimation)

func move():
	currentAnimation=animationPlayer.current_animation_position
	#input(Left/Right)
	if input_vector.x>0:
		face_right=true
		if currentState=="Move"||currentState=="Shoot":
			velocity.x=SPEED
	elif input_vector.x<0:
		face_right=false
		if currentState=="Move"||currentState=="Shoot":
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
		currentState="Move"
	lastState=DASH

func _Spawned():
	currentState=States.Idle
	can_shoot=true
	can_jump=true

func shot_ended():
	currentAnimation=animationPlayer.current_animation_position
	match lastState:
		"Idle":
			animationPlayer.play("Idle")
			currentState=States.Idle
		"Move":
			animationPlayer.play("Run")
			animationPlayer.seek(currentAnimation)
			currentState=States.Move
		"Jump":
			animationPlayer.play("Jump")
			animationPlayer.seek(currentAnimation)
			currentState=States.Jump
		"Fall":
			animationPlayer.play("Jump")
			animationPlayer.seek(0.8)
			currentState=States.Fall
		"Dash":
			animationPlayer.play("Dash")
			animationPlayer.seek(currentAnimation)
			currentState=States.Dash
		
func _on_Firing_timeout():
	shot_ended()

func _on_ShotTimer_timeout():
	can_shoot=true

func _on_AnimationPlayer_animation_finished(_Dash):
	can_dash=true
	currentState=States.Idle
	lastState="Idle"
