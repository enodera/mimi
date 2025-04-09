# ItemDatabase.gd (singleton)

extends Node

var items = {
	"health_potion": {
		"name": "Health Potion",
		"description": "Restores 50 health.",
		"type": "usable",
		"use_effect": "restore_health",
		"value": 10
	},
	"food": {
		"name": "Food",
		"description": "Tasty!",
		"type": "unusable",
		"use_effect": "none",
		"value": 50
	}
}

# You can also define more advanced functions for item effects, etc.
func get_item(id: String) -> Dictionary:
	return items.get(id, {})
