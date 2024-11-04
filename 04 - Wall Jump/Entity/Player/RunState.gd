extends PlayerState


func EnterState():
	# Set the state label
	Name = "Run"


func ExitState():
	pass


func Update(delta: float):
	# Handle the movments
	Player.HorizontalMovement()
	Player.HandleJump()
	Player.HandleFalling()
	HandleAnimations()
	HandleIdle()


func HandleAnimations():
	Player.Animator.play("Run")
	Player.HandleFlipH()


func HandleIdle():
	if (Player.moveDirectionX == 0):
		Player.ChangeState(States.Idle)
