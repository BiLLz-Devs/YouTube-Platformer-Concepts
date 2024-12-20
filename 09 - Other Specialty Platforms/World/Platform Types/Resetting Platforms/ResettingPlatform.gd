@tool
class_name ResettingPlatform extends StaticBody2D

@onready var Collider: CollisionShape2D = $Collider
@onready var Animator: AnimationPlayer = $Animator
@onready var Sprite: Sprite2D = $Sprite
@onready var Area: Area2D = $Area
@onready var Detector: CollisionShape2D = $Area/Detector
@onready var LifeTimer: Timer = $LifeTimer
@onready var ResetTimer: Timer = $ResetTimer

@export_category("Platform Properties")
@export var platformTexture: Texture2D
@export var scaleWidth: float = 1.0
@export var scaleHeight: float = 1.0
@export var oneWay: bool = false
@export var lifetime: float = 1.0
@export var resetTime: float = 3.0

var areaHeight = 2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Sprite.texture = platformTexture
	Sprite.scale = Vector2(scaleWidth, scaleHeight)
	Collider.one_way_collision = oneWay
	
	ResizeColliderToSprite()
	ResizeAreaToSprite()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func ResizeColliderToSprite():
	# Ensure the sprite has a valid texture
	if (Sprite.texture):
		var _spriteSize = Sprite.get_rect().size * Sprite.scale
		print(_spriteSize)
		# Check if the collider has a shape
		if (Collider.shape is RectangleShape2D):
			# Adjust the size of the RectangleShape2D
			Collider.shape.extents = _spriteSize / 2
		elif (Collider.shape is CircleShape2D):
			# Adjust the radius of the CircleShape2D (if appropriate)
			Collider.shape.radius = max(_spriteSize.x, _spriteSize.y) / 2
		else:
			print("Unsupported collider shape.")
	else:
		print("Sprite texture is missing!")


func ResizeAreaToSprite():
	# Ensure the sprite has a valid texture
	if (Sprite.texture):
		var _spriteSize = Sprite.get_rect().size * Sprite.scale
		print(_spriteSize)
		# Check if the collider has a shape
		if (Detector.shape is RectangleShape2D):
			# Adjust the size of the RectangleShape2D
			Detector.shape.extents = Vector2(_spriteSize.x / 2, areaHeight)
			Detector.position = Detector.position - Vector2(0, Collider.shape.extents.y + areaHeight)
		elif (Detector.shape is CircleShape2D):
			# Adjust the radius of the CircleShape2D (if appropriate)
			Detector.shape.radius = max(_spriteSize.x, _spriteSize.y) / 2
		else:
			print("Unsupported collider shape.")
	else:
		print("Sprite texture is missing!")


func _on_area_body_entered(body: Node2D) -> void:
	if (body is CharacterBody2D):
		LifeTimer.start(lifetime)


func _on_life_timer_timeout() -> void:
	# Stop the timer
	LifeTimer.stop()
	
	# Play the break animation
	
	#disable the collider
	Collider.disabled = true;
	ResetTimer.start(resetTime)


func _on_reset_timer_timeout() -> void:
	# Stop the timer
	ResetTimer.stop()
	
	# Enable the collider
	Collider.disabled = false
