# inventoryui.gd

extends CanvasLayer

@onready var item_list = $Panel/VBoxContainer  # The container that holds item buttons
@onready var close_button = $Panel/CloseButton

var inventory: Inventory  # Reference to the inventory data

func _ready():
	# Initialize the inventory
	inventory = Inventory.new()
	
	# Add some items to test (remove or replace with your actual item-adding logic)
	inventory.add_item("health_potion", 5)
	inventory.add_item("food", 3)
	inventory.add_item("health_potion", 2)  # Adding 2 more Health Potions to demonstrate quantity increase
	
	# Update the UI
	update_ui()

	# Connect the button signal to close the inventory
	close_button.pressed.connect(self._on_close_button_pressed)

# This function updates the UI with the current inventory items
func update_ui():
	for child in item_list.get_children():
		child.queue_free()
	# Loop through each item in the inventory and create a label for it
	for item in inventory.get_items():
		
		var item_data = ItemDatabase.items[item["id"]]
		var display_text = item_data["name"] + " x" + str(item["quantity"])
		
		var node
		
		if item_data["type"] == "usable":
			node = Button.new()
			node.text = display_text
			# Optional: connect button press to some function
			node.pressed.connect(_on_item_pressed.bind(item))
		else:
			var label = Label.new()
			label.text = display_text
			label.autowrap_mode = TextServer.AUTOWRAP_WORD
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			node = label

		item_list.add_child(node)

# This function shows the hover text when the mouse enters an item button
func _on_item_hovered(item_name: String):
	# Show the hover text
	print(item_name + "!")
	
# This function hides the hover text when the mouse exits the item button
func _on_item_hover_exited():
	# Hide the hover text (in this case, we simply print an empty line)
	print("")
	
# Hide the inventory screen when the close button is pressed
func _on_close_button_pressed():
	visible = false
	Global.paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)  # Hide the mouse when inventory is closed
	Engine.time_scale = 1

func _on_item_pressed(item):
	print("Used item:", item["id"])
	if item["quantity"] > 1:
		item["quantity"] = item["quantity"] - 1
	else:
		inventory.remove_item(item["id"])
	update_ui()
