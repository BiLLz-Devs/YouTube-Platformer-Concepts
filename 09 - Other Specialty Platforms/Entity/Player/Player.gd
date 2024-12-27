class_name PlayerController extends CharacterBody2D

#region Player Variables

#region Nodes
# Nodes
@onready var Sprite = $Sprite
@onready var Animator = $Animator
@onready var Collider = $Collider
@onready var States = $StateMachine

@onready var CoyoteTimer = $Timers/CoyoteTime
@onready var JumpBufferTimer = $Timers/JumpBuffer
@onready var DashTimer = $Timers/DashTimer
@onready var DashBuffer = $Timers/DashBuffer

@onready var Raycasts = $Raycasts
@onready var RCBottomLeft = $Raycasts/WallJump/BottomLeft
@onready var RCBottomRight = $Raycasts/WallJump/BottomRight
@onready var RCTopRight = $Raycasts/WallClimb/TopRight
@onready var RCTopLeft = $Raycasts/WallClimb/TopLeft
@onready var RCUpperLeft = $Raycasts/WallClimb/UpperLeft
@onready var RCUpperRight = $Raycasts/WallClimb/UpperRight
@onready var RCLowerLeft = $Raycasts/WallClimb/LowerLeft
@onready var RCLowerRight = $Raycasts/WallClimb/LowerRight

@onready var RCLedgeRightLower = $Raycasts/LedgeGrab/LedgeRightLower
@onready var RCLedgeRightUpper = $Raycasts/LedgeGrab/LedgeRightUpper
@onready var RCLedgeLeftLower = $Raycasts/LedgeGrab/LedgeLeftLower
@onready var RCLedgeLeftUpper = $Raycasts/LedgeGrab/LedgeLeftUpper

@onready var DashParticles = $GraphcisEffects/Dash/DashTrail

# Used to get the tilemap for layer snapping
# Alternatively we can use get_tree().root.get_node("Tiles")
@export var CollisionMap: TileMapLayer

#endregion

#region Physics Variables
# Physics Constants
const RunSpeed = 120
const WallJumpHSpeed = 120
const GroundAcceleration = 20
const GroundDeceleration = 25
const AirAcceleration = 15
const AirDeceleration = 20
const WallKickAcceleration = 4
const GravityJump = 600
const GravityFall = 700
const MaxFallVelocity = 300

const JumpVelocity = -240
const WallJumpVelocity = -190
const WallJumpAcceleration = 5
const WallJumpYSpeedPeak = 0 # y speed at which wall jumping gives control back to the player
const VariableJumpMultiplier = 0.5
const MaxJumps = 1
const CoyoteTime = 0.1 # 6 Frames: (desired frames) / FPS = Time in seconds
const JumpBufferTime = 0.15  # 9 Frames: (desired frames) / FPS = Time in seconds

const ClimbSpeed = 30
const MaxClimbStamina = 300 #stamina measured by frames and not with a timer as certain activites use stamina at different rate
const GrabStaminaCost = 1
const ClimbStaminaCost = 2
const WallSlideSpeed = 40

const MaxDashes = 1
const DashSpeed = 300
const DashDeceleration = 4
const DashTime = 0.15
const DashBufferTime = 0.075 # roughly 4.5 frames of buffer time
const DashDelayEffect = 30 # millisecond pause before dshing

# Physics Variables
var moveSpeed = RunSpeed
var Acceleration = GroundAcceleration
var Deceleration = GroundDeceleration
var moveDirectionX = 0
var movingPlatformSpeed = Vector2(0, 0)
var movingPlatformSpeedBonus = Vector2(0, 0)
var moveSpeedBonus = 0

var jumpSpeed = JumpVelocity
var jumps = 0

var wallDirection: Vector2 = Vector2.ZERO
var wallClimbDirection: Vector2 = Vector2.ZERO
var climbStamina = MaxClimbStamina

var dashes = 0
var dashDirection: Vector2
var facing = 1

var squishX = 1.0
var squishY = 1.0
var squishStep = 0.02 # how quickly to return to value

var ledgeDirection: Vector2 = Vector2.ZERO
var cornerGrabPosition = Vector2.ZERO
var canGrabLedge = true
var ResettingPlatformNudge = -8
var AdditionalLedgeClimbNudge = 0

var movingPlatform: MovingPlatform = null # For a future video
var resettingPlatform: ResettingPlatform = null # For falling when the resetting platform breaks

#endregion

#region Input
# Input Variables
var keyUp = false
var keyUpPressed = false
var keyDown = false
var keyLeft = false
var keyRight = false
var keyJump = false
var keyJumpPressed = false
var keyClimb = false
var keyDash = false

#endregion

#region State Machine
# State Machine
var currentState = null
var previousState = null
var nextState = null
#endregion

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
	UpdateRaycasts()
	# Update the current state
	currentState.Update(delta)
	HandleMaxFallVelocity()
	UpdateSquish()
	# Commit movement
	move_and_slide()
	movingPlatformSpeed = get_platform_velocity()


#endregion


#region Player Physics Functions


func HorizontalMovement(acceleration: float = Acceleration, deceleration: float = Deceleration):
	moveDirectionX = Input.get_axis("Left", "Right")
	var _targetSpeed = moveDirectionX * (moveSpeed) + movingPlatformSpeedBonus.x + moveSpeedBonus
	
	if (moveDirectionX != 0):
		velocity.x = move_toward(velocity.x, _targetSpeed, acceleration)
	else:
		velocity.x = move_toward(velocity.x, _targetSpeed, deceleration)


func HandleFalling():
	# See if we walked off a ledge
	if (!is_on_floor()):
		# Start the coyote timer
		CoyoteTimer.start(CoyoteTime)
		ChangeState(States.Fall)


func HandleMaxFallVelocity():
	if (velocity.y > MaxFallVelocity): velocity.y = MaxFallVelocity


func HandleJumpBuffer():
	if (keyJumpPressed and (CoyoteTimer.time_left <= 0)):
		JumpBufferTimer.start(JumpBufferTime)


func HandleGravity(delta, gravity: float = GravityJump):
	velocity.y += gravity * delta


func HandleJump():
	# Handle jump
	if (is_on_floor()):
		if (jumps < MaxJumps):
			if (keyJumpPressed):
				jumps += 1
				#velocity.x = movingPlatformSpeed.x
				ChangeState(States.Jump)
			if (JumpBufferTimer.time_left > 0):
				JumpBufferTimer.stop()
				#velocity.x = movingPlatformSpeed.x
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


func HandleWallJump():
	GetWallDirection()
	if ((keyJumpPressed or (JumpBufferTimer.time_left > 0)) and wallDirection.x != 0):
		ChangeState(States.WallJump)


func HandleLanding():
	if (is_on_floor()):
		jumps = 0
		dashes = 0
		climbStamina = MaxClimbStamina
		ChangeState(States.Idle)


func HandleWallGrab():
	if (wallClimbDirection != Vector2.ZERO):
		if (keyClimb and (climbStamina > 0)):
			ChangeState(States.WallGrab)


func HandleWallRelease():
	if (!keyClimb):
		ChangeState(States.Fall)
	elif (climbStamina <= 0):
		ChangeState(States.Fall)


func HandleWallSlide():
	if (((wallDirection == Vector2.LEFT and keyLeft) and (RCUpperLeft.is_colliding() and RCLowerLeft.is_colliding()))
		or ((wallDirection == Vector2.RIGHT and keyRight) and (RCUpperRight.is_colliding() and RCLowerRight.is_colliding()))):
		if (!keyJump):
			if (IsRayCastCollidingMovingPlatform(RCUpperLeft)
				or IsRayCastCollidingMovingPlatform(RCLowerLeft)
				or IsRayCastCollidingMovingPlatform(RCUpperRight)
				or IsRayCastCollidingMovingPlatform(RCLowerRight)):
				print("Trying to SLIDE on moving platform")
				return
			else:
				ChangeState(States.WallSlide)


func HandleDash():
	if (dashes < MaxDashes):
		if (keyDash):
			if (DashTimer.time_left <= 0):
				DashTimer.start(DashBufferTime)
				await DashTimer.timeout # this gives the player time to hit the correct dash input direction
				dashes += 1
				ChangeState(States.Dash)


func GetDashDirection() -> Vector2:
	var _dir = Vector2.ZERO
	if (!keyLeft and !keyRight and !keyUp and !keyDown):
		_dir = Vector2(facing, 0)
	else:
		_dir -= Vector2(Input.get_axis("Right", "Left"), Input.get_axis("Down", "Up"))
	return _dir


func HandleLedgeGrab():
	# Snap the player to the corner of the ledge
	# Get the tile data to find the top left or top right corner global_position
	var _tileSize = CollisionMap.tile_set.tile_size # Returns a Vector2 of the tile size
	var _tileSizeCorrection = (_tileSize / 2) as Vector2 # Adjusts for center position of tile to give us the corner of the tile
	var _collisionPoint # Where the raycast is colliding
	var _tileCoords # The coordinates of the colliding tile
	
	# Handle a left ledge
	if (RCLedgeLeftLower.is_colliding() and !RCLedgeLeftUpper.is_colliding()):
		if (facing == -1):
			if (RCLedgeLeftLower.get_collider().get_parent() is MovingPlatform):
				print("Trying to grab left MP LEDGE!")
				return
			if (RCLedgeLeftLower.get_collider() is ResettingPlatform):
				# Calculate the edge location
				resettingPlatform = RCLedgeLeftLower.get_collider()
				var _positionalAdjustment = Vector2(resettingPlatform.Collider.shape.extents.x, -resettingPlatform.Collider.shape.extents.y)
				
				cornerGrabPosition = resettingPlatform.global_position + _positionalAdjustment
				AdditionalLedgeClimbNudge = ResettingPlatformNudge
				resettingPlatform.currentState = resettingPlatform.PlatformStates.Breaking
				
				ChangeState(States.LedgeGrab)
			else:
				_collisionPoint = RCLedgeLeftLower.get_collision_point() # Get the colliding point
				_tileCoords = CollisionMap.local_to_map(_collisionPoint) # Convert to tilemap coordinates
				AdditionalLedgeClimbNudge = 0
				# Check if this is a one way collision
				# The following code gets the data of the ledge tile
				var _ledge = Vector2i(_tileCoords.x + facing, _tileCoords.y)
				var _tileData = CollisionMap.get_cell_tile_data(_ledge)
				if (_tileData and _tileData.get_custom_data("OneWay")):
					ChangeState(States.Fall)
					return
				else:
					cornerGrabPosition = CollisionMap.map_to_local(_tileCoords) - _tileSizeCorrection
					ChangeState(States.LedgeGrab)
	
	# Handle a right ledge
	if (RCLedgeRightLower.is_colliding() and !RCLedgeRightUpper.is_colliding()):
		if (facing == 1):
			if (RCLedgeRightLower.get_collider().get_parent() is MovingPlatform):
				print("Trying to grab right MP LEDGE!")
				return
			if (RCLedgeRightLower.get_collider() is ResettingPlatform):
				# Calculate the edge location
				resettingPlatform = RCLedgeRightLower.get_collider()
				var _positionalAdjustment = Vector2(-resettingPlatform.Collider.shape.extents.x, -resettingPlatform.Collider.shape.extents.y)
				
				cornerGrabPosition = resettingPlatform.global_position + _positionalAdjustment
				AdditionalLedgeClimbNudge = ResettingPlatformNudge
				resettingPlatform.currentState = resettingPlatform.PlatformStates.Breaking
				
				ChangeState(States.LedgeGrab)
			else:
				_collisionPoint = RCLedgeRightLower.get_collision_point() # Get the colliding point
				_tileCoords = CollisionMap.local_to_map(_collisionPoint) # Convert to tilemap coordinates
				AdditionalLedgeClimbNudge = ResettingPlatformNudge
				# Check if this is a one way collision
				# The following code gets the data of the ledge tile
				var _ledge = Vector2i(_tileCoords.x + facing, _tileCoords.y)
				var _tileData = CollisionMap.get_cell_tile_data(_ledge)
				if(_tileData and _tileData.get_custom_data("OneWay")):
					ChangeState(States.Fall)
					return
				else:
					cornerGrabPosition = CollisionMap.map_to_local(_tileCoords) - _tileSizeCorrection
					ChangeState(States.LedgeGrab)


func HandleOneWayDropThrough():
	if (keyDown):
		global_position += Vector2(0, 1)


#endregion


#region Player Utility Functions

func UpdateRaycasts():
	for child in Raycasts.get_children():
		if child is RayCast2D:
			child.force_raycast_update()
			#print("Updated: " + str(child))


func GetWallDirection():
	if (RCBottomLeft.is_colliding()):# and !(RCBottomLeft.get_collider().get_parent().is_class("MovingPlatform"))):
		wallDirection = Vector2.LEFT
	elif (RCBottomRight.is_colliding()):# and !(RCBottomRight.get_collider().get_parent().is_class("MovingPlatform"))):):
		wallDirection = Vector2.RIGHT
	else:
		wallDirection = Vector2.ZERO


func GetCanWallClimb():
	if (RCBottomLeft.is_colliding() and RCTopLeft.is_colliding()):
		if ((RCBottomLeft.get_collider().get_parent() is MovingPlatform)
			or (RCTopLeft.get_collider().get_parent() is MovingPlatform)):
			print("Trying to CLIMB a moving platform")
			wallClimbDirection = Vector2.ZERO
		else:
			wallClimbDirection = Vector2.LEFT
	elif (RCBottomRight.is_colliding() and RCTopRight.is_colliding()):
		if ((RCBottomRight.get_collider().get_parent() is MovingPlatform)
			or (RCTopRight.get_collider().get_parent() is MovingPlatform)):
			print("Trying to CLIMB a moving platform")
			wallClimbDirection = Vector2.ZERO
		else:
			wallClimbDirection = Vector2.RIGHT
	else:
		wallClimbDirection = Vector2.ZERO


func GetInputStates():
	keyUp = Input.is_action_pressed("Up")
	keyUpPressed = Input.is_action_just_pressed("Up")
	keyDown = Input.is_action_pressed("Down")
	keyLeft = Input.is_action_pressed("Left")
	keyRight = Input.is_action_pressed("Right")
	keyJump = Input.is_action_pressed("Jump")
	keyJumpPressed = Input.is_action_just_pressed("Jump")
	keyClimb = Input.is_action_pressed("Climb")
	keyDash = Input.is_action_just_pressed("Dash")
	
	if (keyLeft): facing = -1
	if (keyRight): facing = 1
	# Handle the sprite x-scale
	Sprite.flip_h = (facing < 0)


func ChangeState(nextState):
	if (nextState != null):
		if (currentState != nextState):
			previousState = currentState
			currentState.ExitState()
			currentState = null
			currentState = nextState
			currentState.EnterState()
			#print("STATE CHANGE: " + previousState.Name + " to " + currentState.Name)
		nextState = null


func IsRayCastCollidingMovingPlatform(_ray: RayCast2D) -> bool:
	if(_ray.is_colliding()):
		var _parent = _ray.get_collider().get_parent()
		if (_parent is MovingPlatform):
			return true
		else:
			return false
	else:
		return false


#endregion


#region Player Graphics Functions

func UpdateSquish():
	Sprite.scale.x = squishX
	Sprite.scale.y = squishY
	
	if (squishX != 1.0):
		squishX = move_toward(squishX, 1.0, squishStep)
	if (squishY != 1.0):
		squishY = move_toward(squishY, 1.0, squishStep)


func SetSquish(_squishX: float = 1.0, _squishY: float = 1.0, _step: float = 0.02):
	squishX = _squishX if (_squishX != 0) else 1
	squishY = _squishY if (_squishY != 0) else 1
	squishStep = _step


func HandleFlipH():
	Sprite.flip_h = (facing < 1)

#endregion
