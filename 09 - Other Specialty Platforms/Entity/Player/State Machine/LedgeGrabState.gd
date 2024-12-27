extends PlayerState

const ledgeReleaseXNudge = 1
const ledgeReleaseYNudge = 5

var ledgeGrabSnapPosition = Vector2.ZERO

func EnterState():
	# Set the label
	Name = "LedgeGrab"
	
	if (Player.RCLedgeLeftLower.is_colliding()):
		Player.ledgeDirection = Vector2.LEFT
	elif (Player.RCLedgeRightLower.is_colliding()):
		Player.ledgeDirection = Vector2.RIGHT
	
	ledgeGrabSnapPosition = Vector2(Player.cornerGrabPosition.x + (Player.ledgeDirection.x * -1), Player.cornerGrabPosition.y + 6)
	Player.global_position = ledgeGrabSnapPosition


func ExitState():
	pass


func Update(delta: float):
	# Set velocity and ledge snap in case of any accidental nudging
	Player.velocity = Vector2.ZERO
	Player.global_position = ledgeGrabSnapPosition
	
	Player.climbStamina -= Player.GrabStaminaCost
	HandleJumpUp()
	HandleClimbUp()
	HandleLedgeRelease()
	HandleAnimations()


func HandleLedgeRelease():
	if (Player.keyDown or (Player.climbStamina <= 0)
		or ((Player.resettingPlatform != null) and (Player.resettingPlatform.currentState == Player.resettingPlatform.PlatformStates.Broken))):
		Player.global_position += Vector2(ledgeReleaseXNudge * Player.ledgeDirection.x * -1,
			ledgeReleaseYNudge)
		Player.ChangeState(States.Fall)


# Functionality for if the player jumps from a grab
func HandleJumpUp():
	if (Player.keyJumpPressed):
		Player.global_position += Vector2(ledgeReleaseXNudge * Player.ledgeDirection.x * -2, -ledgeReleaseYNudge)
		Player.ChangeState(States.Jump)
		return


# Functionality for if the player climbs from a grab
func HandleClimbUp():
	if (Player.keyUpPressed):
		Player.ChangeState(States.LedgeClimb)


func HandleAnimations():
	Player.Animator.play("LedgeGrab")
	Player.Sprite.flip_h = (Player.ledgeDirection.x < 0)
