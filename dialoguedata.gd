# dialoguedata.gd (dictionary singleton)

extends Node

var dialogue = {
	
	"npc_john": {
		"greeting": [
			"Hey there, traveler.",
			{
				"text": "Do you need directions?",
				"options": [
					{"text": "Yes, please.", "next": "help_directions"},
					{"text": "No thanks.", "next": "no_help"}
				]
			}
		],
		"help_directions": [
			"The village is just down the road to the east.",
			"Safe travels!"
		],
		"no_help": [
			"Alright, take care!"
		]
	},
	
	"npc_luna": {
		"intro": [
			"Shh! Keep your voice down.",
			{
				"text": "Are you followed?",
				"options": [
					{"text": "I don't think so.", "next": "relieved"},
					{"text": "Yes.", "next": "panics"}
				]
			}
		],
		"relieved": [
			"Good. We don't want any trouble."
		],
		"panics": [
			"Oh no. We need to hide, now!"
		]
	}
	
}
