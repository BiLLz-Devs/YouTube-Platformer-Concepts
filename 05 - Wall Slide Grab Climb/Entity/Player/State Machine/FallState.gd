extends PlayerState

func EnterState():
	# Set the label
	Name = "Fall"


func ExitState():
	pass


func Update(delta: float):
	# Handle state physics
	Player.GetCanWallClimb()
	Player.HandleGravity(delta, Player.GravityFall)
	Player.HorizontalMovement(Player.AirAcceleration, Player.AirDeceleration)
	Player.HandleLanding()
	Player.HandleJump()
	Player.HandleJumpBuffer()
	Player.HandleWallJump()
	Player.HandleWallSlide()
	Player.HandleWallGrab()
	HandleAnimations()


func HandleAnimations():
	Player.Animator.play("Fall")
	Player.HandleFlipH()
