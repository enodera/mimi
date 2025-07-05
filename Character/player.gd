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
@export var jump_strength := 65.0
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

var is_knockback_active := false

var good_def := false
var is_on_water := false
var gamedoneinstanced := false

# -----------------------
# --- NODE REFERENCES ---
# -----------------------

@onready var _camera_pivot : Node3D = $CameraPivot
@onready var _camera: Camera3D = $CameraPivot/SpringArm3D/Camera3D
@onready var _spring_arm: SpringArm3D = $CameraPivot/SpringArm3D
@onready var _skin: MimiSkin = %Mimi
@onready var health_ui = %HealthUI
@onready var shader_material: ShaderMaterial = $ScreenTransition/ColorRect.material
# ---------------
# ---- READY ----
# ---------------

func _ready() -> void:
	was_on_floor = true
	_can_move = true
	is_on_water = false
	Global.dialoguepaused = false
	Global.gamedone = false

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
	
	if health_ui:
		health_ui.set_health(max_health, current_health)
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	run_transition_show()


# ---------------
# ---- INPUT ----
# ---------------

func _input(event: InputEvent) -> void:
	if Global.inventorypaused or Global.cookingpaused:
		return
	
	if event.is_action_pressed("left_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
		if not Global.dialoguepaused:
			if is_on_floor():
				if state == "attack" and combo_step < combo_max:
					combo_queued = true
				else:
					perform_attack()
			elif state == "jump" and 35 >= velocity.y and velocity.y >= -25:
				perform_air_attack()
	
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# Right click pressed -> enter defend state
	if event.is_action_pressed("right_click") and not Global.dialoguepaused and is_on_floor():
		if state in ["idle", "walkrun", "recovery"]:
			set_state("defend")
	
	# Right click released -> exit defend state (go back to idle or previous state)
	if event.is_action_released("right_click"):
		# Only reset defend if currently defending, to avoid unwanted state changes
		if state == "defend":
			set_state("idle")
			
	
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

	set_state("attack")
	_can_move = false
	combo_step += 1
	print("State changed to attack (step ", combo_step, ")")

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
	velocity.y = 55
	_skin.spin_around(attack_durations[2]/3)
	_skin.set_airbroom_position()
	_air_attack_timer.wait_time = attack_durations[2]/1.5
	_air_attack_timer.start()


# -------------------------------
# ---- UNHANDLED MOUSE INPUT ----
# -------------------------------

func _unhandled_input(event: InputEvent) -> void:
	if not Global.inventorypaused or not not Global.cookingpaused:
		if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			_camera_input_direction = event.relative * mouse_sensitivity


# -----------------
# ---- PHYSICS ----
# -----------------

func _physics_process(delta: float) -> void:
	
	# print("State: ", state, " | _can_move: ", _can_move, " | Vel: ", velocity)
	
	if Global.dialoguepaused or is_on_water or Global.gamedone:
		disable_movement()
		if Global.gamedone and gamedoneinstanced == false and not Global.dialoguepaused:
			gamedoneinstanced = true
			await run_transition_hide()
			get_tree().change_scene_to_file("res://Scenes/Victory.tscn")
		return
	
	update_broom_visibility()
	update_can_move()
	if is_on_floor():
		update_broom_particles()
	else:
		update_air_broom_particles()
	update_camera_rotation(delta)

	if not _can_move:
		if state == "attack":
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
	_can_move = false
	set_state("idle")


func update_broom_visibility():
	var visibility = state in ["attack", "recovery", "airattack"]
	_skin.set_broom_visibilty(visibility)


func update_can_move():
	_can_move = _attack_timer.time_left <= 0 and state != "defend"


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
	if not is_knockback_active:
		velocity.y = 0.0 if is_on_floor() else velocity.y - gravity * delta
		velocity.x = _attack_lunge_direction.x * _attack_lunge_strength * extraattackmove
		velocity.z = _attack_lunge_direction.z * _attack_lunge_strength * extraattackmove
		move_and_slide()


func handle_movement_input(delta: float):
	var speed = sprint_speed if Input.is_action_pressed("sprint") else move_speed
	var input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var move_dir = (_camera.global_basis.z * input.y + _camera.global_basis.x * input.x).normalized()
	move_dir.y = 0.0

	if state not in ["hitstun", "attack", "defend"]:
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
	# Prevent gravity state changes while in hitstun
	if state == "hitstun":
		velocity.y -= gravity * delta
		return

	if not is_on_floor():
		velocity.y -= gravity * delta
		if velocity.y > 0 and state not in ["jump", "airattack", "hitstun"]:
			set_state("jump")
		elif velocity.y < -15 and state not in ["air", "airattack", "hitstun"]:
			set_state("air")
	elif Input.is_action_just_pressed("jump"):
		velocity.y = jump_strength
		set_state("jump")
	elif not is_knockback_active:
		velocity.y = 0.0
		

func update_state_and_animation():
	var horizontal_speed = Vector2(velocity.x, velocity.z).length()

	if not is_on_floor():
		return

	if state == "air" or state == "airattack":
		set_state("squat")
	
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

func set_state(new_state: String) -> void:
	if state == new_state:
		return
	state = new_state
	print("State change triggered: ", state)
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
			pass # no animación específica
		"hitstun":
			if good_def:
				_skin.set_move_state("good_def")
			else:
				_skin.set_move_state("hitstun")
			
		"recovery":
			pass # no animación específica
		"airattack":
			_skin.set_move_state("airattack")
		"defend":
			_skin.set_move_state("defend")


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

		# Exit hitstun when landing
		if state == "hitstun":
			set_state("idle")
			_can_move = true
			is_knockback_active = false



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
	else:
		set_state("squat")


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
	if not is_knockback_active and not Global.gamedone:
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


func take_damage(amount: int, knockback_dir: Vector3, knockback_strength: float, upward_force: float) -> void:
	print("Player took damage: ", amount, " in state ", state)
	
	$AttackedParticles.restart()
	$AttackedParticles.emitting = true
	
	_can_move = false
	combo_step = 0
	combo_queued = false
	is_knockback_active = true
	
	if _attack_timer.is_stopped() == false:
		_attack_timer.stop()
	if _attack_recovery_timer.is_stopped() == false:
		_attack_recovery_timer.stop()
	
	var direction = knockback_dir.normalized()
	
	if state != "defend":
		health_ui.take_damage(amount)
		good_def = false
	else:
		good_def = true
	
	set_state("hitstun")
	
	if health_ui.player_dead == false:
		velocity.x = direction.x * knockback_strength
		velocity.z = direction.z * knockback_strength
		velocity.y = upward_force

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
		

func die() -> void:
	is_on_water = true
	_can_move = false
	combo_step = 0
	combo_queued = false
	is_knockback_active = true
	health_ui.take_damage(max_health)
