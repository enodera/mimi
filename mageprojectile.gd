extends Node3D

@export var speed: float = 22.5
@export var lifetime: float = 1.0
@export var damage: int = 5
@export var knockback_force: float = 10.0
@export var homing_strength: float = 4.5 # How fast to turn toward the player

var direction: Vector3 = Vector3.FORWARD
var exploded: bool = false

var player: Node3D = null  # Store reference to player
var smalladjust = null;

func _ready():
	$Area3D.body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	if exploded:
		return
	
	if player and player.is_inside_tree():
		var target_dir = (player.global_position - global_position)
		target_dir.y += 2  # Add upward offset here (adjust 0.5 to your liking)
		target_dir = target_dir.normalized()
		# Slerp (spherical linear interpolation) smooths the direction change
		direction = direction.slerp(target_dir, homing_strength * delta).normalized()
	
	# Move the projectile forward in current direction
	global_position += direction * speed * delta
	
	# Decrease lifetime and explode if needed
	lifetime -= delta
	if lifetime <= 0:
		_explode_and_cleanup()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage, direction, knockback_force, 30.0)
		_explode_and_cleanup()

func _explode_and_cleanup() -> void:
	exploded = true
	
	$ShineParticles.emitting = false
	speed = 0.0
	
	if $MeshInstance3D:
		$MeshInstance3D.visible = false
	
	$Area3D.set_deferred("monitoring" ,false)
	$Area3D.body_entered.disconnect(_on_body_entered)
	
	$DeathParticles.restart()
	$DeathParticles.emitting = true
	await get_tree().create_timer($DeathParticles.lifetime).timeout
	
	queue_free()
