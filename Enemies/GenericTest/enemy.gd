extends CharacterBody3D

enum State { PATROL, ATTACK, DAMAGE }
var state: State = State.PATROL

@export var knockback_strength: float = 10.0
@export var gravity: float = 9.8
@export var health: float = 10.0
@export var patrol_speed: float = 3.0
@export var chase_speed: float = 6.0
@export var patrol_wait_time: float = 1.5
@export var patrol_bounds_area: Area3D
@export var melee_range: float = 3.0
@export var vision_range: float = 10.0

var is_knocked_back: bool = false
var knockback_velocity: Vector3 = Vector3.ZERO
var knockback_timer: float = 0.1
var knockback_elapsed: float = 0.0

var player: Node3D = null
var patrol_target: Vector3 = Vector3.ZERO
var rng = RandomNumberGenerator.new()

@onready var patrol_timer: Timer = $PatrolTimer
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

func _ready():
	rng.randomize()

	$MeshInstance3D/Area3D.area_entered.connect(_on_area_entered)
	$VisibilityRange.body_entered.connect(_on_vision_body_entered)
	$VisibilityRange.body_exited.connect(_on_vision_body_exited)
	$MeleeAttackRange.body_entered.connect(_on_attack_range_entered)
	$MeleeAttackRange.body_exited.connect(_on_attack_range_exited)
	patrol_timer.timeout.connect(_on_patrol_timer_timeout)

	pick_new_patrol_point()
	patrol_timer.start(patrol_wait_time)
	print("ENEMY: Ready. Starting in PATROL state.")

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0

	if not nav_agent.is_navigation_finished():
		print("ENEMY: Has a path.")
	else:
		print("ENEMY: No valid path.")

	match state:
		State.DAMAGE:
			if is_knocked_back:
				knockback_elapsed += delta
				velocity.x = knockback_velocity.x
				velocity.z = knockback_velocity.z

				if knockback_elapsed >= knockback_timer or is_on_floor():
					is_knocked_back = false
					knockback_velocity = Vector3.ZERO
					state = State.ATTACK if player and is_player_in_vision() else State.PATROL
					print("ENEMY: Knockback ended. New state: ", state)

		State.ATTACK:
			if player and player.is_inside_tree():
				if is_player_in_vision():
					print("ENEMY: Chasing player.")
					nav_agent.target_position = player.global_transform.origin
					move_with_agent(chase_speed)
				else:
					print("ENEMY: Lost sight of player. Switching to PATROL.")
					player = null
					state = State.PATROL
			else:
				print("ENEMY: Player missing from tree. Switching to PATROL.")
				state = State.PATROL

		State.PATROL:
			if nav_agent.is_navigation_finished():
				print("ENEMY: Reached patrol target.")
				pick_new_patrol_point()
				patrol_timer.start(patrol_wait_time)
			else:
				move_with_agent(patrol_speed)

	move_and_slide()
	print("ENEMY: Velocity = ", velocity)

func move_with_agent(speed: float) -> void:
	var next_pos = nav_agent.get_next_path_position()
	var dir = next_pos - global_transform.origin
	dir.y = 0

	if dir.length() > 0.1:
		var move = dir.normalized() * speed
		velocity.x = move.x
		velocity.z = move.z
		print("ENEMY: Moving toward ", next_pos, " at speed ", speed)
	else:
		velocity.x = 0
		velocity.z = 0
		print("ENEMY: Close enough to stop.")

func is_player_in_vision() -> bool:
	if player == null:
		return false
	var dist = global_transform.origin.distance_to(player.global_transform.origin)
	return dist <= vision_range

func pick_new_patrol_point():
	if patrol_bounds_area == null:
		printerr("ENEMY: No patrol_bounds_area assigned!")
		return

	var shape = patrol_bounds_area.get_node("CollisionShape3D").shape
	if shape is CylinderShape3D:
		var radius = shape.radius
		var origin = patrol_bounds_area.global_transform.origin

		var angle = rng.randf_range(0, TAU)
		var r = rng.randf_range(0, radius)
		var x = r * cos(angle)
		var z = r * sin(angle)
		patrol_target = origin + Vector3(x, 0, z)

		print("ENEMY: New patrol target picked at ", patrol_target)
		nav_agent.target_position = patrol_target

func _on_patrol_timer_timeout():
	if state == State.PATROL:
		print("ENEMY: Patrol timer expired, picking new target.")
		pick_new_patrol_point()
		patrol_timer.start(patrol_wait_time)

func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("playerattack"):
		var direction = (global_transform.origin - area.global_transform.origin).normalized()
		apply_knockback(direction)
		health -= 1.0
		print("ENEMY: Took damage! Health now: ", health)
		if health <= 0:
			die()

func _on_vision_body_entered(body):
	if body.is_in_group("player") and state != State.DAMAGE:
		player = body
		state = State.ATTACK
		print("ENEMY: Spotted player! Switching to ATTACK.")

func _on_vision_body_exited(body):
	if body == player:
		print("ENEMY: Player left vision.")
		player = null
		if state == State.ATTACK:
			state = State.PATROL
			print("ENEMY: Returning to PATROL.")

func _on_attack_range_entered(body): pass
func _on_attack_range_exited(body): pass

func apply_knockback(direction: Vector3) -> void:
	is_knocked_back = true
	state = State.DAMAGE
	knockback_elapsed = 0.0
	direction.y = 0
	knockback_velocity = direction * knockback_strength
	knockback_velocity.y = knockback_strength * 0.5
	velocity.x = 0
	velocity.z = 0
	player = null
	print("ENEMY: Knocked back!")

func die():
	print("ENEMY: Dying...")
	var exploding_timer := Timer.new()
	exploding_timer.one_shot = true
	exploding_timer.wait_time = 0.5
	add_child(exploding_timer)
	exploding_timer.start()
	await exploding_timer.timeout
	queue_free()
