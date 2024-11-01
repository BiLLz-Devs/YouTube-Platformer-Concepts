extends PlayerState

func EnterState():
	# Set the label
	Name = "Fall"


func ExitState():
	pass


func Update(delta: float):
	# Handle state physics
	Player.velocity.y += Player.Gravity * delta
	Player.HorizontalMovement()
	Player.HandleLanding()
	HandleAnimations()


func HandleAnimations():
	Player.Animator.play("Fall")
	Player.HandleFlipH()
