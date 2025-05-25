extends CharacterBody3D

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D

enum State { PATROL, ATTACK, DAMAGE }
enum Class { FROG }

@onready var class_models = {
	Class.FROG: %frog
}

@export_group("Physics")
@export var knockback_strength: float = 75.0
@export var gravity: float = 125.0

@export_group("Stats")
@export var health: float = 10.0

@export_group("Movement")
@export var patrol_speed: float = 40.0
@export var chase_speed: float = 6.0
@export var patrol_wait_time: float = 1.5
@export var patrol_bounds_area: Area3D
@export var melee_range: float = 3.0
@export var vision_range: float = 10.0

@export var max_wait: float = 1.0
@export var min_wait: float = 2.0
@export var player: Node3D

@export_group("Enemy type")
@export var selectedtype: Class = Class.FROG

var state: State = State.PATROL
var mesh: Node3D

var waiting: bool = false
var wait_timer: float = 0.0

var is_knocked_back: bool = false
var knockback_velocity: Vector3 = Vector3.ZERO
var knockback_elapsed: float = 0.0
var playeraggroable = true

func _ready() -> void:
	$MeshInstance3D/Area3D.area_entered.connect(_on_area_entered)
	$VisibilityRange.body_entered.connect(_on_vision_body_entered)
	$VisibilityRange.body_exited.connect(_on_vision_body_exited)
	var player = %Player
	mesh = class_models[selectedtype]
	_pick_new_target()

var target_velocity: Vector3 = Vector3.ZERO

func _physics_process(delta: float) -> void:

	match state:

		State.PATROL:
			if waiting:
				wait_timer -= delta
				if wait_timer <= 0:
					waiting = false
					_pick_new_target()
			else:
				if navigation_agent_3d.is_navigation_finished():
					waiting = true
					wait_timer = randf_range(min_wait, max_wait)
					target_velocity = Vector3.ZERO
				else:
					var destination = navigation_agent_3d.get_next_path_position()
					var direction = (destination - global_position).normalized()
					target_velocity = direction * patrol_speed
					
			if not is_on_floor():
				velocity.y -= gravity * delta
			else:
				velocity.y = 0

		State.ATTACK:
			if player:
				var direction = (player.global_position - global_position).normalized()
				target_velocity = direction * chase_speed
			if not is_on_floor():
				velocity.y -= gravity * delta
			else:
				velocity.y = 0

		State.DAMAGE:
			if is_knocked_back:
				knockback_elapsed += delta
				velocity.x = knockback_velocity.x
				velocity.z = knockback_velocity.z
			
			if not is_on_floor():
				velocity.y -= gravity * delta
			else:
				if playeraggroable == true:
					state = State.ATTACK
				else:
					state = State.PATROL
				print(state)

	# Smoothly interpolate velocity towards target_velocity
	velocity = velocity.lerp(target_velocity, 0.25)

	if state == State.ATTACK and player:
		var look_dir = (player.global_position - global_position).normalized()
		look_dir.y = 0  # Keep the look direction horizontal
		if look_dir.length() > 0.1:
			var target = global_position + look_dir
			var direction = (target - mesh.global_position).normalized()
			var target_angle = atan2(direction.x, direction.z)
			mesh.rotation.y = lerp_angle(mesh.rotation.y, target_angle - deg_to_rad(90), delta * 5.0)

	elif state == State.PATROL and not waiting and not navigation_agent_3d.is_navigation_finished():
		var look_dir = (navigation_agent_3d.get_next_path_position() - global_position).normalized()
		look_dir.y = 0
		if look_dir.length() > 0.1:
			var target = global_position + look_dir
			var direction = (target - mesh.global_position).normalized()
			var target_angle = atan2(direction.x, direction.z)
			mesh.rotation.y = lerp_angle(mesh.rotation.y, target_angle - deg_to_rad(90), delta * 5.0)
			
	move_and_slide()

func _pick_new_target() -> void:
	var center = patrol_bounds_area.global_position
	var random_position = Vector3(
		randf_range(center.x - 15.0, center.x + 15.0),
		global_position.y,
		randf_range(center.z - 15.0, center.z + 15.0)
	)
	navigation_agent_3d.set_target_position(random_position)

func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("playerattack"):
		var direction = (global_transform.origin - area.global_transform.origin).normalized()
		print(direction)
		apply_knockback(direction)
		health -= 1.0
		print("ENEMY: Took damage! Health now: ", health)

func _on_vision_body_entered(body):
	if body.is_in_group("player"):
		player = body
		state = State.ATTACK
		playeraggroable = true
		print("ENEMY: Spotted player! Switching to ATTACK.")

func _on_vision_body_exited(body):
	if body.is_in_group("player"):
		player = null
		state = State.PATROL
		playeraggroable = false
		print("ENEMY: Player left vision.")
		

func apply_knockback(direction: Vector3) -> void:
	is_knocked_back = true
	state = State.DAMAGE
	knockback_elapsed = 0.0
	direction.y = 0
	knockback_velocity = direction * knockback_strength
	knockback_velocity.y = knockback_strength * 0.5
	velocity.y = knockback_velocity.y
	
	print("ENEMY: Knocked back!")
