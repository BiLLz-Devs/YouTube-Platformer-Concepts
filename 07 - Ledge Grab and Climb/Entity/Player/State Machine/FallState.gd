extends PlayerState

func EnterState():
	# Set the label
	Name = "Fall"


func ExitState():
	Player.SetSquish(1.10, 0.9)


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
	Player.HandleDash()
	HandleAnimations()


func HandleAnimations():
	Player.Animator.play("Fall")
	Player.HandleFlipH()
