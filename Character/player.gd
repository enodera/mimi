# player.gd
extends CharacterBody3D

# ---------------------
# --- CONFIG EXPORTS --
# ---------------------

@export_group("Camera")
@export_range(0.0, 1.0) var mouse_sensitivity := 0.25
@export var zoom_speed := 0.5                    # Zoom speed for smoother zooming
@export var min_zoom_distance := 3.0             # Minimum camera zoom distance
@export var max_zoom_distance := 10.0            # Maximum camera zoom distance

@export_group("Movement")
@export var move_speed := 8.0                    # Normal walking speed
@export var sprint_speed := 22.0                 # Sprinting speed
@export var acceleration := 100.0                # Acceleration rate
@export var rotation_speed := 12.0               # Rotation interpolation speed
@export var jump_strength := 75.0                # Upward force when jumping
@export var gravity := 225.0                     # Gravity strength

# ---------------------
# ---- VARIABLES -------
# ---------------------

var state := "idle"
var _camera_input_direction := Vector2.ZERO       # Mouse input for rotating camera
var _last_movement_direction := Vector3.BACK      # Last non-zero movement direction
var was_on_floor := false                         # For detecting landing transitions

# ---------------------
# --- NODE REFERENCES -
# ---------------------

@onready var _camera_pivot : Node3D = $CameraPivot
@onready var _camera: Camera3D = $CameraPivot/SpringArm3D/Camera3D
@onready var _spring_arm: SpringArm3D = $CameraPivot/SpringArm3D
@onready var _skin: MimiSkin = %Mimi

# ---------------------
# ---- READY ----------
# ---------------------

func _ready() -> void:
	was_on_floor = true

# ---------------------
# ---- INPUT ----------
# ---------------------

func _input(event: InputEvent) -> void:
	# Lock or unlock the mouse
	if event.is_action_pressed("left_click") and not Global.paused:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	# Handle camera zoom in
	if Input.is_action_pressed("camera_zoomin"):
		if _spring_arm.spring_length > min_zoom_distance:
			_spring_arm.spring_length -= zoom_speed
	
	# Handle camera zoom out
	if Input.is_action_pressed("camera_zoomout"):
		if _spring_arm.spring_length < max_zoom_distance:
			_spring_arm.spring_length += zoom_speed

# ----------------------------
# ---- UNHANDLED MOUSE INPUT -
# ----------------------------

func _unhandled_input(event: InputEvent) -> void:
	if not Global.paused:
		var is_camera_motion := (
			event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
		)
		if is_camera_motion:
			_camera_input_direction = event.screen_relative * mouse_sensitivity

# ---------------------
# ---- PHYSICS --------
# ---------------------

func _physics_process(delta: float) -> void:
	
	# -- CHECK FOR PAUSE --
	if Global.dialoguepaused:
		_skin.set_move_state("idle")
		state = "idle"
		return
		
	# -- CAMERA ROTATION --
	_camera_pivot.rotation.x -= _camera_input_direction.y * delta
	_camera_pivot.rotation.x = clamp(_camera_pivot.rotation.x, -PI/6.0, PI/3.0)
	_camera_pivot.rotation.y -= _camera_input_direction.x * delta
	_camera_input_direction = Vector2.ZERO

	# -- APPLY GRAVITY --
	if not is_on_floor():
		velocity.y -= gravity * delta
		if velocity.y > 0 and state != "jump":
			state = "jump"
			_skin.set_move_state("jump")
		elif velocity.y < -15 and state != "air":
			state = "air"
			_skin.set_move_state("air")

	# -- JUMPING --
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = jump_strength
		_skin.set_move_state("jump")
		state = "jump"

	# -- MOVEMENT DIRECTION --
	var current_move_speed = move_speed
	if Input.is_action_pressed("sprint"):
		current_move_speed = sprint_speed

	var raw_input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var forward := _camera.global_basis.z
	var right := _camera.global_basis.x
	var move_direction := forward * raw_input.y + right * raw_input.x
	move_direction.y = 0.0
	move_direction = move_direction.normalized()

	# -- APPLY MOVEMENT --
	velocity = velocity.move_toward(move_direction * current_move_speed, acceleration * delta)
	move_and_slide()

	# -- CHARACTER ROTATION --
	if move_direction.length() > 0.2:
		_last_movement_direction = move_direction
	var target_angle := Vector3.BACK.signed_angle_to(_last_movement_direction, Vector3.UP)
	_skin.global_rotation.y = lerp_angle(_skin.rotation.y, target_angle, rotation_speed * delta)

	# -- ANIMATIONS + STATES --
	var ground_speed := velocity.length()

	if is_on_floor():
		if state == "air":
			_skin.set_move_state("squat")
			state = "squat"
		else:
			if ground_speed > 0.0:
				_skin.set_move_state("walkrun")
				_skin.set_run_speed(ground_speed - move_speed, sprint_speed - move_speed)
				state = "walkrun"
			else:
				_skin.set_move_state("idle")
				state = "idle"

	# -- PARTICLE EFFECTS --
	if state == "walkrun":
		%WalkParticles.emitting = true
		%RunParticles.emitting = true
		if current_move_speed <= move_speed:
			%WalkParticles.amount_ratio = 1
			%RunParticles.amount_ratio = 0
		else:
			%WalkParticles.amount_ratio = 0
			%RunParticles.amount_ratio = 1
	else:
		%WalkParticles.emitting = false
		%RunParticles.emitting = false

	# -- LANDING PARTICLES --
	if not was_on_floor and is_on_floor():
		%LandParticles.restart()

	was_on_floor = is_on_floor()

# ---------------------
# ---- UI / PROCESS ---
# ---------------------

func _process(_delta: float) -> void:
	# Toggle inventory and pause game
	if Input.is_action_just_pressed("inventory"):
		if not Global.paused and not Global.dialoguepaused:
			print("paused")
			%InventoryUI.visible = true
			Global.paused = true
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			Engine.time_scale = 0.0001
		else:
			print("unpaused")
			%InventoryUI.visible = false
			Global.paused = false
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			Engine.time_scale = 1
