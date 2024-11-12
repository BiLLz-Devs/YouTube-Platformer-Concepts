extends PlayerState


func EnterState():
	Name = "WallClimb"


func ExitState():
	pass


func Draw():
	pass


func Update(delta):
	Player.GetCanWallClimb()
	Player.climbStamina -= Player.ClimbStaminaCost
	HandleClimbMovement()
	Player.HandleWallRelease()
	Player.HandleWallJump()
	HandleAnimations()


func HandleClimbMovement():
	if (Player.keyClimb):
		if (Player.wallClimbDirection != Vector2.ZERO):
			if (Player.keyUp and (Player.RCUpperLeft.is_colliding() or Player.RCUpperRight.is_colliding())):
				Player.velocity.y = -Player.ClimbSpeed
			elif (Player.keyDown and (Player.RCLowerLeft.is_colliding() or Player.RCLowerRight.is_colliding())):
				Player.velocity.y = Player.ClimbSpeed
			else:
				Player.ChangeState(States.WallGrab)
	else:
		Player.ChangeState(States.Fall)


func HandleAnimations():
	if (Player.velocity.y > 0):
		Player.Animator.speed_scale = -1
	else:
		Player.Animator.speed_scale = 1
	Player.Animator.play("WallClimb")
	Player.Sprite.flip_h = (Player.wallClimbDirection == Vector2.LEFT)
