class_name Jump extends PlayerState

func EnterState():
	# Set the state label
	Player.currentStateDebug = "Jump"
	Player.velocity.y = Player.jumpSpeed


func ExitState():
	pass


func Update(delta: float):	
	# Handle State physics
	Player.velocity.y += Player.Gravity * delta
	Player.HandleJump()
	HandleJumpToFall()
	Player.HorizontalMovement()	
	HandleAnimations()


func HandleAnimations():
	Player.Animator.play("Jump")
	Player.HandleFlipH()


func HandleJump():
	# See if the jump key is held, if not, slash the momentum
	if (!Player.keyJump):
		Player.velocity.y *= Player.VariableJumpMultiplier
		Player.ChangeState(States.JumpPeak)


func HandleJumpToFall():
	if (Player.velocity.y > 0):
		Player.ChangeState(States.JumpPeak)
