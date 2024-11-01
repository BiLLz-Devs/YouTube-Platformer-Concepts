extends PlayerState

func EnterState():
	# Set the label
	Player.currentStateDebug = "Idle"


func ExitState():
	pass


func Update(delta: float):
	Player.HandleFalling()
	Player.HandleJump()
	Player.HorizontalMovement()
	if (Player.moveDirectionX != 0):
		print("INPUT")
		Player.ChangeState(Player.States.Run)


func HandleAnimations():
	Player.Animator.play("Idle")
	Player.HandleFlipH()
