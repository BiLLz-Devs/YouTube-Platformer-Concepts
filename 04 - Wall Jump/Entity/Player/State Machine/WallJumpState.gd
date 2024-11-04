extends PlayerState

'''
Wall jumping will have a few cases
1) basic wall jump where hitting peak of jump gives back control (y-value can be modified)
	- also includes cancelling upon hitting a wall
	- also includes jump buffering
	- allows wall jumping by just hitting jump key against a wall
2) just jumping kicks you slightly off the wall and then continue vertically (Celeste)
	- if there is any movement input, then jump like #1
	- cancels upon hitting a wall
	- jump buffering
'''

var targetSpeed
var shouldDecelerate = false
var lastWallDirection

func EnterState():
	# Set the label
	Name = "WallJump"
	Player.velocity.y = Player.WallJumpVelocity
	if (Player.keyLeft or Player.keyRight):
		Player.velocity.x = Player.WallJumpHSpeed * Player.wallDirection.x * -1
	else:
		#if (Player.jumps < Player.MaxJumps):
		Player.velocity.x = Player.WallJumpHSpeed/1.5 * Player.wallDirection.x * -1
		#else:
			#Player.ChangeState(States.Fall)
	lastWallDirection = Player.wallDirection


func ExitState():
	pass


func Update(delta: float):
	# Handle state physics
	Player.GetWallDirection() # Update the wall direction to see if we hit a wall preaturely
	Player.HandleGravity(delta, Player.GravityJump)
	if (!Player.keyLeft and !Player.keyRight):
		Player.velocity.x = move_toward(Player.velocity.x, 0, Player.WallJumpDeceleration) # slows the player to 0
	else:
		if ((lastWallDirection == Vector2.LEFT and Player.keyRight)):
			Player.HorizontalMovement()
		elif ((lastWallDirection == Vector2.RIGHT and Player.keyLeft)):
			Player.HorizontalMovement()
	HandleWallJumpPeak(delta)
	HandleWallCancel()
	HandleAnimations()
	#print("Laast: " + str(lastWallDirection) + " MoveDirectionX: " + str(Player.moveDirectionX))


func HandleAnimations():
	Player.Animator.play("WallJump")
	if (!Player.keyLeft and !Player.keyRight):
		Player.Sprite.flip_h = (Player.velocity.x < 1)
	else:
		Player.Sprite.flip_h = (Player.velocity.x > 1)


# Switches states to fall once the player y velocity hits a certain value
func HandleWallJumpPeak(delta):
	if (Player.velocity.y >= Player.WallJumpYSpeedPeak):
		Player.ChangeState(States.Fall)


# Cancels the wall jump and goes to fall state if we hit a wall
# This gives the player back control of the character
func HandleWallCancel():
	if ((Player.wallDirection != lastWallDirection) and (Player.wallDirection != Vector2.ZERO)):
		Player.velocity.y = 15
		Player.ChangeState(States.Fall)
