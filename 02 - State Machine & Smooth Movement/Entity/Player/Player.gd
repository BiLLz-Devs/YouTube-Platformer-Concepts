extends CharacterBody2D

#region Player Variables

# Nodes
@onready var Sprite = $Sprite
@onready var Animator = $Animator
@onready var Collider = $Collider
@onready var States = $StateMachine

# Physics Variables
const RunSpeed = 150
const Acceleration = 40
const Gravity = 300
const JumpVelocity = -150
const VariableJumpMultiplier = 0.5
const MaxJumps = 2

var moveSpeed = RunSpeed
var jumpSpeed = JumpVelocity
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

# State Machine
var currentState = null
var previousState = null
var currentStateDebug = "NULL"

#endregion

#endregion

func _ready():
	# Initialize the state machine
	for state in States.get_children():
		state.States = States
		state.Player = self
	previousState = States.Fall
	currentState = States.Fall


func _physics_process(delta: float) -> void:
	# Get input states
	GetInputStates()
	
	# Update the current state
	currentState.Update(delta)

	# Commit movement
	move_and_slide()


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


func ChangeState(nextState):
	if nextState != null:
		previousState = currentState 
		currentState = nextState
		print("State Changed To: " + currentStateDebug)
		previousState.ExitState()
		currentState.EnterState()


func HandleFlipH():
	Sprite.flip_h = (facing < 1)
