extends CharacterBody3D

# ----------------------
# --- CONFIG EXPORTS ---
# ----------------------

@export_group("Camera")
@export_range(0.0, 1.0) var mouse_sensitivity := 0.25
@export var zoom_speed := 0.5
@export var min_zoom_distance := 3.0
@export var max_zoom_distance := 7.0

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

# -------------------
# ---- VARIABLES ----
# -------------------
var state := "idle"
var _camera_input_direction := Vector2.ZERO
var was_on_floor := false
var _can_move := true
var _attack_timer: Timer
var _attack_recovery_timer: Timer
var _air_attack_timer: Timer
var _attack_tween: Tween
var _attack_lunge_direction := Vector3.ZERO
var _attack_lunge_strength := 0.0
var combo_step := 0
var combo_max := 3
var combo_queued := false


# -----------------------
# --- NODE REFERENCES ---
# -----------------------

@onready var _camera_pivot : Node3D = $CameraPivot
@onready var _camera: Camera3D = $CameraPivot/SpringArm3D/Camera3D
@onready var _spring_arm: SpringArm3D = $CameraPivot/SpringArm3D
@onready var _skin: MimiSkin = %Mimi
@onready var health_ui = %HealthUI


# ---------------
# ---- READY ----
# ---------------

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
	
	_air_attack_timer = Timer.new()
	_air_attack_timer.one_shot = true
	_air_attack_timer.timeout.connect(_on_air_attack_timeout)
	add_child(_air_attack_timer)
	
	health_ui.set_health(max_health, current_health)
	
	QuestManager.start_quest("find_lost_sword")
	QuestManager.start_quest("rescue_villager")


# ---------------
# ---- INPUT ----
# ---------------

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click") and not Global.paused:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if event.is_action_pressed("left_click") and not Global.paused and not Global.dialoguepaused:
		if is_on_floor():
			if state == "attack" and combo_step < combo_max:
				combo_queued = true
			else:
				perform_attack()
		elif state == "jump" and 35 >= velocity.y and velocity.y >= -15:
			perform_air_attack()

	if event.is_action_pressed("right_click"):
		state = "hitstun"
		_skin.set_move_state("hitstun")
		health_ui.take_damage(20)
	
	if not Global.paused:
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
			_skin.spin_around(attack_durations[2]/2)

	_skin.set_broom_position(combo_step)

	var attack_duration: float = attack_durations[combo_step - 1]
	_attack_timer.wait_time = attack_duration
	_attack_timer.start()

	var recovery_duration: float = recovery_durations[combo_step - 1]
	_attack_recovery_timer.wait_time = attack_duration + recovery_duration
	_attack_recovery_timer.start()

func perform_air_attack() -> void:
	set_state("airattack")
	velocity.y = 40
	_skin.spin_around(attack_durations[2]/3)
	_skin.set_airbroom_position()
	_air_attack_timer.wait_time = attack_durations[2]/1.5
	_air_attack_timer.start()


# -------------------------------
# ---- UNHANDLED MOUSE INPUT ----
# -------------------------------

func _unhandled_input(event: InputEvent) -> void:
	if not Global.paused:
		if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			_camera_input_direction = event.relative * mouse_sensitivity


# -----------------
# ---- PHYSICS ----
# -----------------

func _physics_process(delta: float) -> void:
	
	# print("State: ", state, " | _can_move: ", _can_move, " | Vel: ", velocity)
	
	if Global.dialoguepaused:
		disable_movement()
		return
	
	update_broom_visibility()
	update_can_move()
	if is_on_floor():
		update_broom_particles()
	else:
		update_air_broom_particles()
	update_camera_rotation(delta)

	if state == "attack" and not _can_move:
		handle_attack_movement(delta)
		return

	handle_movement_input(delta)
	handle_jump_and_gravity(delta)
	update_state_and_animation()
	update_particles()
	check_landing()

	was_on_floor = is_on_floor()
	move_and_slide()


func disable_movement():
	set_state("idle")
	_can_move = false


func update_broom_visibility():
	var visibility = state in ["attack", "recovery", "airattack"]
	_skin.set_broom_visibilty(visibility)


func update_can_move():
	_can_move = _attack_timer.time_left <= 0


func update_broom_particles():
	_skin.set_broom_particles(_attack_timer.time_left > 0.15)

func update_air_broom_particles():
	_skin.set_broom_particles(_air_attack_timer.time_left > 0.15)


func update_camera_rotation(delta: float):
	_camera_pivot.rotation.x = clamp(
		_camera_pivot.rotation.x - _camera_input_direction.y * delta,
		-PI/6.0, PI/3.0
	)
	_camera_pivot.rotation.y -= _camera_input_direction.x * delta
	_camera_input_direction = Vector2.ZERO


func handle_attack_movement(delta: float):
	var extraattackmove
	if combo_step < 3:
		extraattackmove = 1
	else:
		extraattackmove = 2
	velocity.y = 0.0 if is_on_floor() else velocity.y - gravity * delta
	velocity.x = _attack_lunge_direction.x * _attack_lunge_strength * extraattackmove
	velocity.z = _attack_lunge_direction.z * _attack_lunge_strength * extraattackmove
	move_and_slide()


func handle_movement_input(delta: float):
	var speed = sprint_speed if Input.is_action_pressed("sprint") else move_speed
	var input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var move_dir = (_camera.global_basis.z * input.y + _camera.global_basis.x * input.x).normalized()
	move_dir.y = 0.0

	if state not in ["hitstun", "attack"]:
		velocity = velocity.move_toward(move_dir * speed, acceleration * delta)

	if _can_move and state == "attack":
		state = "recovery"
		
		if combo_step >= combo_max:
			combo_step = 0
		elif (velocity.x != 0 or velocity.z != 0) and combo_step != 0:
			combo_step = 0
			print("byecombo")

	if _attack_recovery_timer.time_left <= 0:
		combo_step = 0

	if move_dir.length() > 0.2:
		var angle = Vector3.BACK.signed_angle_to(move_dir, Vector3.UP)
		_skin.global_rotation.y = lerp_angle(_skin.rotation.y, angle, rotation_speed * delta)


func handle_jump_and_gravity(delta: float):
	if not is_on_floor():
		velocity.y -= gravity * delta
		if velocity.y > 0 and state not in ["jump", "airattack"]:
			set_state("jump")
		elif velocity.y < -15 and state not in ["air", "airattack"]:
			set_state("air")
	elif Input.is_action_just_pressed("jump"):
		velocity.y = jump_strength
		set_state("jump")
	else:
		velocity.y = 0.0


func update_state_and_animation():
	var horizontal_speed = Vector2(velocity.x, velocity.z).length()

	if not is_on_floor():
		return

	if state == "air" or state == "airattack":
		set_state("squat")
	
	elif state == "hitstun":
		1 + 1 # placeholder para cuendo implemente el resto
	
	elif state not in ["hitstun", "attack"]:
		if horizontal_speed > 0.1:
			set_state("walkrun")
			_skin.set_run_speed(horizontal_speed - move_speed, sprint_speed - move_speed)
			combo_step = 0
		elif _attack_recovery_timer.time_left <= 0:
			set_state("idle")
			combo_step = 0
			

func set_state(new_state: String) -> void:
	if state == new_state:
		return
	state = new_state
	print(state)
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
			_skin.set_move_state("swing1") # o lo que toque
		"hitstun":
			_skin.set_move_state("hitstun")
		"recovery":
			pass # no animación específica
		"airattack":
			_skin.set_move_state("airattack")


func update_particles():
	var walk = %WalkParticles
	var run = %RunParticles
	var is_running = Input.is_action_pressed("sprint")

	if state == "walkrun":
		walk.emitting = true
		run.emitting = true
		walk.amount_ratio = 0 if is_running else 1
		run.amount_ratio = 1 if is_running else 0
	else:
		walk.emitting = false
		run.emitting = false

func check_landing():
	if not was_on_floor and is_on_floor():
		%LandParticles.restart()




# ------------------------
# ---- ATTACK TIMEOUT ----
# ------------------------

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

func _on_air_attack_timeout() -> void:
	if not is_on_floor():
		set_state("air")


# --------------------------
# ---- RECOVERY TIMEOUT ----
# --------------------------

func _on_attack_recovery_timeout() -> void:
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
