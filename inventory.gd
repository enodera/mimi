# inventory.gd

extends Node

class_name Inventory

# An array of dictionaries to hold item information
var items: Array[Dictionary] = []
var recipes: Array[Dictionary] = []

# Adds a new item to the inventory or increases its quantity
func add_item(item_id: String, amount: int = 1):
	var itemname = ItemDatabase.items[item_id]["name"]
	var item_type = ItemDatabase.items[item_id]["type"]
	print("Adding item:", item_id, "Name:", itemname, "Amount:", amount, "Type:", item_type)

	if amount == 1:
		NotificationUI.show_notification("You got %s!" % [itemname], 2.0)
	else:
		NotificationUI.show_notification("You got %s! (%d)" % [itemname, amount], 2.0)

	# Check if item already in inventory, add quantity if found
	for i in items:
		print("Checking existing item:", i)
		if i["id"] == item_id:
			i["quantity"] += amount
			print("Item found, new quantity:", i["quantity"])
			QuestManager.on_item_obtained(item_id, amount)
			return

	# Find insertion index to keep list sorted, with consumables first
	var insert_index = 0
	for idx in items.size():
		var current_item_id = items[idx]["id"]
		var current_item_data = ItemDatabase.items[current_item_id]
		var current_type = current_item_data["type"]
		var current_name = current_item_data["name"].to_lower()

		print("Comparing with item:", current_item_id, "Type:", current_type, "Name:", current_name)

		# First check type priority: consumables before others
		if item_type == "consumable" and current_type != "consumable":
			# New item is consumable but current is not, stop here to insert before
			break
		elif item_type != "consumable" and current_type == "consumable":
			# New item is not consumable but current is, keep going
			insert_index += 1
			continue
		else:
			# Same type group, compare by name
			if itemname.to_lower() < current_name:
				break
			insert_index += 1

	print("Inserting new item at index:", insert_index)
	items.insert(insert_index, {"id": item_id, "quantity": amount})
	
	QuestManager.on_item_obtained(item_id, amount)

func add_recipe(recipe_id: String):
	# Check if recipe already exists to avoid duplicates
	for r in recipes:
		if r["id"] == recipe_id:
			return  # Already have this recipe, no need to add
	# Add new recipe dictionary with id only (no quantity)
	recipes.append({"id": recipe_id})
	var recipename = ItemDatabase.recipes[recipe_id]["name"]
	NotificationUI.show_notification("New recipe unlocked: %s!" % recipename, 2.0)

# Removes an item from the inventory (if the quantity reaches 0)
func remove_item(item_id: String, amount: int = 1):
	for i in items:
		if i["id"] == item_id:
			i["quantity"] -= amount
			if i["quantity"] <= 0:
				items.erase(i)
			return

# Retrieves all items from the inventory
func get_items() -> Array:
	return items

func get_recipes() -> Array:
	return recipes

# Clears all recipes from the inventory
func clear_recipes():
	recipes.clear()
	print("All recipes cleared from inventory.")
