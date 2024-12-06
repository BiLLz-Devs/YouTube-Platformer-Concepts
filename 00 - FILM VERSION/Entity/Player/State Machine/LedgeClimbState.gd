extends PlayerState

const LedgeFinalPosX = 10
const LedgeFinalPosY = -14

var ledgeGrabFinalPosition = Vector2.ZERO

func EnterState():
	# Set the label
	Name = "LedgeClimb"
	
	# Get the ledge direction
	if (Player.RCLedgeLeftLower.is_colliding()):
		Player.ledgeDirection = Vector2.LEFT
	if (Player.RCLedgeRightLower.is_colliding()):
		Player.ledgeDirection = Vector2.RIGHT
	
	ledgeGrabFinalPosition = Vector2(LedgeFinalPosX * Player.ledgeDirection.x, LedgeFinalPosY)


func ExitState():
	pass


func Update(delta: float):
	HandleClimbUp()
	HandleAnimations()


func HandleClimbUp():
	Player.Animator.play("LedgeClimb")


func HandleAnimations():
	Player.Sprite.flip_h = (Player.ledgeDirection.x < 0)


func _on_animator_animation_finished(anim_name: StringName) -> void:
	if (anim_name == "LedgeClimb"):
		Player.global_position += ledgeGrabFinalPosition
		Player.ChangeState(States.Idle)
