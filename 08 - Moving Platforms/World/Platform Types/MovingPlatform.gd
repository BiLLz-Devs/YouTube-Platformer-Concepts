class_name MovingPlatform extends Path2D

@onready var Path: PathFollow2D = $PathFollow2D
@onready var Transform: RemoteTransform2D = $PathFollow2D/RemoteTransform2D
@onready var Body: AnimatableBody2D = $AnimatableBody2D
@onready var Sprite: Sprite2D = $AnimatableBody2D/Sprite2D
@onready var Collider: CollisionShape2D = $AnimatableBody2D/CollisionShape2D
@onready var Animator: AnimationPlayer = $AnimationTree

@export var speed = .5

var pathDirection = 1

func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	if (Path.progress == 1):
		pathDirection = pathDirection * -1
	Path.progress += speed
