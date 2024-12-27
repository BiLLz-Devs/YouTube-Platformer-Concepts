@tool
class_name ResettingPlatform extends StaticBody2D

@onready var Collider: CollisionShape2D = $Collider
@onready var Area: Area2D = $Area
@onready var Detector: CollisionShape2D = $Area/Detector

@export_category("Platform Properties")
@export var scaleWidth: float = 1.0
@export var scaleHeight: float = 1.0
@export var oneWay: bool = false

@export_category("Graphics Properties")
@export var platformTexture: Texture2D
@export var Sprite: Sprite2D
@export var Animator: AnimationPlayer
@export var Normal: String = "Normal"
@export var Breaking: String = "Breaking"
@export var Broken: String = "Broken"

enum PlatformStates {
	Normal,
	Breaking,
	Broken
}

var currentState: PlatformStates = PlatformStates.Normal
var areaheight: int = 4

func _ready() -> void:
	Sprite.texture = platformTexture
	Sprite.scale = Vector2(scaleWidth, scaleHeight)
	Collider.one_way_collision = oneWay
	
	Animator.animation_finished.connect(OnAnimationFinished)
	
	ResizeColliderToSprite()
	ResizeAreaToSprite()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (!Engine.is_editor_hint()):
		match currentState:
			PlatformStates.Breaking:
				Animator.play(Breaking)
			PlatformStates.Broken:
				Collider.disabled = true
				Animator.play(Broken)
			_:
				Animator.play(Normal)
				Collider.disabled = false
		
		HandlePlatformTrigger()


func OnAnimationFinished(currentAnimation: String):
	if (currentAnimation == Breaking):
		currentState = PlatformStates.Broken
	if (currentAnimation == Broken):
		currentState = PlatformStates.Normal


func HandlePlatformTrigger():
	var _bodies = Area.get_overlapping_bodies()
	for item in _bodies:
		if (item is PlayerController):
			if (item.is_on_floor()):
				if (currentState == PlatformStates.Normal):
					currentState = PlatformStates.Breaking


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
		if (Collider.shape is RectangleShape2D):
			# Adjust the size of the RectangleShape2D
			Detector.shape.extents = Vector2(_spriteSize.x / 2, areaheight)
			Detector.position = Detector.position -Vector2(0, Collider.shape.extents.y)
		elif (Collider.shape is CircleShape2D):
			# Adjust the radius of the CircleShape2D (if appropriate)
			Collider.shape.radius = max(_spriteSize.x, _spriteSize.y) / 2
		else:
			print("Unsupported collider shape.")
	else:
		print("Sprite texture is missing!")
