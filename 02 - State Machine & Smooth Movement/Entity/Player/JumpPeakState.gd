class_name JumpTransition extends PlayerState

func EnterState():
	# Set the state label
	Player.currentStateDebug = "JumpTransition"
	Player.ChangeState(States.Fall)


func ExitState():
	pass


func Update(delta: float):	
	# Handle State physics
	# Player.velocity.y += Player.Gravity * delta
	Player.HorizontalMovement()	
	HandleAnimations()


func HandleAnimations():
	Player.Animator.play("Jump")
	Player.HandleFlipH()
