extends Node3D

@export var item_id: String = "health_potion"
@export var quantity: int = 1
@export var respawn_time: float = 10.0  # In seconds
@export var pickupable: bool = true  # Toggle if the item can be picked up

var player_in_range := false
var collected := false
var respawn_timer := 0.0

func _ready():
	$Area3D.body_entered.connect(_on_body_entered)
	$Area3D.body_exited.connect(_on_body_exited)
	$Label3D.visible = false

func _process(delta):
	if player_in_range and not collected and pickupable:
		$Label3D.visible = true
		$Label3D.text = "Press E to pick up"
	else:
		$Label3D.visible = false

	if collected:
		respawn_timer -= delta
		if player_in_range:
			$Label3D.visible = true
			$Label3D.text = "Respawns in %.1f" % max(respawn_timer, 0.0)

	if player_in_range and Input.is_action_just_pressed("interact") and not collected and pickupable:
		collect_item()

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
		$Label3D.visible = false

func collect_item():
	collected = true
	respawn_timer = respawn_time
	if has_node("MeshInstance3D"):
		$MeshInstance3D.visible = false
	elif has_node("Sprite3D"):
		$Sprite3D.visible = false
		
	$PickupParticles.emitting = true

	# Add to inventory
	var inventory := Global.inventory_ref
	inventory.add_item(item_id, quantity)

	# Start respawn timer asynchronously
	await get_tree().create_timer(respawn_time).timeout
	respawn_item()

func respawn_item():
	collected = false

	if has_node("MeshInstance3D"):
		$MeshInstance3D.visible = true
	elif has_node("Sprite3D"):
		$Sprite3D.visible = true

	$Label3D.text = "Press E to pick up"
