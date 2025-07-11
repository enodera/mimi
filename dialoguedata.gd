extends Node

var dialogue = {

	"liz": {
		"intro": [
			"Hello, Mimi. Have you been practicing your cooking spells?",
			{
				"text": "Remember, the Sweets Archipelago is where sugar magic is strongest.",
				"options": [
					{"text": "Yup. Ready for a task!", "next": "greeting"}
				]
			}
		],
		"greeting": [
			"Good to see you again, Mimi. Keep striving to be the best cook you can be!",
			"I'm going to ask you with delivering some food to me, okay?\nAll you have to do is cook on your cooking menu! (Press R)",
			"If you dont know how to make it, search for the recipies! They should be scattered around the archipelago.",
			{"text": "You can talk to me to choose a mission when you're ready.", "set_branch": "mission_select"}
		],
		"mission_select": [
			{
				"text": "Greetings! Choose a sweet dish to deliver:",
				"options": [
					{"text": "3 Strawberry Cakes", "next": "quest_offer1"},
					{"text": "3 Nut Cookies", "next": "quest_offer2"},
					{"text": "3 Pumpkin Pies", "next": "quest_offer3"},
					{"text": "3 Ice Creams", "next": "quest_offer4"},
					{"text": "3 Mango Lassis", "next": "quest_offer5"},
					{"text": "3 Berry Muffins", "next": "quest_offer6"},
					{"text": "3 Carrot Cakes", "next": "quest_offer7"}
				]
			}
		],
		
		"quest_offer1": [
			{"text": "", "check_quest": "delivery_cake"}
		],
		"quest_offer2": [
			{"text": "", "check_quest": "delivery_cookies"}
		],
		"quest_offer3": [
			{"text": "", "check_quest": "delivery_pumpkin_pie"}
		],
		"quest_offer4": [
			{"text": "", "check_quest": "delivery_ice_cream"}
		],
		"quest_offer5": [
			{"text": "", "check_quest": "delivery_mango_lassi"}
		],
		"quest_offer6": [
			{"text": "", "check_quest": "delivery_muffin"}
		],
		"quest_offer7": [
			{"text": "", "check_quest": "delivery_carrot_cake"}
		],
		
		"delivery_cake_start": [
			"You must deliver 3 Strawberry Cakes to complete this task.",
			"The softness and fluffiness of the cake is to die for.",
			"Please, return once the delivery is done."
		],

		"delivery_cookies_start": [
			"Would you mind giving me 3 Nut cookies?",
			"I've heard enjoy their crunchiness a lot, and I'd love to try it for myself...",
			"Do come back once you're done."
		],

		"delivery_pumpkin_pie_start": [
			"Please, make 3 Pumpkin Pies for me.",
			"Pumpkins are so fascinating... Don't you agree? Heehee...",
			"Let me know when you're done."
		],

		"delivery_ice_cream_start": [
			"It's getting a bit warm, could you bring me 3 Ice Creams?",
			"They're so chilly and refreshing...",
			"Come back once completed."
		],

		"delivery_mango_lassi_start": [
			"I wish I could have 3 Mango Lassis.",
			"Have you heard of those before? They seem to be a real delicacy of a smoothie.",
			"How about you make some? It'd be a learning experience."
		],

		"delivery_muffin_start": [
			"I'd like to have 3 Berry Muffins, if it's not too much trouble.",
			"The soft muffins filled with berries are very popular.",
			"Come back when you've delivered them."
		],

		"delivery_carrot_cake_start": [
			"I'd like to have 3 Carrot Cakes, please.",
			"They're my favourite!",
			"Return once the delivery is done."
		],


		"delivery_cake_done": [
			"Strawberry Cakes delivered perfectly! Great job as always, Mimi."
		],
		"delivery_cake_fail": [
			"You haven't baked all Strawberry Cakes yet.",
			"Keep at it, you'll get there soon!"
		],

		"delivery_cookies_done": [
			"Nut Cookies delivered! Outstanding."
		],
		"delivery_cookies_fail": [
			"You don't have enough Nut Cookies prepared.",
			"Practice makes perfect!"
		],

		"delivery_pumpkin_pie_done": [
			"Pumpkin Pies delivered! I'm delighted."
		],
		"delivery_pumpkin_pie_fail": [
			"The Pumpkin Pies aren’t ready yet.",
			"Keep working on your baking!"
		],

		"delivery_ice_cream_done": [
			"Ice Creams delivered! A perfect cool treat. Thank you!"
		],
		"delivery_ice_cream_fail": [
			"You don’t have enough Ice Cream prepared.",
			"Try again after practicing!"
		],

		"delivery_mango_lassi_done": [
			"Mango Lassis! Just as I asked. Thank you!"
		],
		"delivery_mango_lassi_fail": [
			"Not all Mango Lassis ready yet.",
			"Keep at it to get better!"
		],

		"delivery_muffin_done": [
			"Berry Muffins delivered! These are a hit, I've heard."
		],
		"delivery_muffin_fail": [
			"You need more Berry Muffins before you can deliver.",
			"Keep baking!"
		],

		"delivery_carrot_cake_done": [
			"Carrot Cakes delivered! Isn't it amazing how versatile carrots can be?"
		],
		"delivery_carrot_cake_fail": [
			"All Carrot Cakes aren’t ready yet.",
			"Keep practicing and try again!"
		],
		"quest_already": [
			"You're already on a quest, Mimi... Always finish your current duties before starting new ones!"
		],
		"already_done_quest": [
			"You already did this mission, Mimi... Don't overwork yourself, okay?"
		],
		"error": [
			"Something's not right, try again later."
		]
	},


	"laura": {
		"intro": [
			"Have you seen the pink trees around here? They glow softly at dusk.",
			{
				"text": "It's a magical place filled with sweet aromas.",
				"options": [
					{"text": "Tell me more.", "next": "pink_trees_info"},
					{"text": "Thanks, just passing by.", "next": "casual"}
				]
			}
		],
		"pink_trees_info": [
			"The pink trees' sap is sweet and can be used for powerful cooking spells.",
			"Watch out for the pink frog slimes—they love the sap too!",
			{"text": "Stay safe!", "set_branch": "again"}
		],
		"casual": [
			"Enjoy the pink hues while they last!"
		],
		"again": [
			"Come back anytime to enjoy the pink woods."
		]
	},

	"avery": {
		"intro": [
			"The mountain's chocolate ground is unlike anything else in the archipelago.",
			{
				"text": "It's said the earth itself is sweet and magical.",
				"options": [
					{"text": "What about the mages here?", "next": "mages_info"},
					{"text": "Thanks for the info.", "next": "casual"}
				]
			}
		],
		"mages_info": [
			"The mages here use chocolate magic to enhance cooking and healing spells.",
			"They are very secretive but will open up if you bring them special treats.",
			{"text": "Try to befriend them!", "set_branch": "again"}
		],
		"casual": [
			"Enjoy the rich smells of chocolate as you explore."
		],
		"again": [
			"The mountain holds many secrets; keep exploring."
		]
	},

	"npc_pink_frog_slimes": {
		"intro": [
			"Have you encountered the pink frog slimes around here?",
			{
				"text": "They're cute but tricky little creatures.",
				"options": [
					{"text": "What do they eat?", "next": "frog_slimes_food"},
					{"text": "Just curious.", "next": "casual"}
				]
			}
		],
		"frog_slimes_food": [
			"Pink frog slimes love sweet nectar from the pink trees and always drop sugar.",
			{"text": "Good luck!", "set_branch": "again"}
		],
		"casual": [
			"They add charm to the pink area, don't they?"
		],
		"again": [
			"Come back and tell me if you meet any."
		]
	},

	"npc_mages": {
		"intro": [
			"Mages around these islands specialize in sweet magic.",
			{
				"text": "They study sugar and sweets to amplify their powers.",
				"options": [
					{"text": "Where can I find them?", "next": "mages_location"},
					{"text": "Thanks for the info.", "next": "casual"}
				]
			}
		],
		"mages_location": [
			"You can find them near the Cream Island and the mountain village.",
			"They often gather to share recipes and spells.",
			{"text": "Try bringing them cooked sweets to gain their favor.", "set_branch": "again"}
		],
		"casual": [
			"Sweet magic is powerful when wielded well."
		],
		"again": [
			"May the sugar guide your path!"
		]
	},

	"flavia": {
		"intro": [
			"Looking for ingredients? Each island has its specialty.",
			"It's all about the flora and fauna...",
			{
				"text": "Want to hear about them?\nI'll warn you, my explanations can be a bit long...",
				"options": [
					{"text": "Yes, please.", "next": "ingredients_info"},
					{"text": "Maybe later.", "next": "casual"}
				]
			}
		],
		"ingredients_info": [
			"Really?! Thank you! Alright then, ahem...",
			"First there's the Rose Island. It's that big pink island over there, impossible to miss.",
			"There, you can find bushes with strawberries and pink slimes to defeat, which will give you sugar.",
			"Next is Cream Island, that icy looking one with the big mountain.",
			"The mages there will drop milk, and the blue frogs will give you ice!",
			"Besides that though, there's no ingredients to collect.",
			"After that, there's Choco Island, the brown island.",
			"You can find pumpkins and nuts scattered everywhere... And there, mages give you flour upon defeating them.",
			"And finally, there's Jelly Island: the one we're on now!",
			"There's A LOT of trees here! Mangos, carrots, pineapples... It's amazing!",
			"...Ahem. Sorry for the long explanation... I just get so passionate!",
			{"text": "If you need anything else, let me know!", "set_branch": "again"}
		],
		"casual": [
			"Got it! Come back if you want any tips."
		],
		"again": [
			"Good luck with your ingredient gathering!",
			{
				"text": "Did you want to hear my explanation again?",
				"options": [
					{"text": "Yes, please.", "next": "ingredients_info"},
					{"text": "Maybe later.", "next": "casual"}
				]
			}
		]
	},


	"elric": {
		"intro": [
			"Ah, greetings! I'm just taking in the fresh air over here.",
			{
				"text": "What brings you out here?",
				"options": [
					{"text": "Just enjoying nature.", "next": "friendly"},
					{"text": "Nothing to do...", "next": "quest_offer"}
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
			"In this place, mangos grow on the ground... They're over here, near the trees!",
			"But you won't know which are mangos until you pluck them...",
			"Try collecting 3 of them! I'll give you some sugar in exchange."
		],
		"elric_gathering_done": [
			"Ah, perfect! You're a true friend.",
			{
				"text": "Here's the sugar, as promised. Enjoy!",
				"action": "give_item",
				"item": "sugar",
				"itemnumber": 10
			}
		],
		"elric_gathering_fail": [
			"Still missing the mangos. They're out there—don't give up!"
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
