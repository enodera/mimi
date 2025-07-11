extends Node

enum QuestState {
	NOT_STARTED,
	IN_PROGRESS,
	COMPLETED
}

var quests := {}  # { "quest_id": QuestState }

# Embedded quest database
var quest_data := {
	"delivery_cake": {
		"title": "Strawberry Cake Delivery",
		"description": "Deliver 3 Strawberry Cakes to Liz.",
		"reward": "none",
		"type": "delivery",
		"item": "cake",
		"item_count": 3,
		"recipient": "liz"
	},
	"delivery_cookies": {
		"title": "Nut Cookies Delivery",
		"description": "Deliver 3 Nut Cookies to Liz.",
		"reward": "none",
		"type": "delivery",
		"item": "cookies",
		"item_count": 3,
		"recipient": "liz"
	},
	"delivery_pumpkin_pie": {
		"title": "Pumpkin Pie Delivery",
		"description": "Deliver 3 Pumpkin Pies to Liz.",
		"reward": "none",
		"type": "delivery",
		"item": "pumpkin_pie",
		"item_count": 3,
		"recipient": "liz"
	},
	"delivery_ice_cream": {
		"title": "Ice Cream Delivery",
		"description": "Deliver 3 Ice Creams to Liz.",
		"reward": "none",
		"type": "delivery",
		"item": "ice_cream",
		"item_count": 3,
		"recipient": "liz"
	},
	"delivery_mango_lassi": {
		"title": "Mango Lassi Delivery",
		"description": "Deliver 3 Mango Lassis to Liz.",
		"reward": "none",
		"type": "delivery",
		"item": "mango_lassi",
		"item_count": 3,
		"recipient": "liz"
	},
	"delivery_muffin": {
		"title": "Berry Muffin Delivery",
		"description": "Deliver 3 Berry Muffins to Liz.",
		"reward": "none",
		"type": "delivery",
		"item": "muffin",
		"item_count": 3,
		"recipient": "liz"
	},
	"delivery_carrot_cake": {
		"title": "Carrot Cake Delivery",
		"description": "Deliver 3 Carrot Cakes to Liz.",
		"reward": "none",
		"type": "delivery",
		"item": "carrot_cake",
		"item_count": 3,
		"recipient": "liz"
	},
	"elric_gathering": {
		"title": "Mangos for Elric",
		"description": "Deliver 3 Mangos to Elric.",
		"reward": "none",
		"type": "delivery",
		"item": "mango",
		"item_count": 3,
		"recipient": "elric"
	}
}

signal quest_started(quest_id)
signal quest_completed(quest_id)

# Get the ordered list of quest IDs
func get_quest_list() -> Array:
	return quest_data.keys()  # Returns an array of quest IDs in the order they were defined

func get_active_quest_list() -> Array:
	return quests.keys()  # Returns an array of quest IDs in the order they were defined

# Function to get a quest's index in the list
func get_quest_index(quest_id: String) -> int:
	var quest_list = get_quest_list()
	for i in range(quest_list.size()):
		if quest_list[i] == quest_id:
			return i
	return -1  # Return -1 if quest_id is not found

# Function to check if a quest has a next quest
func has_next_quest(quest_id: String) -> bool:
	var index = get_quest_index(quest_id)
	var quest_list = get_quest_list()
	return index != -1 and index < quest_list.size() - 1

func start_quest(quest_id: String) -> void:
	if not quests.has(quest_id):
		quests[quest_id] = QuestState.IN_PROGRESS
		print("Quest started:", quest_id)
		emit_signal("quest_started", quest_id)
	else:
		print("Quest already exists:", quest_id)

func complete_quest(quest_id: String) -> void:
	if quests.has(quest_id) and quests[quest_id] == QuestState.IN_PROGRESS:
		quests[quest_id] = QuestState.COMPLETED
		print("Quest completed:", quest_id)
		emit_signal("quest_completed", quest_id)
		if are_all_liz_delivery_quests_completed():
			print("All Liz delivery quests completed. Going to title screen.")
			Global.gamedone = true

func is_quest_started(quest_id: String) -> bool:
	return quests.get(quest_id, QuestState.NOT_STARTED) != QuestState.NOT_STARTED

func is_quest_completed(quest_id: String) -> bool:
	return quests.get(quest_id, QuestState.NOT_STARTED) == QuestState.COMPLETED

func get_quest_info(quest_id: String) -> Dictionary:
	return quest_data.get(quest_id, {})  # Safe fallback

func reset_quests():
	quests.clear()
	for quest_id in quest_data.keys():
		var data = quest_data[quest_id]
		if data.has("delivered"):
			data.erase("delivered")
		if data.has("progress"):
			data.erase("progress")

func on_enemy_defeated(enemy_type: String) -> void:
	for quest_id in quests.keys():
		if quests[quest_id] == QuestState.IN_PROGRESS:
			var data = quest_data.get(quest_id, {})
			if data.get("type") == "kill" and data.get("target_enemy") == enemy_type:
				if not data.has("progress"):
					data["progress"] = 0
				data["progress"] += 1
				print("Progress for", quest_id, ":", data["progress"], "/", data.get("target_count", 0))
				if data["progress"] >= data.get("target_count", 0):
					complete_quest(quest_id)

func on_item_obtained(item_type: String, quantity: int) -> void:
	print("on_item_obtained: You got ", quantity, " ", item_type)
	for quest_id in quests.keys():
		if quests[quest_id] == QuestState.IN_PROGRESS:
			var data = quest_data.get(quest_id, {})
			if data.get("type") == "collect" and data.get("target_item") == item_type:
				if not data.has("progress"):
					data["progress"] = 0
				data["progress"] += quantity
				print("Progress for ", quest_id, ":", data["progress"], "/", data.get("target_count", 0))
				if data["progress"] >= data.get("target_count", 0):
					print("Mission complete:", quest_id)
					complete_quest(quest_id)

func on_item_delivered(quest_id: String) -> String:
	var next_line = quest_id
	var completed = "fail"

	print("on_item_delivered: Called with quest_id =", quest_id)

	if quests.has(quest_id):
		print("on_item_delivered: Quest exists.")

		if quests[quest_id] == QuestState.NOT_STARTED:
			#THIS DOESNT WORK, refer to else
			print("on_item_delivered: Quest not started. Starting quest now.")
			start_quest(quest_id)
			completed = "start"
			next_line += "_" + completed

		elif quests[quest_id] == QuestState.IN_PROGRESS:
			print("on_item_delivered: Quest is in progress.")


			var data = quest_data.get(quest_id, {})
			print("on_item_delivered: Quest data retrieved:", data)

			if data.get("type") == "delivery":
				print("on_item_delivered: Quest type is delivery.")

				var required_item = data.get("item")
				var required_count = data.get("item_count", 0)
				print("on_item_delivered: Required item =", required_item, ", required count =", required_count)

				# Get how many items player currently has from global inventory_ref by searching items directly
				var player_has = 0
				for i in Global.inventory_ref.items:
					if i["id"] == required_item:
						player_has = i["quantity"]
						break

				print("on_item_delivered: Player currently has", player_has, required_item)

				if player_has <= 0:
					print("on_item_delivered: No items to deliver for", quest_id)
					return next_line + "_" + completed  # No items to deliver
				
				# Calculate how many items to deliver this time (can't deliver more than required)
				var deliver_count = required_count
				if data.has("delivered"):
					var already_delivered = data["delivered"]
					var remaining = required_count - already_delivered
					deliver_count = min(player_has, remaining)
					print("on_item_delivered: Already delivered =", already_delivered, ", remaining =", remaining)
				else:
					deliver_count = min(player_has, required_count)
					print("on_item_delivered: No previous deliveries recorded.")

				print("on_item_delivered: Deliver count determined as", deliver_count)

				if deliver_count <= 0:
					print("on_item_delivered: Already delivered enough items for", quest_id)
					return next_line + "_" + completed

				# Remove items from global inventory_ref
				Global.inventory_ref.remove_item(required_item, deliver_count)
				print("on_item_delivered: Removed", deliver_count, required_item, "from inventory.")

				# Update delivered count
				if not data.has("delivered"):
					data["delivered"] = 0
				data["delivered"] += deliver_count
				print("on_item_delivered: Updated delivered count:", data["delivered"], "/", required_count)

				# Check if quest complete
				if data["delivered"] >= required_count:
					print("on_item_delivered: Required items delivered. Completing quest.")
					complete_quest(quest_id)
					completed = "done"
				else:
					print("on_item_delivered: Quest not yet complete.")
			next_line += "_" + completed
		
		else:
			print("on_item_delivered: quest already done:", quest_id)
			next_line = "already_done_quest"
			
	else:
		print("Quest check: ", quests, quests.keys())
		for q in quests.keys():
			if quests[q] == QuestState.IN_PROGRESS:
				print("on_item_delivered: Quest already started. Can't start.")
				return "quest_already"
		print("on_item_delivered: Quest not started. Starting quest now.")
		start_quest(quest_id)
		completed = "start"
		next_line += "_" + completed

	return next_line

func are_all_liz_delivery_quests_completed() -> bool:
	for quest_id in quest_data.keys():
		var data = quest_data[quest_id]
		if data.get("type") == "delivery" and data.get("recipient") == "liz":
			if not is_quest_completed(quest_id):
				return false
	return true
