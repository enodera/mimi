extends Node3D

@export_enum(
	"almond", "apple", "banana", "blueberry", "carrot", "coconut", "grape",
	"kiwi", "lemon", "lime", "litchi", "mango", "mangosteen", "melon", "orange",
	"papaya", "peach", "peanut", "pear", "pineapple", "pumpkin", "raspberry",
	"starfruit", "strawberry", "watermelon", "sugar", "butter", "egg", "ice",
	"milk", "flour", "fruit_salad", "smoothie", "cake", "cookies", "pumpkin_pie",
	"fruit_pie", "ice_cream", "candied_fruit", "mango_lassi", "muffin", "carrot_cake"
)

var item_id: String = "apple"
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
	
	show_item(item_id)

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
	
	show_item("none")
	
	$PickupParticles.emitting = true

	# Add to inventory
	var inventory := Global.inventory_ref
	inventory.add_item(item_id, quantity)

	# Start respawn timer asynchronously
	await get_tree().create_timer(respawn_time).timeout
	respawn_item()

func respawn_item():
	collected = false

	show_item(item_id)

	$Label3D.text = "Press E to pick up"

func show_item(id: String):
	var item_container = $Item

	for child in item_container.get_children():
		child.visible = false

	if id == "none":
		return

	if item_container.has_node(id):
		var item_node = item_container.get_node(id)
		item_node.visible = true
