extends PlayerState

func EnterState():
	# Set the label
	Name = "Idle"


func ExitState():
	pass


func Update(delta: float):
	Player.HandleFalling()
	Player.HorizontalMovement()
	Player.HandleJump()
	Player.HandleDash()
	if (Player.moveDirectionX != 0):
		Player.ChangeState(States.Run)
	HandleAnimations()


func HandleAnimations():
	Player.Animator.play("Idle")
	Player.HandleFlipH()
