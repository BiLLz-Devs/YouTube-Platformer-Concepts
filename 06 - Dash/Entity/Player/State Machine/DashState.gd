extends PlayerState

func EnterState():
	# Set the label
	Name = "Dash"
	Player.dashDirection = Player.GetDashDirection()
	Player.DashParticles.restart()
	Player.velocity = Player.dashDirection.normalized() * Player.DashSpeed
	Player.DashTimer.start(Player.DashTime)
	print("Dash Direction: " + str(Player.dashDirection) + "; Dash Speed: " + str(Player.velocity)
		+ "; Facing: " + str(Player.facing))


func ExitState():
	pass


func Update(delta: float):
	print(Player.DashTimer.time_left)
	HandleAnimations()


func HandleAnimations():
	Player.HandleWallGrab()
	HandleDashEnd()
	Player.Animator.play("Dash")
	Player.HandleFlipH()


func HandleDashEnd():
	if (Player.DashTimer.time_left <= 0):
		Player.velocity *= 0.5
		Player.ChangeState(States.Fall)
