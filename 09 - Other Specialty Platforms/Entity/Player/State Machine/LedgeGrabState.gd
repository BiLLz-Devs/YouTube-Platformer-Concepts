extends PlayerState

const ledgeReleaseXNudge = 1
const ledgeReleaseYNudge = 5

var cornerGrabPosition = Vector2.ZERO
var ledgeGrabSnapPosition = Vector2.ZERO

func EnterState():
	# Set the label
	Name = "LedgeGrab"
	if (Player.RCLedgeLeftLower.is_colliding()):
		Player.ledgeDirection = Vector2.LEFT
	elif (Player.RCLedgeRightLower.is_colliding()):
		Player.ledgeDirection = Vector2.RIGHT
	
	# Snap the player to the corner of the ledge
	# Get the tile data to find the top left or top right corner global_position
	var _tileSize = Player.CollisionMap.tile_set.tile_size # Returns a Vector2 of the tile size
	var _tileSizeCorrection = (_tileSize / 2) as Vector2 # Adjusts for center position of tile to give us the corner of the tile
	var _collisionPoint # Where the raycast is colliding
	var _tileCoords # The coordinates of the colliding tile
	
	if (Player.ledgeDirection == Vector2.LEFT):
		if (Player.RCLedgeLeftLower.is_colliding()):
			_collisionPoint = Player.RCLedgeLeftLower.get_collision_point() # Get the colliding point
			_tileCoords = Player.CollisionMap.local_to_map(_collisionPoint) # Convert to tilemap coordinates
			
			# Check if this is a one way collision
			# The following code gets the data of the ledge tile
			var _ledge = Vector2i(_tileCoords.x - 1, _tileCoords.y)
			print(Player.CollisionMap.map_to_local(_ledge))
			var _tileData = Player.CollisionMap.get_cell_tile_data(_ledge)
			if (_tileData.get_custom_data("OneWay")):
				return
			else:
				cornerGrabPosition = Player.CollisionMap.map_to_local(_tileCoords) - _tileSizeCorrection
	elif (Player.ledgeDirection == Vector2.RIGHT):
		if (Player.RCLedgeRightLower.is_colliding()):
			_collisionPoint = Player.RCLedgeRightLower.get_collision_point() # Get the colliding point
			_tileCoords = Player.CollisionMap.local_to_map(_collisionPoint) # Convert to tilemap coordinates
			
			# Check if this is a one way collision
			# The following code gets the data of the ledge tile
			var _ledge = Vector2i(_tileCoords.x - 1, _tileCoords.y)
			print(Player.CollisionMap.map_to_local(_ledge))
			var _tileData = Player.CollisionMap.get_cell_tile_data(_ledge)
			print(_tileData.get_custom_data("OneWay")):
			
			cornerGrabPosition = Player.CollisionMap.map_to_local(_tileCoords) - _tileSizeCorrection
			
			# Check if this is a one way collision
			# The following code gets the data of the ledge tile
			var _collider = Player.RCLedgeRightLower.get_collider()
			var _cell = _collider.local_to_map(_collider.global_position)
			var _tileData = _collider.get_cell_tile_data(_cell)
			print(_tileData.get_custom_data("OneWay"))
	
	ledgeGrabSnapPosition = Vector2(cornerGrabPosition.x + (Player.ledgeDirection.x * -1), cornerGrabPosition.y + 6)
	Player.global_position = ledgeGrabSnapPosition


func ExitState():
	pass


func Update(delta: float):
	Player.climbStamina -= Player.GrabStaminaCost
	HandleJumpUp()
	HandleClimbUp()
	HandleLedgeRelease()
	HandleAnimations()


func HandleLedgeRelease():
	if (Player.keyDown or (Player.climbStamina <= 0)):
		Player.global_position += Vector2(ledgeReleaseXNudge * Player.ledgeDirection.x * -1,
			ledgeReleaseYNudge)
		Player.ChangeState(States.Fall)


# Functionality for if the player jumps from a grab
func HandleJumpUp():
	if (Player.keyJumpPressed):
		Player.global_position += Vector2(ledgeReleaseXNudge * Player.ledgeDirection.x * -2, ledgeReleaseYNudge)
		Player.ChangeState(States.Jump)


# Functionality for if the player climbs from a grab
func HandleClimbUp():
	if (Player.keyUpPressed):
		Player.ChangeState(States.LedgeClimb)


func HandleAnimations():
	Player.Animator.play("LedgeGrab")
	Player.Sprite.flip_h = (Player.ledgeDirection.x < 0)
