extends CharacterBody2D

#region Player Variables

# Nodes
@onready var Sprite = $Sprite
@onready var Animator = $Animator
@onready var Collider = $Collider
@onready var States = $StateMachine
@onready var CoyoteTimer = $Timers/CoyoteTime
@onready var JumpBufferTimer = $Timers/JumpBuffer

# Physics Variables
const RunSpeed = 120
const Acceleration = 40
const Deceleration = 50
const GravityJump = 600
const GravityFall = 700
const MaxFallVelocity = 700
const JumpVelocity = -240
const VariableJumpMultiplier = 0.5
const MaxJumps = 1
const CoyoteTime = 0.1 # 6 Frames: FPS / (desired frames) = Time in seconds
const JumpBufferTime = 0.15  # 9 Frames: FPS / (desired frames) = Time in seconds

var moveSpeed = RunSpeed
var jumpSpeed = JumpVelocity
var moveDirectionX = 0
var jumps = 0
#var jumpBuffered = false
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

#region Game Loop Functions

func _ready():
	# Initialize the state machine
	for state in States.get_children():
		state.States = States
		state.Player = self
	previousState = States.Fall
	currentState = States.Fall
	
	#Set some important variables
	CoyoteTimer.one_shot = true
	JumpBufferTimer.one_shot = true


func _draw():
	currentState.Draw()


func _physics_process(delta: float) -> void:
	# Get input states
	GetInputStates()
	
	# Update the current state
	currentState.Update(delta)
	HandleMaxFallVelocity()
	# Commit movement
	move_and_slide()


#endregion


#region Player Functions


func HorizontalMovement(acceleration: float = Acceleration, deceleration: float = Deceleration):
	moveDirectionX = Input.get_axis("Left", "Right")
	if (moveDirectionX != 0):
		velocity.x = move_toward(velocity.x, moveDirectionX * moveSpeed, acceleration)
	else:
		velocity.x = move_toward(velocity.x, moveDirectionX * moveSpeed, deceleration)


func HandleFalling():
	# See if we walked off a ledge
	if (!is_on_floor()):
		# Start the coyote timer
		CoyoteTimer.start(CoyoteTime)
		ChangeState(States.Fall)


func HandleMaxFallVelocity():
	if (velocity.y > MaxFallVelocity): velocity.y = MaxFallVelocity


func HandleJumpBuffer():
	if (keyJumpPressed):
		JumpBufferTimer.start(JumpBufferTime)


func HandleGravity(delta, gravity: float = GravityJump):
	velocity.y += gravity * delta


func HandleJump():
	# Handle jump
	if (is_on_floor()):
		if (jumps < MaxJumps):
			if (keyJumpPressed or JumpBufferTimer.time_left > 0):
				jumps += 1
				JumpBufferTimer.stop()
				ChangeState(States.Jump)
	else:
		# Handle air jumps if MaxJumps > 1, first jump must be on the ground
		if ((jumps < MaxJumps) and (jumps > 0) and keyJumpPressed):
			jumps += 1
			ChangeState(States.Jump)
		
		# Handle coyote time jumps
		if (CoyoteTimer.time_left > 0):
			if ((keyJumpPressed) and (jumps < MaxJumps)):
				CoyoteTimer.stop()
				jumps += 1
				ChangeState(States.Jump)


func HandleLanding():
	if (is_on_floor()):
		jumps = 0
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
		return


func HandleFlipH():
	Sprite.flip_h = (facing < 1)


#endregion
