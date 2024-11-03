extends PlayerState

var targetSpeed
var shouldDecelerate = false

func EnterState():
	# Set the label
	Name = "WallJump"
	Player.velocity.y = Player.WallJumpVelocity
	targetSpeed = Player.WallJumpSpeed * Player.wallDirection.x * -1


func ExitState():
	pass


func Update(delta: float):
	# Handle state physics
	Player.HandleGravity(delta, Player.GravityFall)
	Player.velocity.x = move_toward(Player.velocity.x, targetSpeed, Player.Acceleration)
	HandleWallJumpPeak(delta)
	HandleAnimations()


func HandleAnimations():
	Player.Animator.play("WallJump")
	Player.HandleFlipH()


func HandleWallJumpPeak(delta):
	if (Player.velocity.y >= 0):
		Player.ChangeState(States.Fall)
