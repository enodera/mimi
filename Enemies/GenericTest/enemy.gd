extends CharacterBody3D

@export var knockback_strength: float = 10.0
@export var gravity: float = 9.8

var is_knocked_back: bool = false
var knockback_velocity: Vector3 = Vector3.ZERO
var knockback_timer: float = 0.1  # How long knockback lasts
var knockback_elapsed: float = 0.0

func _ready():
	$MeshInstance3D/Area3D.area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("playerattack"):
		print("Enemy hit by broom!")
		var direction = (global_transform.origin - area.global_transform.origin).normalized()
		apply_knockback(direction)

func apply_knockback(direction: Vector3) -> void:
	is_knocked_back = true
	knockback_elapsed = 0.0

	# Knockback force: horizontal + vertical
	direction.y = 0  # Optional: keep knockback flat
	knockback_velocity = direction * knockback_strength
	knockback_velocity.y = knockback_strength * 0.5  # Upward push

func _physics_process(delta: float) -> void:
	if is_knocked_back:
		knockback_elapsed += delta
		velocity = knockback_velocity

		# Gravity applies only to vertical component
		velocity.y -= gravity * delta

		if knockback_elapsed >= knockback_timer or is_on_floor():
			is_knocked_back = false
			knockback_velocity = Vector3.ZERO
	else:
		# Default gravity (if falling)
		if not is_on_floor():
			velocity.y -= gravity * delta
		else:
			velocity.x = 0
			velocity.y = 0
			velocity.z = 0

	move_and_slide()
