extends CharacterBody2D

#region Player Variables

# Nodes
@onready var Sprite = $Sprite
@onready var Animator = $Animator
@onready var Collider = $Collider

# Physics Variables
const RunSpeed = 120
const Acceleration = 40
const Gravity = 600
const JumpVelocity = -240
const MaxJumps = 1

var moveSpeed = RunSpeed
var moveDirection = 0
var jumps = 0
var facing = 1

# Input Variables
var keyUp = false
var keyDown = false
var keyLeft = false
var keyRight = false
var keyJump = false
var keyJumpPressed = false

#endregion

func _ready():
	pass


func _physics_process(delta: float) -> void:
	# Get input states
	GetInputStates()
	
	# Handle Gravity
	if (!is_on_floor()): # Not on the floor, aka falling
		velocity.y += Gravity * delta
	else: # on the floor
		jumps = 0

	#Handle Movements
	HorizontalMovement()
	HandleJump()
	
	# Commit movement
	move_and_slide()
	
	# Handle Animation
	HandleAnimation()


func HorizontalMovement():
	moveDirection = Input.get_axis("Left", "Right")
	velocity.x = move_toward(velocity.x, moveDirection * moveSpeed, Acceleration)


func HandleJump():
	if (keyJumpPressed):
		if (jumps < MaxJumps):
			velocity.y = JumpVelocity
			jumps += 1


func GetInputStates():
	keyUp = Input.is_action_pressed("Up")
	keyDown = Input.is_action_pressed("Down")
	keyLeft = Input.is_action_pressed("Left")
	keyRight = Input.is_action_pressed("Right")
	keyJump = Input.is_action_pressed("Jump")
	keyJumpPressed = Input.is_action_just_pressed("Jump")
	
	if (keyLeft): facing = -1
	if (keyRight): facing = 1


func HandleAnimation():
	# Handle the sprite x-scale
	Sprite.flip_h = (facing < 0)
	
	# Handle horizontal movements
	if (is_on_floor()):
		if (velocity.x != 0):
			Animator.play("Run")
		else:
			Animator.play("Idle")
	else:
		if (velocity.y < 0):
			Animator.play("Jump")
		else:
			Animator.play("Fall")
