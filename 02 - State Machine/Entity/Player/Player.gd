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
const Deceleration = 50
const Gravity = 300
const JumpVelocity = -150
const VariableJumpMultiplier = 0.5
const MaxJumps = 2

var moveSpeed = RunSpeed
var jumpSpeed = JumpVelocity
var moveDirectionX = 0
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

#endregion


func _ready():
	# Initialize the state machine
	for state in States.get_children():
		state.States = States
		state.Player = self
	previousState = States.Fall
	currentState = States.Fall


func _draw():
	currentState.Draw()


func _physics_process(delta: float) -> void:
	# Get input states
	GetInputStates()
	
	# Update the current state
	currentState.Update(delta)

	# Commit movement
	move_and_slide()


func HorizontalMovement(acceleration: float = Acceleration, deceleration: float = Deceleration):
	moveDirectionX = Input.get_axis("Left", "Right")
	if (moveDirectionX != 0):
		velocity.x = move_toward(velocity.x, moveDirectionX * moveSpeed, Acceleration)
	else:
		velocity.x = move_toward(velocity.x, moveDirectionX * moveSpeed, Deceleration)


func HandleFalling():
	# See if we walked off a ledge
	if (!is_on_floor()):
		ChangeState(States.Fall)


func HandleJump():
	# Handle jump
	if ((keyJumpPressed) && (jumps < MaxJumps)):
		ChangeState(States.Jump)


func HandleLanding():
	if (is_on_floor()):
		ChangeState(States.Idle)


func GetInputStates():
	keyUp = Input.is_action_pressed("Up")
	keyDown = Input.is_action_pressed("Down")
	keyLeft = Input.is_action_pressed("Left")
	keyRight = Input.is_action_pressed("Right")
	keyJump = Input.is_action_pressed("Jump")
	keyJumpPressed = Input.is_action_just_pressed("Jump")
	
	if (keyLeft): facing = -1
	if (keyRight): facing = 1
	# Handle the sprite x-scale
	Sprite.flip_h = (facing < 0)


func ChangeState(nextState):
	if nextState != null:
		previousState = currentState 
		currentState = nextState
		previousState.ExitState()
		currentState.EnterState()
		#print("State Changed From: " + previousState.Name + " To: " + currentState.Name)


func HandleFlipH():
	Sprite.flip_h = (facing < 1)
