extends PlayerState

func EnterState():
	# Set the label
	Name = "LedgeGrab"


func ExitState():
	pass


func Update(delta: float):
	HandleAnimations()


func HandleAnimations():
	Player.Animator.play("LedgeGrab")
	Player.HandleFlipH()
