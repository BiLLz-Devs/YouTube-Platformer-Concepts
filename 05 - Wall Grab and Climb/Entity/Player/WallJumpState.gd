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
	Player.HandleGravity(delta, Player.Gravity)
	Player.velocity.x = move_toward(Player.velocity.x, 0, Player.Deceleration)
	print(str(Player.velocity))
	print("HERE")
	HandleWallJumpPeak()
	HandleAnimations()


func HandleAnimations():
	Player.Animator.play("WallJump")
	Player.HandleFlipH()


func HandleWallJumpPeak():
	if (Player.velocity.y >= 1.5):
		Player.ChangeState(States.Fall)
