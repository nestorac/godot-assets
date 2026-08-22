extends Node3D

@export var speed: float = 15.0
@export var lifetime: float = 2.5

var direction: Vector3 = Vector3.FORWARD

func set_direction(dir: Vector3) -> void:
	direction = dir
	direction.y = 0.0
	direction = direction.normalized()

func _ready() -> void:
	# If you didn't call set_direction, use current facing, flattened
	if direction == Vector3.FORWARD:
		direction = -global_transform.basis.z
		direction.y = 0.0
		direction = direction.normalized()

	get_tree().create_timer(lifetime).timeout.connect(queue_free)

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
