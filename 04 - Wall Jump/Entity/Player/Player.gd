extends CharacterBody2D

#region Player Variables

# Nodes
@onready var Sprite = $Sprite
@onready var Animator = $Animator
@onready var Collider = $Collider
@onready var States = $StateMachine
@onready var CoyoteTimer = $Timers/CoyoteTime
@onready var JumpBufferTimer = $Timers/JumpBuffer
@onready var RCBottomLeft = $Raycasts/WallJump/BottomLeft
@onready var RCBottomRight = $Raycasts/WallJump/BottomRight

# Physics Variables
const RunSpeed = 125
const WallJumpSpeed = 125
const Acceleration = 40
const Deceleration = 50
const GravityJump = 300
const GravityFall = 350
const JumpVelocity = -170
const WallJumpVelocity = -130
const VariableJumpMultiplier = 0.5
const MaxJumps = 2
const CoyoteTime = 0.1 # 6 Frames: FPS / (desired frames) = Time in seconds
const JumpBufferTime = 0.15  # 9 Frames: FPS / (desired frames) = Time in seconds

var moveSpeed = RunSpeed
var jumpSpeed = JumpVelocity
var moveDirectionX = 0
var jumps = 0
var wallDirection: Vector2 = Vector2.ZERO
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


func HandleJumpBuffer():
	if (keyJumpPressed):
		JumpBufferTimer.start(JumpBufferTime)


func HandleGravity(delta, gravity: float = GravityJump):
	velocity.y += gravity * delta


func HandleJump():
	# Handle jump
	if (is_on_floor()):
		if ((keyJumpPressed) && (jumps < MaxJumps)):
			ChangeState(States.Jump)
		if (JumpBufferTimer.time_left > 0):
			JumpBufferTimer.stop()
			ChangeState(States.Jump)
	else:
		if (CoyoteTimer.time_left > 0):
			if ((keyJumpPressed) && (jumps < MaxJumps)):
				CoyoteTimer.stop()
				ChangeState(States.Jump)


func HandleWallJump():
	GetWallDirection()
	if (keyJumpPressed and wallDirection.x != 0):
		ChangeState(States.WallJump)


func HandleLanding():
	if (is_on_floor()):
		#JumpBufferTimer.stop()
		ChangeState(States.Idle)


func GetWallDirection():
	if (RCBottomLeft.is_colliding()):
		wallDirection = Vector2.LEFT
	elif (RCBottomRight.is_colliding()):
		wallDirection = Vector2.RIGHT
	else:
		wallDirection = Vector2.ZERO


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
	if (currentState.Name == "WallJump"):
		Sprite.flip_h = (wallDirection.x < 1)
	else:
		Sprite.flip_h = (facing < 1)


#endregion
