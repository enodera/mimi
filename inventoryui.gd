# inventoryui.gd

extends CanvasLayer

# --- UI Node References ---
@onready var item_list = $Panel/VBoxContainer  # The container that holds item buttons
@onready var close_button = $Panel/CloseButton  # Close button to hide inventory UI

# --- Inventory State ---
var justupdated = true  # Flag to track whether the hover text was updated
var inventory: Inventory  # Reference to the inventory data object

# --- Initialization ---
func _ready():
	# Initialize the inventory object (this can be replaced with actual inventory logic)
	inventory = Inventory.new()
	
	# Add some test items to the inventory (can be replaced with actual item-adding logic)
	inventory.add_item("health_potion", 5)  # Add 5 health potions
	inventory.add_item("food", 3)  # Add 3 food items
	inventory.add_item("health_potion", 2)  # Add 2 more health potions to demonstrate quantity increase
	inventory.add_item("flour", 4)  # Add 4 flour items
	
	# Update the UI to reflect the current inventory
	update_ui()

	# Connect the close button's press signal to the function to close the inventory
	close_button.pressed.connect(self._on_close_button_pressed)


# --- UI Update ---
# This function updates the UI based on the current items in the inventory
func update_ui():
	# First, remove all current item nodes (e.g., buttons or labels) in the list
	for child in item_list.get_children():
		child.queue_free()

	# Loop through each item in the inventory and create a corresponding label or button
	for item in inventory.get_items():
		# Retrieve the data for the item from the ItemDatabase
		var item_data = ItemDatabase.items[item["id"]]
		# Create a display string for the item (e.g., "Health Potion x5")
		var display_text = item_data["name"] + " x" + str(item["quantity"])
		var item_description = item_data["description"]  # The description of the item
		
		var node  # Will hold the UI element (either a Button or Label)
		
		# Check the type of the item (if it's "usable", create a Button; otherwise, a Label)
		if item_data["type"] == "usable":
			node = Button.new()
			node.text = display_text
			# Optionally, connect the button press to the item usage function
			node.pressed.connect(_on_item_pressed.bind(item))
		else:
			node = Label.new()
			node.text = display_text
			node.autowrap_mode = TextServer.AUTOWRAP_WORD  # Ensure the text wraps correctly
			node.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER  # Center-align the text
			node.size_flags_horizontal = Control.SIZE_EXPAND_FILL  # Make label expand horizontally

		# Add the created node to the item list container
		item_list.add_child(node)

		# Connect mouse events for hover (to show item description)
		node.mouse_entered.connect(_on_item_hovered.bind(item_description))
		node.mouse_exited.connect(_on_item_hover_exited)


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
	visible = false  # Hide the inventory UI
	Global.paused = false  # Resume the game
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)  # Hide the mouse cursor when inventory is closed
	Engine.time_scale = 1  # Ensure the game time is running normally


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
