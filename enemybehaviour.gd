extends CharacterBody3D

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D

@export_group("Physics")
@export var knockback_strength: float = 10.0
@export var gravity: float = 9.8

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

var waiting: bool = false
var wait_timer: float = 0.0

func _ready() -> void:
	$MeshInstance3D/Area3D.area_entered.connect(_on_area_entered)
	_pick_new_target()

var target_velocity: Vector3 = Vector3.ZERO

func _physics_process(delta: float) -> void:
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

	# Smoothly interpolate velocity towards target_velocity
	velocity = velocity.lerp(target_velocity, 0.1)

	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0

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
		health -= 1.0
		print("ENEMY: Took damage! Health now: ", health)
