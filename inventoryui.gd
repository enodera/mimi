# inventoryui.gd

extends CanvasLayer

# --- UI Node References ---
@onready var item_list = $Panel/ScrollContainer/VBoxContainer  # The container that holds item buttons
@onready var close_button = $Panel/CloseButton  # Close button to hide inventory UI

# --- Inventory State ---
var justupdated = true  # Flag to track whether the hover text was updated
var inventory: Inventory  # Reference to the inventory data object

# --- Initialization ---
func _ready():
	# Initialize the inventory object (this can be replaced with actual inventory logic)
	inventory = Inventory.new()
	$Panel.scale = Vector2(0, 0)
	
	# Add some test items to the inventory (can be replaced with actual item-adding logic)
	inventory.add_item("health_potion", 5)  # Add 5 health potions
	inventory.add_item("food", 3)  # Add 3 food items
	inventory.add_item("health_potion", 2)  # Add 2 more health potions to demonstrate quantity increase
	inventory.add_item("flour", 4)  # Add 4 flour items
	inventory.add_item("flour", 4)  # Add 4 flour itemsw
	
	# Update the UI to reflect the current inventory
	update_ui()
	
	# Connect the close button's press signal to the function to close the inventory
	close_button.pressed.connect(self._on_close_button_pressed)


# --- UI Update ---
# This function updates the UI based on the current items in the inventory
func update_ui():
	for child in item_list.get_children():
		child.queue_free()

	for item in inventory.get_items():
		var item_data = ItemDatabase.items[item["id"]]
		var display_text = item_data["name"] + " x" + str(item["quantity"])
		var item_description = item_data["description"]
		
		var node
		var container = MarginContainer.new()  # For offset and padding
		container.add_theme_constant_override("margin_left", 30)
		container.add_theme_constant_override("margin_right", 40)
		container.add_theme_constant_override("margin_top", 2)     # Space above
		container.add_theme_constant_override("margin_bottom", 2)  # Space below


		if item_data["type"] == "usable":
			node = Button.new()
			node.text = display_text
			node.pressed.connect(_on_item_pressed.bind(item))
		else:
			node = Label.new()
			node.text = display_text
			node.autowrap_mode = TextServer.AUTOWRAP_WORD
			node.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			node.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		node.custom_minimum_size = Vector2(300, 20)  # Wider and taller
		node.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		container.add_child(node)
		item_list.add_child(container)

		node.mouse_entered.connect(_on_item_hovered.bind(item_description))
		node.mouse_exited.connect(_on_item_hover_exited)

func show_inventory():
	visible = true
	Global.paused = true
	$Panel.scale = Vector2(0, 0)  # Start small
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Engine.time_scale = 0.0001
	await get_tree().process_frame
	
	var tween := create_tween()
	tween.tween_property($Panel, "scale", Vector2(1, 1), 0.00002).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(0.00002).timeout
	
	print("hi")
	

# --- Hover Effect ---
# This function is called when the mouse hovers over an item button (shows item description)
func _on_item_hovered(item_description: String):
	# Display the item's description in the designated UI area
	%ItemDescription.text = item_description
	print(item_description + " It works!")  # Debugging print statement to confirm hover
	justupdated = false  # Set justupdated to false to indicate hover is active

# This function is called when the mouse exits an item button (hides item description)
func _on_item_hover_exited():
	# Hide the item's description when the mouse leaves the button
	await get_tree().create_timer(0.00000001).timeout  # Small delay to avoid instant disappearance
	if not justupdated:
		%ItemDescription.text = ""  # Clear the description text
		print("Bye!")  # Debugging print statement to confirm exit


# --- Close Inventory ---
# This function is triggered when the close button is pressed to hide the inventory UI
func _on_close_button_pressed():
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$Panel.scale = Vector2(1, 1)
	var tween := create_tween()
	tween.tween_property($Panel, "scale", Vector2(0, 0), 0.00002).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(0.00002).timeout
	
	visible = false  # Hide the inventory UI
	Engine.time_scale = 1
	Global.paused = false
	print("bye")

# --- Item Interaction ---
# This function handles the action when an item button is pressed (e.g., using or consuming an item)
func _on_item_pressed(item):
	print("Used item: ", item["id"])  # Debugging print statement for item usage
	# If the item has more than 1 quantity, decrease the quantity by 1
	if item["quantity"] > 1:
		item["quantity"] = item["quantity"] - 1
	else:
		# If quantity is 1, remove the item from the inventory
		inventory.remove_item(item["id"])
		%ItemDescription.text = ""  # Clear the item description text after use
	justupdated = true  # Set justupdated to true after item usage to reflect changes in UI
	update_ui()  # Update the UI to reflect the new inventory state
