extends Control

@onready var shader_material: ShaderMaterial = $ScreenTransition/ColorRect.material

func _ready():
	$StartButton.pressed.connect(_on_start_button_pressed)
	$OptionsButton.pressed.connect(_on_options_button_pressed)
	$CloseButton.pressed.connect(_on_close_button_pressed)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	run_transition_show()

func _on_start_button_pressed() -> void:
	# Disable buttons during transition
	$StartButton.disabled = true
	$OptionsButton.disabled = true
	$CloseButton.disabled = true
	Global.gamedone = false
	Global.inventory_ref.clear_recipes()
	QuestManager.reset_quests()
	
	await run_transition_hide()
	# Change the scene after transition
	get_tree().change_scene_to_file("res://island.tscn")

func _on_options_button_pressed():
	print("Options button pressed")

func _on_close_button_pressed():
	get_tree().quit()

func run_transition_hide() -> void:
	var circle_size = 1.0
	while circle_size > 0.0:
		circle_size -= 0.005
		shader_material.set_shader_parameter("circle_size", circle_size)
		# Wait for the next frame (~60fps)
		await get_tree().process_frame

func run_transition_show() -> void:
	var circle_size = 0.0
	while circle_size < 1.0:
		circle_size += 0.005
		shader_material.set_shader_parameter("circle_size", circle_size)
		# Wait for the next frame (~60fps)
		await get_tree().process_frame
