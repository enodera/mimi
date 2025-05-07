# npc.gd
extends Node3D

var dialog_npc: String
@export var selected_npc: NPCType = NPCType.JOHN
@export var dialog_text: String = "greeting"
@export var itemgiven: String = "none"

# Define the NPCs
enum NPCType {
	JOHN,
	LUNA,
	NARRATOR
}

enum TextType {
	GREETING,
	MISSION1,
	MISSION2,
	MISSION3
}

var npc_dialogue_keys = {
	NPCType.JOHN: "npc_john",
	NPCType.LUNA: "npc_luna",
	NPCType.NARRATOR: "narrator"
}

#var text_dialogue_keys = {
	#NPCType.GREETING: "npc_john",
	#NPCType.MISSION1: "npc_luna",
	#NPCType.MISSION2: "narrator",
	#NPCType.MISSION2: "narrator"
#}

var player_in_range = false

func _ready():
	$Area3D.body_entered.connect(_on_body_entered)
	$Area3D.body_exited.connect(_on_body_exited)
	dialog_npc = npc_dialogue_keys[selected_npc]
	%DialogueUI.npc_set_branch.connect(_on_npc_set_branch)

func _process(_delta):
	if player_in_range and Input.is_action_just_pressed("interact") and not Global.paused and not Global.dialoguepaused:
		show_dialog()

func _on_body_entered(body):
	if body.is_in_group("player"):  # Or use group checking
		player_in_range = true
		$Label3D.visible = true  # Optional

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
		$Label3D.visible = false  # Optional

func _on_npc_set_branch(character_id: String, new_branch: String):
	if dialog_npc == character_id:
		dialog_text = new_branch

func show_dialog():
	print(dialog_text)
	
	Global.dialoguepaused = true
	
	%DialogueUI.start_from_global(dialog_npc, dialog_text)
	
	await %DialogueUI.dialogue_finished
	
	#%DialogueUI.start_dialogue([
		#"Hello, witch!",
		#"What's up? Not much, I assume...",
		#"it works heeheehee"
	#], "Yes")
	#
	#await %DialogueUI.dialogue_finished
