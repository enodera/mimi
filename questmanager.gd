extends Node

enum QuestState {
	NOT_STARTED,
	IN_PROGRESS,
	COMPLETED
}

var quests := {}  # { "quest_id": QuestState }

# Embedded quest database
var quest_data := {
	"lemons_for_liz": {
		"title": "Lemons for Liz",
		"description": "Liz needs some lemons. Deliver 3 lemons to her.",
		"reward": "100 Gold",
		"type": "delivery",
		"item": "lemon",
		"item_count": 3,
		"recipient": "liz"
	},
	"collect_lemons": {
		"title": "Get some lemons!",
		"description": "Get 5 lemons to start cooking!",
		"reward": "muffin",
		"type": "collect",
		"target_item": "lemon",
		"target_count": 5
	},
	"defeat_frogs": {
		"title": "Frogs!",
		"description": "Frogs have taken over! Defeat 3 of them to restore peace.",
		"reward": "lemon",
		"type": "kill",
		"target_enemy": "frog",
		"target_count": 3
	}
}

signal quest_started(quest_id)
signal quest_completed(quest_id)

# Get the ordered list of quest IDs
func get_quest_list() -> Array:
	return quest_data.keys()  # Returns an array of quest IDs in the order they were defined

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

func is_quest_started(quest_id: String) -> bool:
	return quests.get(quest_id, QuestState.NOT_STARTED) != QuestState.NOT_STARTED

func is_quest_completed(quest_id: String) -> bool:
	return quests.get(quest_id, QuestState.NOT_STARTED) == QuestState.COMPLETED

func get_quest_info(quest_id: String) -> Dictionary:
	return quest_data.get(quest_id, {})  # Safe fallback

func reset_quests():
	quests.clear()

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
		print("on_item_delivered: Quest not started. Starting quest now.")
		start_quest(quest_id)
		completed = "start"
		next_line += "_" + completed

	return next_line
