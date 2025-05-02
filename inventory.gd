# inventory.gd

extends Node

class_name Inventory

# An array of dictionaries to hold item information
var items: Array[Dictionary] = []

# Adds a new item to the inventory or increases its quantity
func add_item(item_id: String, amount: int = 1):
	var itemname = ItemDatabase.items[item_id]["name"]
	if amount == 1:
		NotificationUI.show_notification("You got %s!" % [itemname], 2.0)
	else:
		NotificationUI.show_notification("You got %s! (%d)" % [itemname, amount], 2.0)
	
	for i in items:
		if i["id"] == item_id:
			i["quantity"] += amount
			return
			
	items.append({"id": item_id, "quantity": amount})

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
