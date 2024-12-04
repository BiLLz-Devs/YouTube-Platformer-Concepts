extends PlayerState

const ledgeReleaseXNudge = 1
const ledgeReleaseYNudge = 5
var ledgeGrabFinalPosiion = Vector2.ZERO
var ledgeGrabSnapPosition = Vector2.ZERO

var climbingUp = false

func EnterState():
	# Set the label
	Name = "LedgeGrab"
	if (Player.RCLedgeLeftLower.is_colliding()):
		Player.ledgeDirection = Vector2.LEFT
	elif (Player.RCLedgeRightLower.is_colliding()):
		Player.ledgeDirection = Vector2.RIGHT
	
	ledgeGrabFinalPosiion = Vector2(10 * Player.ledgeDirection.x, -14)


func ExitState():
	pass


func Update(delta: float):
	Player.climbStamina -= Player.GrabStaminaCost
	HandleJumpUp()
	HandleClimbUp()
	HandleLedgeRelease()
	HandleAnimations()


func HandleLedgeRelease():
	if (Player.keyDown or (Player.climbStamina <= 0)):
		Player.global_position += Vector2(ledgeReleaseXNudge * Player.ledgeDirection.x * -1,
			ledgeReleaseYNudge)
		Player.ChangeState(States.Fall)


# Functionality for if the player jumps from a grab
func HandleJumpUp():
	if (Player.keyJumpPressed):
		Player.global_position += Vector2(ledgeReleaseXNudge * Player.ledgeDirection.x * -2, ledgeReleaseYNudge)
		Player.ChangeState(States.Jump)


# Functionality for if the player climbs from a grab
func HandleClimbUp():
	if (Player.keyUpPressed):
		climbingUp = true
		Player.Animator.play("LedgeClimb")


func HandleAnimations():
	if (!climbingUp): Player.Animator.play("LedgeGrab")
	Player.Sprite.flip_h = (Player.ledgeDirection.x < 0)


func _on_animator_animation_finished(anim_name: StringName) -> void:
	if (anim_name == "LedgeClimb"):
		Player.global_position += ledgeGrabFinalPosiion
		#Player.global_position += Vector2(ledgeReleaseXNudge * Player.ledgeDirection.x * -1, ledgeReleaseYNudge)
		climbingUp = false
		Player.ChangeState(States.Idle)
