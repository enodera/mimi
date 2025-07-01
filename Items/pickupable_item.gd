extends Node3D

@export_enum("fruit_salad", "smoothie", "cake", "cookies", "pumpkin_pie", "fruit_pie", "ice_cream", "candied_fruit", "lemon_bar", "muffin", "coconut_ball")
var recipe_id: String = "fruit_salad"

@export var despawn_time: float = 2.0  # In seconds
@export var pickupable: bool = true  # Toggle if the item can be picked up
@export var spin_speed: float = 1.5   # Rotation speed in radians per second

func _ready():
	$Area3D.body_entered.connect(_on_body_entered)
	$book.visible = true

func _process(delta):
	# Spin around Y axis
	rotate_y(spin_speed * delta)

func _on_body_entered(body):
	if pickupable and body.is_in_group("player"):
		collect_item()

func collect_item():
	# Hide visuals
	if has_node("MeshInstance3D"):
		$MeshInstance3D.visible = false
	elif has_node("Sprite3D"):
		$Sprite3D.visible = false

	# Play particle effect
	$PickupParticles.emitting = true
	$book.visible = false

	# Add item to inventory
	var inventory := Global.inventory_ref
	if inventory:
		inventory.add_recipe(recipe_id)

	# Start respawn
	await get_tree().create_timer(despawn_time).timeout
	queue_free()
