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
					{"text": "Well...", "next": "panics"},
					{"text": "Lemons for Liz (Quest)", "next": "lemons_for_liz"}
				]
			}
		],
		"relieved": [
			{"text": "That's good! Let me know if you need anything.", "set_branch": "again"}
		],
		"panics": [
			"Oh no...\nIf you need any help with anything, let me know!"
		],
		"lemons_for_liz": [
			{"text": "", "check_quest": "lemons_for_liz"}
		],
		"lemons_for_liz_start": [
			"Oh, I need to ask a favour! Could you give me 3 lemons?",
			"Truth is, I need them for my lesson...",
			"Thank you so much!"
		],
		"lemons_for_liz_done": [
			"Thank you for the lemons! You're a lifesaver."
		],
		"lemons_for_liz_fail": [
			"Hmm... looks like you don't have any lemons yet."
		],
		"again": [
			"Talking to me again? You're too kind!"
		],
		"already_done_quest" : [
			"Um... You already did this quest... Sorry..."
		],
		"error" : [
			"Error!"
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
