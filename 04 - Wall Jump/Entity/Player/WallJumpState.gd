extends PlayerState

func EnterState():
	# Set the label
	Name = "WallJump"
	Player.velocity.y = Player.WallJumpVelocity
	Player.velocity.x = Player.WallJumpSpeed * Player.wallDirection.x * -1


func ExitState():
	pass


func Update(delta: float):
	# Handle state physics
	Player.HandleGravity(delta, Player.GravityFall)
	HandleWallJumpPeak()
	HandleAnimations()


func HandleAnimations():
	Player.Animator.play("WallJump")
	Player.HandleFlipH()


func HandleWallJumpPeak():
	if (Player.velocity.y >= 0):
		Player.ChangeState(States.Fall)
