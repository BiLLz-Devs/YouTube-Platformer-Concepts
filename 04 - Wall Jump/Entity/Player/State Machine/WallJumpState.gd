extends PlayerState

func EnterState():
	# Set the label
	Name = "WallJump"
	Player.velocity.y = Player.WallJumpVelocity


func ExitState():
	pass


func Update(delta: float):
	# Handle state physics
	Player.HandleGravity(delta, Player.GravityFall)
	Player.velocity.x = move_toward(Player.velocity.x, Player.WallJumpSpeed * Player.wallDirection.x * -1, Player.Acceleration)
	HandleWallJumpPeak()
	HandleAnimations()


func HandleAnimations():
	Player.Animator.play("WallJump")
	Player.HandleFlipH()


func HandleWallJumpPeak():
	if (Player.velocity.y >= 1):
		Player.ChangeState(States.Fall)
