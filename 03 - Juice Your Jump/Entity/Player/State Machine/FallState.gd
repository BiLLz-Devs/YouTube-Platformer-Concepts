extends PlayerState

func EnterState():
	# Set the label
	Name = "Fall"


func ExitState():
	pass


func Update(delta: float):
	# Handle state physics
	Player.HandleGravity(delta, Player.GravityFall)
	Player.HorizontalMovement()
	Player.HandleLanding()
	Player.HandleJump()
	Player.HandleJumpBuffer()
	HandleAnimations()


func HandleAnimations():
	Player.Animator.play("Fall")
	Player.HandleFlipH()
