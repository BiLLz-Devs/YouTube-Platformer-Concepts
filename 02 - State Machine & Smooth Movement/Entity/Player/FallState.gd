extends PlayerState

func EnterState():
	# Set the label
	Player.currentStateDebug = "Fall"


func ExitState():
	pass


func Update(delta: float):
	# Handle state physics
	Player.velocity.y += Player.Gravity * delta
	Player.HorizontalMovement()
	HandleLanding()
	HandleAnimations()


func HandleAnimations():
	Player.Animator.play("Fall")
	Player.HandleFlipH()


func HandleLanding():
	if (Player.is_on_floor()):
		Player.ChangeState(States.Ground)
