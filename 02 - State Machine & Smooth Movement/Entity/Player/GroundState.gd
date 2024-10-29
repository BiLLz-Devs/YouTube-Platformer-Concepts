extends PlayerState


func EnterState():
	# Set the state label
	Player.currentStateDebug = "Ground"


func ExitState():
	pass


func Update(delta: float):
	# Allow the player to jump
	Player.jumps = 0
	
	# Handle the movments
	Player.HorizontalMovement()
	HandleJump()
	HandleFalling()
	HandleAnimations()


func HandleAnimations():
	if (Player.velocity.x != 0):
		Player.Animator.play("Run")
	if (Player.velocity.x == 0):
		Player.Animator.play("Idle")
	Player.HandleFlipH()


func HandleFalling():
	# See if we walked off a ledge
	if (!Player.is_on_floor()):
		Player.ChangeState(States.Fall)


func HandleJump():
	# Handle jump
	if ((Player.keyJumpPressed) && (Player.jumps < Player.MaxJumps)):
		Player.jumpSpeed = Player.JumpVelocity
		Player.ChangeState(States.Jump)
