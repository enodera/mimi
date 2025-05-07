extends Node

enum QuestState {
	NOT_STARTED,
	IN_PROGRESS,
	COMPLETED
}

var quests := {}  # { "quest_id": QuestState }

# 🗃️ Embedded quest database
var quest_data := {
	"find_lost_sword": {
		"title": "Find the Lost Sword",
		"description": "The blacksmith lost his family sword in the forest.",
		"reward": "100 Gold"
	},
	"rescue_villager": {
		"title": "Rescue the Villager",
		"description": "A villager is trapped in the goblin cave.",
		"reward": "Potion of Strength"
	},
	"defeat_cave_troll": {
		"title": "Defeat the Cave Troll",
		"description": "A troll has taken residence near the mines.",
		"reward": "Troll Fang"
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
	if quests.has(quest_id) and quests[quest_id] != QuestState.COMPLETED:
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
