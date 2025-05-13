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
			{"text": "Safe travels!", "set_branch": "no_help"}
		],
		"no_help": [
			"Alright, take care!"
		]
	},
	
	"liz": {
		"intro": [
			"Hi, Mimi!",
			{
				"text": "How are you today?",
				"options": [
					{"text": "I'm okay.", "next": "relieved"},
					{"text": "Well...", "next": "panics"}
				]
			}
		],
		"relieved": [
			{"text": "That's good! Let me know if you need anything.", "set_branch": "again"}
		],
		"panics": [
			"Oh no... If you need any help with anything, let me know!"
		],
		"again": [
			"Talking to me again? You're too kind!"
		]
	},
	
	"narrator": {
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
