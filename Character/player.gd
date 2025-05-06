extends CharacterBody3D

# --------------------- 
# --- CONFIG EXPORTS -- 
# --------------------- 
@export_group("Camera")
@export_range(0.0, 1.0) var mouse_sensitivity := 0.25
@export var zoom_speed := 0.5
@export var min_zoom_distance := 3.0
@export var max_zoom_distance := 10.0

@export_group("Movement")
@export var move_speed := 8.0
@export var sprint_speed := 22.0
@export var acceleration := 100.0
@export var rotation_speed := 12.0
@export var jump_strength := 75.0
@export var gravity := 225.0

@export_group("Attack Timings")
@export var attack_durations := [0.35, 0.4, 0.5]
@export var recovery_durations := [0.25, 0.3, 0.35]

@export_group("Health")
@export var max_health = 100
@export var current_health = 100

# --------------------- 
# ---- VARIABLES ------- 
# --------------------- 
var state := "idle"
var _camera_input_direction := Vector2.ZERO
var was_on_floor := false
var _can_move := true
var _attack_timer: Timer
var _attack_recovery_timer: Timer
var _attack_tween: Tween
var _attack_lunge_direction := Vector3.ZERO
var _attack_lunge_strength := 0.0  # <-- Re-declared variable
var combo_step := 0
var combo_max := 3
var combo_queued := false

# --------------------- 
# --- NODE REFERENCES -- 
# --------------------- 
@onready var _camera_pivot : Node3D = $CameraPivot
@onready var _camera: Camera3D = $CameraPivot/SpringArm3D/Camera3D
@onready var _spring_arm: SpringArm3D = $CameraPivot/SpringArm3D
@onready var _skin: MimiSkin = %Mimi
@onready var health_ui := get_node("/root/Node3D/HealthUI")

# --------------------- 
# ---- READY ---------- 
# --------------------- 
func _ready() -> void:
	was_on_floor = true

	_attack_timer = Timer.new()
	_attack_timer.one_shot = true
	_attack_timer.timeout.connect(_on_attack_timeout)
	add_child(_attack_timer)

	_attack_recovery_timer = Timer.new()
	_attack_recovery_timer.one_shot = true
	_attack_recovery_timer.timeout.connect(_on_attack_recovery_timeout)
	add_child(_attack_recovery_timer)
	
	health_ui.set_health(max_health, current_health)

# --------------------- 
# ---- INPUT ---------- 
# --------------------- 
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click") and not Global.paused:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if event.is_action_pressed("left_click") and not Global.paused:
		if state == "attack" and combo_step < combo_max:
			combo_queued = true
		else:
			perform_attack()
			
		_skin.set_broom_visibilty(true)

	if event.is_action_pressed("right_click"):
		state = "hitstun"
		_skin.set_move_state("hitstun")
		health_ui.take_damage(20)

	if Input.is_action_pressed("camera_zoomin"):
		if _spring_arm.spring_length > min_zoom_distance:
			_spring_arm.spring_length -= zoom_speed
	if Input.is_action_pressed("camera_zoomout"):
		if _spring_arm.spring_length < max_zoom_distance:
			_spring_arm.spring_length += zoom_speed




# --------------------- 
# ---- ATTACK ---------- 
# --------------------- 
func perform_attack() -> void:
	if combo_step >= combo_max:
		return

	state = "attack"
	_can_move = false
	combo_step += 1
	print("State changed to: attack (step ", combo_step, ")")

	velocity = Vector3.ZERO

	var raw_input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	_attack_lunge_direction = -_camera.global_basis.z
	_attack_lunge_direction.y = 0
	_attack_lunge_direction = _attack_lunge_direction.normalized()
	
	if raw_input.length() > 0.1:
		_attack_lunge_strength = 30.0
	else:
		_attack_lunge_strength = 10.0

	var target_angle = Vector3.BACK.signed_angle_to(_attack_lunge_direction, Vector3.UP)
	_skin.global_rotation.y = target_angle

	if _attack_tween and _attack_tween.is_running():
		_attack_tween.kill()

	_attack_tween = create_tween()
	_attack_tween.tween_property(self, "_attack_lunge_strength", 0.0, 0.5)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	match combo_step:
		1:
			_skin.set_move_state("swing1")
		2:
			_skin.set_move_state("swing2")
		3:
			_skin.set_move_state("swing3")

	_skin.set_broom_position(combo_step)

	var attack_duration: float = attack_durations[combo_step - 1]
	_attack_timer.wait_time = attack_duration
	_attack_timer.start()

	var recovery_duration: float = recovery_durations[combo_step - 1]
	_attack_recovery_timer.wait_time = attack_duration + recovery_duration
	_attack_recovery_timer.start()


# --------------------- 
# ---- UNHANDLED MOUSE INPUT - 
# --------------------- 
func _unhandled_input(event: InputEvent) -> void:
	if not Global.paused:
		if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			_camera_input_direction = event.relative * mouse_sensitivity

# --------------------- 
# ---- PHYSICS -------- 
# --------------------- 
func _physics_process(delta: float) -> void:
	
	if state != "attack" and state != "recovery":
		_skin.set_broom_visibilty(false)
	elif is_on_floor():
		_skin.set_broom_visibilty(true)
	else:
		_skin.set_broom_visibilty(false)
	
	if Global.dialoguepaused:
		_skin.set_move_state("idle")
		state = "idle"
		print("State changed to: idle (dialogue paused)")
		return

	if _attack_timer.time_left > 0 and _can_move:
		_can_move = false

		
	if _attack_timer.time_left <= 0 and not _can_move:
		_can_move = true
	
	if _attack_timer.time_left > 0.15:
		_skin.set_broom_particles(true)
	else:
		_skin.set_broom_particles(false)
	
	# CAMERA ROTATION
	_camera_pivot.rotation.x -= _camera_input_direction.y * delta
	_camera_pivot.rotation.x = clamp(_camera_pivot.rotation.x, -PI/6.0, PI/3.0)
	_camera_pivot.rotation.y -= _camera_input_direction.x * delta
	_camera_input_direction = Vector2.ZERO

	# ATTACK MOVEMENT OVERRIDE
	if state == "attack" and not _can_move:
		if not is_on_floor():
			velocity.y -= gravity * delta
		else:
			velocity.y = 0.0

		velocity.x = _attack_lunge_direction.x * _attack_lunge_strength
		velocity.z = _attack_lunge_direction.z * _attack_lunge_strength

		move_and_slide()
		return

	# MOVEMENT INPUT
	var current_move_speed = move_speed
	if Input.is_action_pressed("sprint"):
		current_move_speed = sprint_speed

	var raw_input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var forward := _camera.global_basis.z
	var right := _camera.global_basis.x
	var move_direction := forward * raw_input.y + right * raw_input.x
	move_direction.y = 0.0
	move_direction = move_direction.normalized()


	# NORMAL MOVEMENT WHEN NOT IN RECOVERY
	if _attack_timer.time_left <= 0:
		if state != "walkrun":
			state = "recovery"
		velocity = velocity.move_toward(move_direction * current_move_speed, acceleration * delta)
		if combo_step >= combo_max:
			combo_step = 0
		if velocity.x != 0 or velocity.z != 0:
			if combo_step != 0:
				combo_step = 0
				print("byecombo")
				
	if _attack_recovery_timer.time_left <= 0:
		combo_step = 0

	# ROTATION
	if move_direction.length() > 0.2:
		var target_angle := Vector3.BACK.signed_angle_to(move_direction, Vector3.UP)
		_skin.global_rotation.y = lerp_angle(_skin.rotation.y, target_angle, rotation_speed * delta)

	# GRAVITY & JUMP
	if not is_on_floor():
		velocity.y -= gravity * delta
		if velocity.y > 0 and state != "jump":
			state = "jump"
			_skin.set_move_state("jump")
		elif velocity.y < -15 and state != "air":
			state = "air"
			_skin.set_move_state("air")
	elif Input.is_action_just_pressed("jump"):
		velocity.y = jump_strength
		_skin.set_move_state("jump")
		state = "jump"
	else:
		velocity.y = 0.0

	# STATE & ANIMATION
	var horizontal_speed := Vector2(velocity.x, velocity.z).length()
	if is_on_floor():
		if state == "air":
			state = "squat"
			_skin.set_move_state("squat")
		elif state == "recovery":
			if horizontal_speed > 0.1:
				state = "walkrun"
				_skin.set_move_state("walkrun")
				_skin.set_run_speed(horizontal_speed - move_speed, sprint_speed - move_speed)
				print("hi")
			elif _attack_recovery_timer.time_left <= 0:
				state = "idle"
				_skin.set_move_state("idle")
		elif horizontal_speed > 0.1:
			state = "walkrun"
			_skin.set_move_state("walkrun")
			_skin.set_run_speed(horizontal_speed - move_speed, sprint_speed - move_speed)
		else:
			state = "idle"
			_skin.set_move_state("idle")

	# PARTICLE EFFECTS
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

	if not was_on_floor and is_on_floor():
		%LandParticles.restart()
		

	was_on_floor = is_on_floor()

	move_and_slide()



# --------------------- 
# ---- ATTACK TIMEOUT --- 
# --------------------- 
func _on_attack_timeout() -> void:
	_attack_lunge_strength = 0.0
	velocity = Vector3.ZERO

	if combo_queued and combo_step < combo_max:
		combo_queued = false
		perform_attack()
	else:
		var recovery_duration: float = recovery_durations[combo_step - 1]
		_attack_recovery_timer.wait_time = recovery_duration
		_attack_recovery_timer.start()

# --------------------- 
# ---- RECOVERY TIMEOUT --- 
# --------------------- 
func _on_attack_recovery_timeout() -> void:
	if combo_queued and combo_step < combo_max:
		combo_queued = false
		perform_attack()
	else:
		_can_move = true
		state = "idle"
		_skin.set_move_state("idle")
		combo_queued = false

# --------------------- 
# ---- UI / PROCESS --- 
# --------------------- 
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("inventory"):
		if not Global.paused and not Global.dialoguepaused:
			print("Inventory paused")
			%InventoryUI.visible = true
			Global.paused = true
			%InventoryUI.show_inventory()
		else:
			print("Inventory unpaused")
			await %InventoryUI._on_close_button_pressed()
			%InventoryUI.visible = false
			Global.paused = false
			


func _on_hitbox_area_entered(area: Area3D) -> void:
	if area.name == "EnemyAttackArea":
		state = "hitstun"
		_can_move = false
		combo_step = 0
		combo_queued = false

		_skin.set_move_state("hitstun")
		health_ui.take_damage(20)

		var knockback_strength := 15.0
		var knockback_direction := (global_transform.origin - area.global_transform.origin).normalized()
		velocity.x = knockback_direction.x * knockback_strength
		velocity.z = knockback_direction.z * knockback_strength
		velocity.y = clamp(velocity.y + 10.0, 5.0, 20.0)
