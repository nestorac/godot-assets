extends Node3D

@export var speed: float = 15.0
@export var lifetime: float = 2.0

func _ready():
	# Optional: make it grow when spawned
	scale = Vector3.ZERO
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector3.ONE, 0.15).set_trans(Tween.TRANS_BACK)

	# Destroy after time
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta):
	position += -transform.basis.z * speed * delta
