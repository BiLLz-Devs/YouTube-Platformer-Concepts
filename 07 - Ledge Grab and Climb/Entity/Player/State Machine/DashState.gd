extends PlayerState


const DashSquish = 0.25
var DistortionEffect = preload("res://Entity/Player/DashDistortion.tscn")

func EnterState():
	# Set the label
	Name = "Dash"
	Player.dashDirection = Player.GetDashDirection()
	Player.DashParticles.restart()
	Player.velocity = Player.dashDirection.normalized() * Player.DashSpeed
	Player.DashTimer.start(Player.DashTime)
	Player.SetSquish(abs(Player.dashDirection.y * DashSquish), abs(Player.dashDirection.x * DashSquish), 0.05)
	var _distortion = DistortionEffect.instantiate()
	_distortion.global_position = Player.global_position
	get_tree().root.get_node("World").add_child(_distortion)
	Player.Animator.play("Dash")
	Player.HandleFlipH()
	#print("Dash Direction: " + str(Player.dashDirection) + " Squish: " + str(Vector2(Player.squishX, Player.squishY)))


func ExitState():
	pass


func Update(delta: float):
	HandleDashEnd()
	HandleAnimations()


func HandleDashEnd():
	if (Player.DashTimer.time_left <= 0):
		Player.DashTimer.stop()
		Player.velocity *= 0.5
		Player.ChangeState(States.Fall)


func HandleAnimations():
	Player.Animator.play("Dash")
	Player.HandleFlipH()
