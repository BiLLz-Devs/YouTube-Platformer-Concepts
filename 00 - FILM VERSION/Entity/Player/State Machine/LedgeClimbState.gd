extends PlayerState

var ledgeGrabFinalPosiion = Vector2.ZERO

func EnterState():
	# Set the label
	Name = "LedgeClimb"
	if (Player.RCLedgeLeftLower.is_colliding()):
		Player.ledgeDirection = Vector2.LEFT
	elif (Player.RCLedgeRightLower.is_colliding()):
		Player.ledgeDirection = Vector2.RIGHT
	
	ledgeGrabFinalPosiion = Vector2(10 * Player.ledgeDirection.x, -14)


func ExitState():
	pass


func Update(delta: float):
	HandleClimbUp()
	HandleAnimations()


# Functionality for if the player climbs from a grab
func HandleClimbUp():
	Player.Animator.play("LedgeClimb")


func HandleAnimations():
	Player.Sprite.flip_h = (Player.ledgeDirection.x < 0)


func _on_animator_animation_finished(anim_name: StringName) -> void:
	if (anim_name == "LedgeClimb"):
		Player.global_position += ledgeGrabFinalPosiion
		Player.ChangeState(States.Idle)
