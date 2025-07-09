# player.gd

extends CharacterBody3D

# ----------------------
# --- CONFIG EXPORTS ---
# ----------------------

# Camera configuration parameters
@export_group("Camera")
@export_range(0.0, 1.0) var mouse_sensitivity := 0.25  # Controls how sensitive camera movement is to mouse input
@export var zoom_speed := 0.5  # Speed at which camera zooms in/out
@export var min_zoom_distance := 3.0  # Minimum camera zoom distance
@export var max_zoom_distance := 7.0  # Maximum camera zoom distance

# Movement configuration parameters
@export_group("Movement")
@export var move_speed := 8.0  # Base movement speed
@export var sprint_speed := 22.0  # Speed when sprinting
@export var acceleration := 100.0  # How quickly character reaches max speed
@export var rotation_speed := 12.0  # How fast character rotates to face movement direction
@export var jump_strength := 65.0  # Vertical force applied when jumping
@export var gravity := 225.0  # Strength of gravity pulling character down

# Attack timing configuration
@export_group("Attack Timings")
@export var attack_durations := [0.35, 0.4, 0.5]  # Duration of each attack in combo
@export var recovery_durations := [0.25, 0.3, 0.35]  # Recovery time after each attack

# Health system configuration
@export_group("Health")
@export var max_health = 100  # Maximum health value
@export var current_health = 100  # Current health value

# -------------------
# ---- VARIABLES ----
# -------------------
var state := "idle"  # Current state of the character (idle, walkrun, jump, etc.)
var _camera_input_direction := Vector2.ZERO  # Stores mouse input for camera movement
var was_on_floor := false  # Track if character was on floor last frame
var _can_move := true  # Flag to enable/disable movement
var _attack_timer: Timer  # Timer for attack duration
var _attack_recovery_timer: Timer  # Timer for attack recovery
var _air_attack_timer: Timer  # Timer for air attacks
var _attack_tween: Tween  # Tween for attack lunge effect
var _attack_lunge_direction := Vector3.ZERO  # Direction of attack lunge
var _attack_lunge_strength := 0.0  # Strength of attack lunge
var combo_step := 0  # Current step in attack combo
var combo_max := 3  # Maximum steps in combo
var combo_queued := false  # Flag for queued combo attacks

var is_knockback_active := false  # Flag for knockback state

var good_def := false  # Flag for successful defense
var is_on_water := false  # Flag for water interaction
var gamedoneinstanced := false  # Flag for game completion state

# -----------------------
# --- NODE REFERENCES ---
# -----------------------

# Get references to important nodes in the scene
@onready var _camera_pivot : Node3D = $CameraPivot
@onready var _camera: Camera3D = $CameraPivot/SpringArm3D/Camera3D
@onready var _spring_arm: SpringArm3D = $CameraPivot/SpringArm3D
@onready var _skin: MimiSkin = %Mimi  # Reference to character visual representation
@onready var health_ui = %HealthUI  # Reference to health UI element
@onready var shader_material: ShaderMaterial = $ScreenTransition/ColorRect.material  # Reference to screen transition shader

# ---------------
# ---- READY ----
# ---------------

func _ready() -> void:
	# Initialize character state
	was_on_floor = true
	_can_move = true
	is_on_water = false
	Global.dialoguepaused = false
	Global.gamedone = false

	# Set up attack timers
	_attack_timer = Timer.new()
	_attack_timer.one_shot = true
	_attack_timer.timeout.connect(_on_attack_timeout)
	add_child(_attack_timer)

	_attack_recovery_timer = Timer.new()
	_attack_recovery_timer.one_shot = true
	_attack_recovery_timer.timeout.connect(_on_attack_recovery_timeout)
	add_child(_attack_recovery_timer)
	
	_air_attack_timer = Timer.new()
	_air_attack_timer.one_shot = true
	_air_attack_timer.timeout.connect(_on_air_attack_timeout)
	add_child(_air_attack_timer)
	
	MusicManager.play_music(preload("res://Sound/music/overworld.ogg"))
	
	# Initialize health UI if available
	if health_ui:
		health_ui.set_health(max_health, current_health)
	
	# Set mouse mode and run screen transition
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	run_transition_show()

# ---------------
# ---- INPUT ----
# ---------------

func _input(event: InputEvent) -> void:
	# Skip input processing if inventory or cooking UI is open
	if Global.inventorypaused or Global.cookingpaused:
		return
	
	# Handle left click (attack input)
	if event.is_action_pressed("left_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
		if not Global.dialoguepaused:
			if is_on_floor():
				# Queue combo if already attacking
				if state == "attack" and combo_step < combo_max:
					combo_queued = true
				else:
					perform_attack()
			# Perform air attack if in jump state with appropriate velocity
			elif state == "jump" and 35 >= velocity.y and velocity.y >= -25:
				perform_air_attack()
	
	# Toggle mouse visibility with escape key
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# Handle right click (defend input)
	if event.is_action_pressed("right_click") and not Global.dialoguepaused and is_on_floor():
		if state in ["idle", "walkrun", "recovery"]:
			set_state("defend")
	
	# Handle right click release (exit defend state)
	if event.is_action_released("right_click"):
		if state == "defend":
			set_state("idle")
			
	# Handle camera zoom input
	if Input.is_action_pressed("camera_zoomin"):
		if _spring_arm.spring_length > min_zoom_distance:
			_spring_arm.spring_length -= zoom_speed
	if Input.is_action_pressed("camera_zoomout"):
		if _spring_arm.spring_length < max_zoom_distance:
			_spring_arm.spring_length += zoom_speed

# ---------------- 
# ---- ATTACK ----
# ----------------

func perform_attack() -> void:
	# Don't attack if already at max combo
	if combo_step >= combo_max:
		return

	# Set attack state and initialize attack variables
	set_state("attack")
	_can_move = false
	combo_step += 1
	print("State changed to attack (step ", combo_step, ")")

	velocity = Vector3.ZERO

	# Get input direction for attack lunge
	var raw_input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# Calculate attack lunge direction based on camera
	_attack_lunge_direction = -_camera.global_basis.z
	_attack_lunge_direction.y = 0
	_attack_lunge_direction = _attack_lunge_direction.normalized()
	
	# Set lunge strength based on input
	if raw_input.length() > 0.1:
		_attack_lunge_strength = 30.0
	else:
		_attack_lunge_strength = 10.0

	# Rotate character to face attack direction
	var target_angle = Vector3.BACK.signed_angle_to(_attack_lunge_direction, Vector3.UP)
	_skin.global_rotation.y = target_angle

	# Set up attack lunge tween
	if _attack_tween and _attack_tween.is_running():
		_attack_tween.kill()

	_attack_tween = create_tween()
	_attack_tween.tween_property(self, "_attack_lunge_strength", 0.0, 0.5)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	# Set appropriate animation based on combo step
	match combo_step:
		1:
			_skin.set_move_state("swing1")
		2:
			_skin.set_move_state("swing2")
		3:
			_skin.set_move_state("swing3")
			_skin.spin_around(attack_durations[2]/2)
	
	# Update broom position for attack
	_skin.set_broom_position(combo_step)

	# Start attack and recovery timers
	var attack_duration: float = attack_durations[combo_step - 1]
	_attack_timer.wait_time = attack_duration
	_attack_timer.start()

	var recovery_duration: float = recovery_durations[combo_step - 1]
	_attack_recovery_timer.wait_time = attack_duration + recovery_duration
	_attack_recovery_timer.start()

func perform_air_attack() -> void:
	# Set up air attack state
	set_state("airattack")
	velocity.y = 55  # Apply upward force
	_skin.spin_around(attack_durations[2]/3)  # Spin animation
	_skin.set_airbroom_position()  # Set broom position
	_air_attack_timer.wait_time = attack_durations[2]/1.5  # Set timer
	_air_attack_timer.start()

# -------------------------------
# ---- UNHANDLED MOUSE INPUT ----
# -------------------------------

func _unhandled_input(event: InputEvent) -> void:
	# Handle mouse movement for camera control
	if not Global.inventorypaused or not not Global.cookingpaused:
		if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			_camera_input_direction = event.relative * mouse_sensitivity

# -----------------
# ---- PHYSICS ----
# -----------------

func _physics_process(delta: float) -> void:
	# Main physics processing function
	
	# Skip physics if in dialogue, water, or game completed state
	if Global.dialoguepaused or is_on_water or Global.gamedone:
		disable_movement()
		if Global.gamedone and gamedoneinstanced == false and not Global.dialoguepaused:
			gamedoneinstanced = true
			await run_transition_hide()
			get_tree().change_scene_to_file("res://Scenes/Victory.tscn")
		return
	
	# Update various character systems
	update_broom_visibility()
	update_can_move()
	if is_on_floor():
		update_broom_particles()
	else:
		update_air_broom_particles()
	update_camera_rotation(delta)

	# Handle attack movement if in attack state
	if not _can_move:
		if state == "attack":
			handle_attack_movement(delta)
		return
	
	# Handle normal movement and state updates
	handle_movement_input(delta)
	handle_jump_and_gravity(delta)
	update_state_and_animation()
	update_particles()
	check_landing()
	
	# Store floor state and apply movement
	was_on_floor = is_on_floor()
	move_and_slide()

# Helper function to disable movement
func disable_movement():
	_can_move = false
	set_state("idle")

# Update broom visibility based on state
func update_broom_visibility():
	var visibility = state in ["attack", "recovery", "airattack"]
	_skin.set_broom_visibilty(visibility)

# Update movement permission based on state
func update_can_move():
	_can_move = _attack_timer.time_left <= 0 and state != "defend"

# Update broom particles when on ground
func update_broom_particles():
	_skin.set_broom_particles(_attack_timer.time_left > 0.15)

# Update broom particles when in air
func update_air_broom_particles():
	_skin.set_broom_particles(_air_attack_timer.time_left > 0.15)

# Update camera rotation based on input
func update_camera_rotation(delta: float):
	_camera_pivot.rotation.x = clamp(
		_camera_pivot.rotation.x - _camera_input_direction.y * delta,
		-PI/6.0, PI/3.0
	)
	_camera_pivot.rotation.y -= _camera_input_direction.x * delta
	_camera_input_direction = Vector2.ZERO

# Handle movement during attacks
func handle_attack_movement(delta: float):
	var extraattackmove
	if combo_step < 3:
		extraattackmove = 1
	else:
		extraattackmove = 2
	if not is_knockback_active:
		velocity.y = 0.0 if is_on_floor() else velocity.y - gravity * delta
		velocity.x = _attack_lunge_direction.x * _attack_lunge_strength * extraattackmove
		velocity.z = _attack_lunge_direction.z * _attack_lunge_strength * extraattackmove
		move_and_slide()

# Handle normal movement input
func handle_movement_input(delta: float):
	# Determine movement speed based on sprint input
	var speed = sprint_speed if Input.is_action_pressed("sprint") else move_speed
	var input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var move_dir = (_camera.global_basis.z * input.y + _camera.global_basis.x * input.x).normalized()
	move_dir.y = 0.0

	# Apply movement if not in restricted states
	if state not in ["hitstun", "attack", "defend"]:
		velocity = velocity.move_toward(move_dir * speed, acceleration * delta)

	# Handle attack recovery state
	if _can_move and state == "attack":
		state = "recovery"
		
		if combo_step >= combo_max:
			combo_step = 0
		elif (velocity.x != 0 or velocity.z != 0) and combo_step != 0:
			combo_step = 0
			print("byecombo")

	# Reset combo if recovery complete
	if _attack_recovery_timer.time_left <= 0:
		combo_step = 0

	# Rotate character to face movement direction
	if move_dir.length() > 0.2:
		var angle = Vector3.BACK.signed_angle_to(move_dir, Vector3.UP)
		_skin.global_rotation.y = lerp_angle(_skin.rotation.y, angle, rotation_speed * delta)

# Handle jumping and gravity
func handle_jump_and_gravity(delta: float):
	# Special handling for hitstun state
	if state == "hitstun":
		velocity.y -= gravity * delta
		return

	# Apply gravity when not on floor
	if not is_on_floor():
		velocity.y -= gravity * delta
		# Set appropriate air states
		if velocity.y > 0 and state not in ["jump", "airattack", "hitstun"]:
			set_state("jump")
		elif velocity.y < -15 and state not in ["air", "airattack", "hitstun"]:
			set_state("air")
	# Handle jump input
	elif Input.is_action_just_pressed("jump"):
		velocity.y = jump_strength
		set_state("jump")
	# Reset vertical velocity when on ground
	elif not is_knockback_active:
		velocity.y = 0.0

# Update character state and animation based on current conditions
func update_state_and_animation():
	var horizontal_speed = Vector2(velocity.x, velocity.z).length()

	# Skip state updates if in air
	if not is_on_floor():
		return

	# Handle landing states
	if state == "air" or state == "airattack":
		set_state("squat")
	
	# Handle ground movement states
	elif state not in ["hitstun", "attack"]:
		if horizontal_speed > 0.1:
			set_state("walkrun")
			_skin.set_run_speed(horizontal_speed - move_speed, sprint_speed - move_speed)
			combo_step = 0
		elif _attack_recovery_timer.time_left <= 0:
			if state != "defend":
				set_state("idle")
				combo_step = 0
			else:
				set_state("defend")
				combo_step = 0

# Change character state and trigger appropriate animations
func set_state(new_state: String) -> void:
	if state == new_state:
		return
	state = new_state
	print("State change triggered: ", state)
	# Set animation based on new state
	match new_state:
		"idle":
			_skin.set_move_state("idle")
		"walkrun":
			_skin.set_move_state("walkrun")
		"jump":
			_skin.set_move_state("jump")
		"air":
			_skin.set_move_state("air")
		"squat":
			_skin.set_move_state("squat")
		"attack":
			pass # no specific animation
		"hitstun":
			if good_def:
				_skin.set_move_state("good_def")
			else:
				_skin.set_move_state("hitstun")
			
		"recovery":
			pass # no specific animation
		"airattack":
			_skin.set_move_state("airattack")
		"defend":
			_skin.set_move_state("defend")

# Update movement particles (dust trails, etc.)
func update_particles():
	var walk = %WalkParticles
	var run = %RunParticles
	var is_running = Input.is_action_pressed("sprint")

	# Emit particles based on movement state
	if state == "walkrun":
		walk.emitting = true
		run.emitting = true
		walk.amount_ratio = 0 if is_running else 1
		run.amount_ratio = 1 if is_running else 0
	else:
		walk.emitting = false
		run.emitting = false

# Handle landing effects and state changes
func check_landing():
	if not was_on_floor and is_on_floor():
		%LandParticles.restart()  # Play landing particles

		# Exit hitstun when landing
		if state == "hitstun":
			set_state("idle")
			_can_move = true
			is_knockback_active = false

# ------------------------
# ---- ATTACK TIMEOUT ----
# ------------------------

func _on_attack_timeout() -> void:
	# Handle attack completion
	_attack_lunge_strength = 0.0
	velocity = Vector3.ZERO

	# Perform queued combo attack if available
	if combo_queued and combo_step < combo_max:
		combo_queued = false
		perform_attack()
	else:
		# Start recovery timer
		var recovery_duration: float = recovery_durations[combo_step - 1]
		_attack_recovery_timer.wait_time = recovery_duration
		_attack_recovery_timer.start()

func _on_air_attack_timeout() -> void:
	# Handle air attack completion
	if not is_on_floor():
		set_state("air")
	else:
		set_state("squat")

# --------------------------
# ---- RECOVERY TIMEOUT ----
# --------------------------

func _on_attack_recovery_timeout() -> void:
	# Handle recovery completion
	if combo_queued and combo_step < combo_max:
		combo_queued = false
		perform_attack()
	else:
		_can_move = true
		combo_queued = false

# ----------------------
# ---- UI / PROCESS ----
# ----------------------

func _process(_delta: float) -> void:
	# Handle UI toggles
	if not is_knockback_active and not Global.gamedone:
		# Toggle inventory UI
		if Input.is_action_just_pressed("inventory"):
			if not Global.cookingpaused and not Global.dialoguepaused:
				if not Global.inventorypaused:
					print("Inventory paused")
					%InventoryUI.visible = true
					Global.inventorypaused = true
					%InventoryUI.show_inventory()
				else:
					print("Inventory unpaused")
					await %InventoryUI._on_close_button_pressed()
					%InventoryUI.visible = false
					Global.inventorypaused = false
				
		# Toggle cooking UI
		if Input.is_action_just_pressed("cooking"):
			if not Global.inventorypaused and not Global.dialoguepaused:
				if not Global.cookingpaused:
					print("Cooking paused")
					%CookingUI.visible = true
					Global.cookingpaused = true
					%CookingUI.show_inventory()
				else:
					print("Cooking unpaused")
					await %CookingUI._on_close_button_pressed()
					%CookingUI.visible = false
					Global.cookingpaused = false

# Handle taking damage from enemies
func take_damage(amount: int, knockback_dir: Vector3, knockback_strength: float, upward_force: float) -> void:
	print("Player took damage: ", amount, " in state ", state)
	
	# Play hit particles
	$AttackedParticles.restart()
	$AttackedParticles.emitting = true
	
	# Set hit state variables
	_can_move = false
	combo_step = 0
	combo_queued = false
	is_knockback_active = true
	
	# Stop any active attack timers
	if _attack_timer.is_stopped() == false:
		_attack_timer.stop()
	if _attack_recovery_timer.is_stopped() == false:
		_attack_recovery_timer.stop()
	
	# Calculate knockback direction
	var direction = knockback_dir.normalized()
	
	# Handle defense state (reduce damage if defending)
	if state != "defend":
		health_ui.take_damage(amount)
		good_def = false
	else:
		good_def = true
	
	# Set hitstun state
	set_state("hitstun")
	
	# Apply knockback if not dead
	if health_ui.player_dead == false:
		velocity.x = direction.x * knockback_strength
		velocity.z = direction.z * knockback_strength
		velocity.y = upward_force

# Screen transition animation (hide)
func run_transition_hide() -> void:
	var duration = 1.0  # seconds
	var elapsed = 0.0
	while elapsed < duration:
		elapsed += get_process_delta_time()
		var circle_size = lerp(1.0, 0.0, elapsed / duration)
		shader_material.set_shader_parameter("circle_size", circle_size)
		await get_tree().process_frame
	# Ensure it ends exactly at 0
	shader_material.set_shader_parameter("circle_size", 0.0)

# Screen transition animation (show)
func run_transition_show() -> void:
	var duration = 1.0  # seconds
	var elapsed = 0.0
	while elapsed < duration:
		elapsed += get_process_delta_time()
		var circle_size = lerp(0.0, 1.0, elapsed / duration)
		shader_material.set_shader_parameter("circle_size", circle_size)
		await get_tree().process_frame
	# Ensure it ends exactly at 1
	shader_material.set_shader_parameter("circle_size", 1.0)

# Handle death state
func die() -> void:
	# Set death state variables
	is_on_water = true
	_can_move = false
	combo_step = 0
	combo_queued = false
	is_knockback_active = true
	health_ui.take_damage(max_health)  # Ensure health reaches 0
