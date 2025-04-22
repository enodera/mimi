# npc.gd
extends Node3D

@export var dialog_text: String = "Sup, bitch!"

var player_in_range = false

func _ready():
	$Area3D.body_entered.connect(_on_body_entered)
	$Area3D.body_exited.connect(_on_body_exited)

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

func show_dialog():
	print(dialog_text)
	
	Global.dialoguepaused = true
	
	%DialogueUI.start_dialogue([
		"Hello, witch!",
		"What's up? Not much, I assume...",
		"it works heeheehee"
	], "Yes")
	
	await %DialogueUI.dialogue_finished
	
	%DialogueUI.start_from_global("npc_john", "greeting")
	
	await %DialogueUI.dialogue_finished
	
