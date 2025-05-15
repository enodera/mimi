extends CanvasLayer

# --- UI Node References ---
@onready var speaker_label = $Panel/Panel/SpeakerLabel
@onready var dialogue_text = $Panel/DialogueText
@onready var options_container = $Panel/VBoxContainer

# --- Dialogue State ---
var lines = []
var current_index = 0
var is_active = false
var is_choosing := false
var option_selected_index := 0
var typing := false

# --- Typing Speed Settings ---
var textspeed := 0.03      # seconds between each character
var commaspeed := 0.125
var dotspeed := 0.30

# --- Speaker Positioning ---
var talkingpos := 0.0
var narratepos := 0.0
var projscale = ProjectSettings.get_setting("display/window/stretch/scale")

# --- Signals ---
signal dialogue_finished
signal npc_set_branch(character_id: String, new_branch: String)

# --- Initialization ---
func _ready() -> void:
	talkingpos = speaker_label.global_position.y
	narratepos = speaker_label.global_position.y + 20
	


# --- Starting Dialogue ---
func start_from_global(character_id: String, branch: String):
	$Panel.scale = Vector2(1/projscale, 1/projscale)  # Reset before anything else

	if DialogueData.dialogue.has(character_id) and DialogueData.dialogue[character_id].has(branch):
		var dialogue_lines = DialogueData.dialogue[character_id][branch]
		start_dialogue(dialogue_lines, character_id.capitalize())
		
		$Panel.scale = Vector2(0, 0)
		var tween := create_tween()
		tween.tween_property($Panel, "scale", Vector2(1/projscale, 1/projscale), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)



func start_dialogue(dialogue_lines: Array, speaker_name: String = ""):
	lines = dialogue_lines
	current_index = 0
	is_active = true
	visible = true
	Global.dialoguepaused = true


	if speaker_name != "":
		speaker_label.text = speaker_name
		speaker_label.visible = true
		speaker_label.global_position.y = talkingpos
	else:
		speaker_label.visible = false
		$Panel/Panel.visible = false
		speaker_label.global_position.y = narratepos
	
	%MinimapUI.visible = false
	%HealthUI.visible = false
	%QuestUI.visible = false
	show_current_line()


# --- Input Handling ---
func _unhandled_input(event):
	if not is_active:
		return

	if is_choosing:
		handle_option_input(event)
	else:
		if event.is_action_pressed("interact"):
			next_line()


func handle_option_input(event):
	if event.is_action_pressed("move_down"):  # Only allow 'S' or your custom key
		option_selected_index = (option_selected_index + 1) % options_container.get_child_count()
		highlight_option(option_selected_index)

	elif event.is_action_pressed("move_up"):  # Only allow 'W' or your custom key
		option_selected_index = (option_selected_index - 1 + options_container.get_child_count()) % options_container.get_child_count()
		highlight_option(option_selected_index)

	elif event.is_action_pressed("interact"):
		is_choosing = false
		var selected_button = options_container.get_child(option_selected_index)
		var selected_option = {
			"text": selected_button.text
		}
		if selected_button.has_meta("option_data"):
			selected_option = selected_button.get_meta("option_data")
		_on_option_selected(selected_option)



# --- Dialogue Flow ---

func show_current_line():
	options_container.visible = false
	for child in options_container.get_children():
		child.queue_free()

	if current_index < lines.size():
		var line = lines[current_index]

		if typeof(line) == TYPE_STRING:
			dialogue_text.text = ""
			typing = true
			type_line(line)

		elif typeof(line) == TYPE_DICTIONARY and line.has("text"):
			dialogue_text.text = ""
			typing = true
			type_line(line["text"])

			# Process custom actions
			if line.has("action"):
				process_action(line)

			if line.has("set_branch"):
				set_npc_branch(line["set_branch"])

			if line.has("set_quest"):
				QuestManager.start_quest(line["set_quest"])

			if line.has("complete_quest"):
				QuestManager.complete_quest(line["complete_quest"])

			if line.has("options"):
				await wait_for_typing()
				show_options(line["options"])

	else:
		end_dialogue()


func wait_for_typing():
	while typing:
		await get_tree().process_frame


func next_line():
	if typing:
		typing = false
		return
	current_index += 1
	show_current_line()


func end_dialogue():
	is_active = false
	var tween := create_tween()
	tween.tween_property($Panel, "scale", Vector2(0, 0), 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(0.3).timeout
	
	visible = false
	Global.dialoguepaused = false
	
	%MinimapUI.visible = true
	%HealthUI.visible = true
	%QuestUI.visible = true
	
	await get_tree().create_timer(0.000000000001).timeout
	emit_signal("dialogue_finished")
	print("Dialogue finished!")


# --- Typing Effect ---
func type_line(line: String) -> void:
	dialogue_text.text = ""
	for i in line.length():
		dialogue_text.text += line[i]
		if i % 2 == 0:
			$VoiceSound.play()
		match line[i]:
			",":
				await get_tree().create_timer(commaspeed).timeout
			".", "?", "!":
				await get_tree().create_timer(dotspeed).timeout
			_:
				await get_tree().create_timer(textspeed).timeout

		if not typing:
			dialogue_text.text = line
			break

	typing = false

func process_action(line: Dictionary):
	match line["action"]:
		"give_item":
			if line.has("item"):
				%InventoryUI.inevntory.add_item(line["item"])  # Assuming you have something like this
		"start_quest":
			if line.has("quest_id"):
				QuestManager.start_quest(line["quest_id"])
		# Add more actions as needed


func set_npc_branch(new_branch: String):
	var character = speaker_label.text.strip_edges().to_lower().replace(" ", "_")
	emit_signal("npc_set_branch", character, new_branch)


# --- Option Handling ---
func show_options(options: Array):
	is_choosing = true
	option_selected_index = 0
	options_container.visible = true

	for option in options:
		var button = Button.new()
		button.text = option["text"]
		button.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.focus_mode = Control.FOCUS_NONE
		button.set_meta("option_data", option)
		options_container.add_child(button)

	highlight_option(option_selected_index)


func highlight_option(index: int):
	for i in options_container.get_child_count():
		var btn = options_container.get_child(i)
		btn.modulate = Color(1, 1, 1)  # Reset color

	var selected = options_container.get_child(index)
	selected.modulate = Color(1, 1, 0.5)  # Highlighted (yellowish)


func _on_option_selected(option: Dictionary):
	options_container.visible = false
	for child in options_container.get_children():
		child.queue_free()

	if option.has("next"):
		var next_branch = option["next"]
		var character = speaker_label.text.strip_edges().to_lower().replace(" ", "_")

		print("Character:", character)
		print("Next branch:", next_branch)

		if DialogueData.dialogue.has(character) and DialogueData.dialogue[character].has(next_branch):
			start_dialogue(DialogueData.dialogue[character][next_branch], character.capitalize())
		else:
			print("Missing dialogue branch: ", next_branch)
			end_dialogue()
	else:
		current_index += 1
		show_current_line()
