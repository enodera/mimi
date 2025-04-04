extends CharacterBody3D

@export_group("Camera")
@export_range(0.0, 1.0) var mouse_sensitivity := 0.25
@export var zoom_speed := 0.5  # New zoom speed for smoother zooming

@export_group("Movement")
@export var move_speed := 8.0
@export var sprint_speed := 22.0
@export var acceleration := 100.0
@export var rotation_speed := 12.0
@export var jump_strength := 75.0  # Jump force
@export var gravity := 225.0  # Gravity strength

var state := "idle"
var _camera_input_direction := Vector2.ZERO
var _last_movement_direction := Vector3.BACK

@onready var _camera_pivot : Node3D = $CameraPivot
@onready var _camera: Camera3D = $CameraPivot/SpringArm3D/Camera3D
@onready var _spring_arm: SpringArm3D = $CameraPivot/SpringArm3D
@onready var _skin: MimiSkin = %Mimi

# Camera zoom limits
@export var min_zoom_distance := 3.0
@export var max_zoom_distance := 10.0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
	# Zoom in when camera_zoomin is pressed
	if Input.is_action_pressed("camera_zoomin"):
		if _spring_arm.spring_length > 1.0:
			_spring_arm.spring_length -= zoom_speed
	
	# Zoom out when camera_zoomout is pressed
	if Input.is_action_pressed("camera_zoomout"):
		if _spring_arm.spring_length < 8.0:
			_spring_arm.spring_length += zoom_speed

func _unhandled_input(event: InputEvent) -> void:
	var is_camera_motion := (
		event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	)
	if is_camera_motion:
		_camera_input_direction = event.screen_relative * mouse_sensitivity

func _physics_process(delta: float) -> void:
	_camera_pivot.rotation.x -= _camera_input_direction.y * delta
	_camera_pivot.rotation.x = clamp(_camera_pivot.rotation.x, -PI/6.0, PI/3.0)
	_camera_pivot.rotation.y -= _camera_input_direction.x * delta
	_camera_input_direction = Vector2.ZERO
	
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta  # Apply gravity
			# Check if character is moving up or falling down
		if velocity.y > 0 and state != "jump":
			state = "jump"
			_skin.set_move_state("jump")  # Play jump animation
		elif velocity.y < -15 and state != "air":
			state = "air"
			_skin.set_move_state("air")  # Play falling animation
		
	# Handle jumping
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = jump_strength
		_skin.set_move_state("jump")  # Play jump animation
		state = "jump"
		
	# Check for sprint action
	var current_move_speed = move_speed
	if Input.is_action_pressed("sprint"):  # If the sprint action is pressed
		current_move_speed = sprint_speed  # Use the sprint speed

	var raw_input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var forward := _camera.global_basis.z
	var right := _camera.global_basis.x
	
	var move_direction := forward * raw_input.y + right * raw_input.x
	move_direction.y = 0.0
	move_direction = move_direction.normalized()
	
	velocity = velocity.move_toward(move_direction * current_move_speed, acceleration * delta)
	move_and_slide()
	
	if move_direction.length() > 0.2:
		_last_movement_direction = move_direction
	
	var target_angle := Vector3.BACK.signed_angle_to(_last_movement_direction, Vector3.UP)
	_skin.global_rotation.y = lerp_angle(_skin.rotation.y, target_angle, rotation_speed * delta)
	
	var ground_speed := velocity.length()
	
	if is_on_floor():
		if state == "air":
			_skin.set_move_state("squat")
			state = "squat"
		elif ground_speed > 0.0:
			_skin.set_move_state("walkrun")
			_skin.set_run_speed(ground_speed - move_speed, sprint_speed - move_speed)
			state = "walkrun"
		else:
			_skin.set_move_state("idle")
			state = "idle"
			
