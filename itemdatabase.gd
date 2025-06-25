extends Node

var items = {
	"almond": {
		"name": "Almond",
		"description": "A crunchy nut.\nIngredient.",
		"type": "unusable",
		"use_effect": "none",
		"stackable": "yes",
		"value": 5
	},

	"apple": {
		"name": "Apple",
		"description": "A juicy apple.\nIngredient.",
		"type": "unusable",
		"use_effect": "none",
		"stackable": "yes",
		"value": 8
	},

	"banana": {
		"name": "Banana",
		"description": "Rich in potassium.\nIngredient.",
		"type": "unusable",
		"use_effect": "none",
		"stackable": "yes",
		"value": 7
	},

	"blueberry": {
		"name": "Blueberry",
		"description": "Small and sweet.\nIngredient.",
		"type": "unusable",
		"use_effect": "none",
		"stackable": "yes",
		"value": 6
	},

	"carrot": {
		"name": "Carrot",
		"description": "Good for your eyes.\nIngredient.",
		"type": "unusable",
		"use_effect": "none",
		"stackable": "yes",
		"value": 4
	},

	"coconut": {
		"name": "Coconut",
		"description": "Hard outside,\nbut soft inside.\nIngredient.",
		"type": "unusable",
		"use_effect": "none",
		"stackable": "no",
		"value": 12
	},

	"grape": {
		"name": "Grape",
		"description": "Juicy and sweet.\nIngredient.",
		"type": "unusable",
		"use_effect": "none",
		"stackable": "yes",
		"value": 5
	},

	"kiwi": {
		"name": "Kiwi",
		"description": "Tangy and sweet.\nIngredient.",
		"type": "unusable",
		"use_effect": "none",
		"stackable": "yes",
		"value": 9
	},

	"lemon": {
		"name": "Lemon",
		"description": "Very sour!\nIngredient.",
		"type": "unusable",
		"use_effect": "none",
		"stackable": "yes",
		"value": 5
	},

	"lime": {
		"name": "Lime",
		"description": "Sour and zesty.\nIngredient.",
		"type": "unusable",
		"use_effect": "none",
		"stackable": "yes",
		"value": 5
	},

	"litchi": {
		"name": "Litchi",
		"description": "Delicately sweet fruit.\nIngredient.",
		"type": "unusable",
		"use_effect": "none",
		"stackable": "yes",
		"value": 10
	},

	"mango": {
		"name": "Mango",
		"description": "Sweet and juicy.\nIngredient.",
		"type": "unusable",
		"use_effect": "none",
		"stackable": "yes",
		"value": 10
	},

	"mangosteen": {
		"name": "Mangosteen",
		"description": "Rare tropical fruit.\nIngredient.",
		"type": "unusable",
		"use_effect": "none",
		"stackable": "no",
		"value": 15
	},

	"melon": {
		"name": "Melon",
		"description": "Refreshing and juicy.\nIngredient.",
		"type": "unusable",
		"use_effect": "none",
		"stackable": "no",
		"value": 11
	},

	"orange": {
		"name": "Orange",
		"description": "Rich in vitamin C.\nIngredient.",
		"type": "unusable",
		"use_effect": "none",
		"stackable": "yes",
		"value": 8
	},

	"papaya": {
		"name": "Papaya",
		"description": "Soft and sweet.\nIngredient.",
		"type": "unusable",
		"use_effect": "none",
		"stackable": "yes",
		"value": 10
	},

	"peach": {
		"name": "Peach",
		"description": "Fuzzy and sweet.\nIngredient.",
		"type": "unusable",
		"use_effect": "none",
		"stackable": "yes",
		"value": 9
	},

	"peanut": {
		"name": "Peanut",
		"description": "A salty snack.\nIngredient.",
		"type": "unusable",
		"use_effect": "none",
		"stackable": "yes",
		"value": 4
	},

	"pear": {
		"name": "Pear",
		"description": "Soft and grainy.\nIngredient.",
		"type": "unusable",
		"use_effect": "none",
		"stackable": "yes",
		"value": 8
	},

	"pineapple": {
		"name": "Pineapple",
		"description": "Tropical and tangy.\nIngredient.",
		"type": "unusable",
		"use_effect": "none",
		"stackable": "no",
		"value": 12
	},

	"pumpkin": {
		"name": "Pumpkin",
		"description": "Great for cooking.\nIngredient.",
		"type": "unusable",
		"use_effect": "none",
		"stackable": "no",
		"value": 10
	},

	"raspberry": {
		"name": "Raspberry",
		"description": "Tart and tasty.\nIngredient.",
		"type": "unusable",
		"use_effect": "none",
		"stackable": "yes",
		"value": 6
	},

	"starfruit": {
		"name": "Starfruit",
		"description": "Star-shaped treat.\nIngredient.",
		"type": "unusable",
		"use_effect": "none",
		"stackable": "yes",
		"value": 11
	},

	"strawberry": {
		"name": "Strawberry",
		"description": "Sweet and red.\nIngredient.",
		"type": "unusable",
		"use_effect": "none",
		"stackable": "yes",
		"value": 7
	},

	"watermelon": {
		"name": "Watermelon",
		"description": "Very refreshing.\nIngredient.",
		"type": "unusable",
		"use_effect": "none",
		"stackable": "no",
		"value": 14
	},
	
	"sugar": {
		"name": "Sugar",
		"description": "Sweet little crystals\nused in desserts.\nIngredient.",
		"type": "unusable",
		"use_effect": "none",
		"stackable": "yes",
		"value": 5
	},

	"butter": {
		"name": "Butter",
		"description": "A creamy block\nmade from milk.\nIngredient.",
		"type": "unusable",
		"use_effect": "none",
		"stackable": "yes",
		"value": 8
	},

	"egg": {
		"name": "Egg",
		"description": "Used in baking and\nprotein-rich meals.\nIngredient.",
		"type": "unusable",
		"use_effect": "none",
		"stackable": "yes",
		"value": 6
	},

	"ice": {
		"name": "Ice",
		"description": "Cold and refreshing.\nMelts quickly!\nIngredient.",
		"type": "unusable",
		"use_effect": "none",
		"stackable": "yes",
		"value": 3
	},

	"milk": {
		"name": "Milk",
		"description": "Creamy...\nIngredient.",
		"type": "unusable",
		"use_effect": "none",
		"stackable": "yes",
		"value": 6
	},

	"flour": {
		"name": "Flour",
		"description": "Dusty...\nIngredient.",
		"type": "unusable",
		"use_effect": "none",
		"stackable": "no",
		"value": 50
	}
}

func get_item(id: String) -> Dictionary:
	return items.get(id, {})
