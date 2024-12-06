extends PlayerState

var lastWallDirection
var shouoldEnableWallKick

func EnterState():
	# Set the label
	Name = "WallJump"
	Player.velocity.y = Player.WallJumpVelocity
	ShouldOnlyJumpButtonWallKick(false)
	lastWallDirection = Player.wallDirection


func ExitState():
	pass


func Update(delta: float):
	# Handle state physics
	Player.GetWallDirection() # Update the wall direction to see if we hit a wall preaturely
	Player.HandleGravity(delta, Player.GravityJump)
	HandleWallKickMovement()
	HandleWallJumpEnd(delta)
	Player.HandleDash()
	HandleAnimations()


func HandleAnimations():
	if ((!Player.keyLeft and !Player.keyRight) and shouoldEnableWallKick):
		Player.Animator.play("WallKick")
		Player.Sprite.flip_h = (Player.velocity.x > 1)
	else:
		Player.Animator.play("WallJump")
		Player.Sprite.flip_h = (Player.velocity.x < 1)


# Switches states to fall once the player y velocity hits a certain value
func HandleWallJumpEnd(delta):
	if (Player.velocity.y >= Player.WallJumpYSpeedPeak):
		Player.ChangeState(States.Fall)
		
	# Cancel if we hit another wall
	if ((Player.wallDirection != lastWallDirection) and (Player.wallDirection != Vector2.ZERO)):
		#Player.velocity.y = Player.WallJumpEndYVelocity
		Player.ChangeState(States.Fall)


# This function determines if only pressing jump results in a small kick or not
# if true, a true wall jump only occurs if keyRIght or keyLeft is pressed as well as jump
func ShouldOnlyJumpButtonWallKick(shouldEnable: bool):
	shouoldEnableWallKick = shouldEnable
	if (shouldEnable):
		if (Player.keyLeft or Player.keyRight):
			Player.velocity.x = Player.WallJumpHSpeed * Player.wallDirection.x * -1
		else:
			if (Player.jumps == Player.MaxJumps):
				Player.velocity.x = Player.WallJumpHSpeed * Player.wallDirection.x * -1
			else:
				Player.ChangeState(States.Fall)
	else:
		Player.velocity.x = Player.WallJumpHSpeed * Player.wallDirection.x * -1


# When wall kicking, allows the player to move away from the wall with the moveLeft/moveRight key
func HandleWallKickMovement():
	if (!Player.keyLeft and !Player.keyRight):
		Player.velocity.x = move_toward(Player.velocity.x, 0, Player.WallJumpAcceleration) # slows the player to 0
	else:
		# Allow the player to move to the opposite direction of the wall at full speed
		if ((lastWallDirection == Vector2.LEFT and Player.keyRight)):
			Player.HorizontalMovement(Player.WallJumpAcceleration, Player.WallJumpAcceleration)
		elif ((lastWallDirection == Vector2.RIGHT and Player.keyLeft)):
			Player.HorizontalMovement(Player.WallJumpAcceleration, Player.WallJumpAcceleration)
		#elif ((lastWallDirection == Vector2.LEFT and Player.keyLeft)):
			#pass#Player.velocity.x = move_toward(Player.velocity.x,  0, Player.WallJumpAcceleration)
		#elif ((lastWallDirection == Vector2.RIGHT and Player.keyRight)):
			#pass#Player.velocity.x = move_toward(Player.velocity.x,  0, Player.WallJumpAcceleration)
