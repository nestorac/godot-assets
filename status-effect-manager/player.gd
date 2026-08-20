extends CharacterBody3D

@export var speed: float = 5.0
@export var jump_velocity: float = 4.5
@export var mouse_sensitivity: float = 0.003
@onready var camera_pivot: Node3D = $CameraPivot

@export var spell_scene: PackedScene
@export var spell_spawn_point: Marker3D   # Drag a Marker3D here (place it in front of the hand)

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	# Gravedad
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Salto
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# Movimiento
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cast_spell"):
		print("F key detected - trying to cast spell")
		cast_spell()
	
	# Extra check
	if event is InputEventKey and event.pressed and event.keycode == KEY_F:
		print("Raw F key pressed")
	
	# Mouse input
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		# Horizontal (left / right)
		rotate_y(-event.relative.x * mouse_sensitivity)

		# Vertical (up / down)
		camera_pivot.rotate_x(-event.relative.y * mouse_sensitivity)

		# Limit vertical rotation so it doesn’t flip
		camera_pivot.rotation.x = clamp(
			camera_pivot.rotation.x,
			deg_to_rad(-80.0),
			deg_to_rad(80.0)
		)

func cast_spell() -> void:
	print("cast_spell() was called")
	
	if spell_scene == null:
		print("ERROR: spell_scene is not assigned!")
		return

	print("Instantiating spell...")
	var spell = spell_scene.instantiate()
	get_tree().current_scene.add_child(spell)
	
	if spell_spawn_point:
		spell.global_position = spell_spawn_point.global_position
		spell.global_basis = spell_spawn_point.global_basis
	else:
		spell.global_position = global_position + Vector3(0, 1.4, 0) - global_transform.basis.z * 1.5
