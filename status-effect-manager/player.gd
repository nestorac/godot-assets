extends CharacterBody3D

@export var speed: float = 5.0
@export var jump_velocity: float = 4.5
@export var mouse_sensitivity: float = 0.003
@onready var camera_pivot: Node3D = $CameraPivot

# On Wizard or a CombatController
@onready var combat_menu: CanvasLayer = $"../CombatMenu"

@onready var camera: Camera3D = $CameraPivot/Camera3D

@export var spell_scene: PackedScene
@export var spell_spawn_point: Marker3D   # Drag a Marker3D here (place it in front of the hand)

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	combat_menu.action_selected.connect(_on_action_selected)

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
		velocity.x = move_toward(velocity.x, 0, speed)if event.is_action_pressed("open_combat_menu"):  # e.g. Tab or R
		if combat_menu.visible:
			combat_menu.close_menu()
		else:
			combat_menu.open_menu()
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
	if event.is_action_pressed("open_combat_menu"):  # e.g. Tab or R
		if combat_menu.visible:
			combat_menu.close_menu()
		else:
			combat_menu.open_menu()

func cast_spell() -> void:
	print("cast_spell() was called")
	
	if spell_scene == null:
		print("ERROR: spell_scene is not assigned!")
		return

	print("Instantiating spell...")
	var spell = spell_scene.instantiate()
	get_tree().current_scene.add_child(spell)
	
	# Camera forward, but only on the ground plane
	var forward: Vector3 = -camera.global_transform.basis.z
	forward.y = 0.0
	if forward.length_squared() < 0.0001:
		forward = -global_transform.basis.z
		forward.y = 0.0
	forward = forward.normalized()

	var origin := spell_spawn_point.global_position if spell_spawn_point else global_position + Vector3(0, 1.2, 0)

	spell.global_position = origin
	spell.look_at(origin + forward, Vector3.UP)

	# Optional: pass the direction if your spell script uses it
	if spell.has_method("set_direction"):
		spell.set_direction(forward)

func _on_action_selected(action: CombatAction) -> void:
	match action.category:
		CombatAction.Category.SPELL:
			cast_spell_from_action(action)
		CombatAction.Category.ATTACK:
			do_attack(action)
		CombatAction.Category.DEFENSE:
			do_defend(action)

func cast_spell_from_action(action: CombatAction) -> void:
	if action.spell_scene == null:
		return
	# same spawn logic you already use for Fireball
	var spell = action.spell_scene.instantiate()
	get_tree().current_scene.add_child(spell)
	# set position / horizontal camera direction...
