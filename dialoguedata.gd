extends Node

var dialogue = {
	
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
			"That's good! Let me know if you need anything."
			# {"text": "That's good! Let me know if you need anything.", "set_branch": "again"}
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
		"quest_already" : [
			"You're already doing a quest! Finish it up and then get back to me, okay?"
		],
		"error" : [
			"Error!"
		]
	},

	"elric": {
		"intro": [
			"Ah, greetings! I'm just taking in the fresh air over here.",
			{
				"text": "What brings you out here?",
				"options": [
					{"text": "Just enjoying nature.", "next": "friendly"},
					{"text": "Bored...", "next": "quest_offer"}
				]
			}
		],
		"friendly": [
			"A likeminded individual, I see! Well, I hope you enjoy yourself as much as I am."
		],
		"quest_offer": [
			{"text": "", "check_quest": "elric_gathering"}
		],
		"elric_gathering_start": [
			"I see you're free...",
			"How about you try collecting some mangos then?",
			"In this place, mangos grow on the ground... They're over here, near the trees! But you won't know which are mangos until you pluck them...",
			"Try collecting 3 of them!"
		],
		"elric_gathering_done": [
			"Ah, perfect! These will help so many people. You're a true friend."
		],
		"elric_gathering_fail": [
			"Still missing the berries. They’re out there—don’t give up!"
		],
		"again": [
			"Back again? I’m always happy to share forest stories!"
		],
		"already_done_quest": [
			"You've already helped me with that—thank you again!"
		],
		"quest_already": [
			"Looks like you're already on a quest. Finish that first, and then let's chat!"
		],
		"error": [
			"Hmm... something's not right. Try again later, will you?"
		]
	},

	"lyra": {
		"intro": [
			"Oh, hello there. It's a pleasure to meet you.",
			{
				"text": "How can I help you today?",
				"options": [
					{"text": "Recipies nearby?", "next": "recipe_hint"},
					{"text": "Just saying hello.", "next": "greeting"}
				]
			}
		],
		"recipe_hint": [
			"Hmm... A recipe, you say?",
			"I believe I caught a glimpse of something like that on the far side of this icy island.",
			"There are a few small ice islets scattered around it — perhaps try searching there.",
			{"text": "Best of luck. I hope you find what you're looking for.", "set_branch": "again"}
		],
		"greeting": [
			"How lovely. It's always nice to exchange a kind word.",
			{"text": "Stay warm out here, won't you?", "set_branch": "again"}
		],
		"again": [
			"Back again? You're always welcome.",
			{
				"text": "How can I help you today?",
				"options": [
					{"text": "Recipies nearby?", "next": "recipe_hint"},
					{"text": "Just saying hello.", "next": "greeting"}
				]
			}
		],
		"error": [
			"Oh dear, something seems to have gone wrong. Please try again later."
		]
	},

	"jack": {
		"intro": [
			"Hey there, kiddo. Quite the view from up here, huh?",
			{
				"text": "Need something?",
				"options": [
					{"text": "Any recipes nearby?", "next": "recipe_hint"},
					{"text": "Just enjoying the view.", "next": "greeting"}
				]
			}
		],
		"recipe_hint": [
			"Ah, recipes, huh?",
			"Y'know, while I was looking out from the ridge up the mountain, I thought I saw something tucked away near the cliff edge.",
			"Could've been a scrap of paper or maybe the wind playing tricks — either way, worth checking out.",
			{"text": "Good luck, kiddo. Watch your step up there.", "set_branch": "again"}
		],
		"greeting": [
			"Heh, nothing wrong with that. Some days it's enough to just take it all in.",
			{"text": "Stay sharp out here, kiddo.", "set_branch": "again"}
		],
		"again": [
			"Back again, kiddo? Not tired of the cold yet?",
			{
				"text": "Need something?",
				"options": [
					{"text": "Any recipes nearby?", "next": "recipe_hint"},
					{"text": "Just enjoying the view.", "next": "greeting"}
				]
			}
		],
		"error": [
			"Hm. Something went wrong there, kiddo. Try again in a bit."
		]
	},

	"npc_4": {
		"intro": [
			"greetings!",
			{
				"text": "what's on your mind?",
				"options": [
					{"text": "just passing by.", "next": "casual"},
					{"text": "interested in a quest?", "next": "quest_offer"}
				]
			}
		],
		"casual": [
			{"text": "have a good day!", "set_branch": "again"}
		],
		"quest_offer": [
			{"text": "", "check_quest": "npc4_quest"}
		],
		"npc4_quest_start": [
			"i need some firewood, could you bring 6 pieces?",
			"it's for the village bonfire.",
			"thanks a lot!"
		],
		"npc4_quest_done": [
			"perfect! the bonfire will be great."
		],
		"npc4_quest_fail": [
			"no firewood yet? keep an eye out."
		],
		"again": [
			"talk to me anytime!"
		],
		"already_done_quest": [
			"you already helped with this one."
		],
		"error": [
			"an error happened. sorry!"
		]
	},

	"npc_5": {
		"intro": [
			"hey there!",
			{
				"text": "how can i assist?",
				"options": [
					{"text": "looking for info.", "next": "info"},
					{"text": "want a quest.", "next": "quest_offer"}
				]
			}
		],
		"info": [
			"i might know something useful for you."
		],
		"quest_offer": [
			{"text": "", "check_quest": "npc5_quest"}
		],
		"npc5_quest_start": [
			"could you find 3 feathers for me?",
			"i need them for a craft project.",
			"thank you!"
		],
		"npc5_quest_done": [
			"great, these feathers will do!"
		],
		"npc5_quest_fail": [
			"still no feathers? keep trying!"
		],
		"again": [
			"here to chat again?"
		],
		"already_done_quest": [
			"quest already completed."
		],
		"error": [
			"error encountered."
		]
	},

	"npc_6": {
		"intro": [
			"hello!",
			{
				"text": "what brings you here?",
				"options": [
					{"text": "just checking in.", "next": "casual"},
					{"text": "do you have tasks?", "next": "quest_offer"}
				]
			}
		],
		"casual": [
			{"text": "good to see you!", "set_branch": "again"}
		],
		"quest_offer": [
			{"text": "", "check_quest": "npc6_quest"}
		],
		"npc6_quest_start": [
			"can you bring me 7 stones?",
			"i need them for construction.",
			"thanks for helping out!"
		],
		"npc6_quest_done": [
			"thanks for the stones!"
		],
		"npc6_quest_fail": [
			"not enough stones yet, keep looking."
		],
		"again": [
			"talk anytime!"
		],
		"already_done_quest": [
			"you already completed this task."
		],
		"error": [
			"something's wrong, please retry."
		]
	},

	"npc_7": {
		"intro": [
			"hi!",
			{
				"text": "can i help you?",
				"options": [
					{"text": "looking for quests.", "next": "quest_offer"},
					{"text": "just chatting.", "next": "friendly"}
				]
			}
		],
		"friendly": [
			{"text": "nice chatting with you!", "set_branch": "again"}
		],
		"quest_offer": [
			{"text": "", "check_quest": "npc7_quest"}
		],
		"npc7_quest_start": [
			"i need 4 bundles of cloth.",
			"can you get them for me?",
			"thanks a lot!"
		],
		"npc7_quest_done": [
			"perfect, just what i needed!"
		],
		"npc7_quest_fail": [
			"haven't got the cloth yet? keep trying!"
		],
		"again": [
			"welcome back!"
		],
		"already_done_quest": [
			"you've already finished this quest."
		],
		"error": [
			"error occurred, please try again."
		]
	},

	"npc_8": {
		"intro": [
			"hello!",
			{
				"text": "need any help?",
				"options": [
					{"text": "yes, please.", "next": "help"},
					{"text": "not right now.", "next": "casual"}
				]
			}
		],
		"help": [
			"what do you need?"
		],
		"casual": [
			"okay, let me know if you need anything!"
		],
		"quest_offer": [
			{"text": "", "check_quest": "npc8_quest"}
		],
		"npc8_quest_start": [
			"could you find 5 bottles of water?",
			"they're important for the trip.",
			"thank you!"
		],
		"npc8_quest_done": [
			"great, thanks for the water!"
		],
		"npc8_quest_fail": [
			"still waiting on those bottles."
		],
		"again": [
			"good to see you again!"
		],
		"already_done_quest": [
			"this quest is already done."
		],
		"error": [
			"something went wrong."
		]
	},

	"npc_9": {
		"intro": [
			"hey!",
			{
				"text": "looking for anything?",
				"options": [
					{"text": "just browsing.", "next": "casual"},
					{"text": "any quests?", "next": "quest_offer"}
				]
			}
		],
		"casual": [
			"feel free to look around."
		],
		"quest_offer": [
			{"text": "", "check_quest": "npc9_quest"}
		],
		"npc9_quest_start": [
			"i need 3 pieces of fabric.",
			"can you help me get them?",
			"thanks!"
		],
		"npc9_quest_done": [
			"thanks for the fabric!"
		],
		"npc9_quest_fail": [
			"no fabric yet? keep searching."
		],
		"again": [
			"nice to see you again!"
		],
		"already_done_quest": [
			"you already finished this one."
		],
		"error": [
			"error happened, try later."
		]
	},

	"npc_10": {
		"intro": [
			"hi there!",
			{
				"text": "need any assistance?",
				"options": [
					{"text": "yes, what can you offer?", "next": "quest_offer"},
					{"text": "just stopping by.", "next": "casual"}
				]
			}
		],
		"casual": [
			"thanks for visiting!"
		],
		"quest_offer": [
			{"text": "", "check_quest": "npc10_quest"}
		],
		"npc10_quest_start": [
			"can you find me 2 bundles of rope?",
			"i need them for fixing the bridge.",
			"thank you!"
		],
		"npc10_quest_done": [
			"perfect, this will help a lot."
		],
		"npc10_quest_fail": [
			"still waiting on the rope."
		],
		"again": [
			"good to see you again!"
		],
		"already_done_quest": [
			"you already did this quest."
		],
		"error": [
			"something went wrong."
		]
	}

}
