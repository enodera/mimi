extends Control

@onready var back_button: Button = $BackButton
@onready var shader_material: ShaderMaterial = $ScreenTransition/ColorRect.material

var current_page_index := 0
const MAX_PAGE := 3

func _ready():
	run_transition_show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	back_button.pressed.connect(_on_back_pressed)


func _on_back_pressed():
	back_button.disabled = true
	
	await run_transition_hide()
	# Change the scene after transition
	get_tree().change_scene_to_file("res://Scenes/TitleScreen.tscn")

func run_transition_hide() -> void:
	var duration = 1.0  # seconds
	var elapsed = 0.0
	while elapsed < duration:
		elapsed += get_process_delta_time()
		var circle_size = lerp(1.0, 0.0, elapsed / duration)
		shader_material.set_shader_parameter("circle_size", circle_size)
		await get_tree().process_frame
	# Ensure it ends exactly at 0
	shader_material.set_shader_parameter("circle_size", 0.0)

func run_transition_show() -> void:
	var duration = 1.0  # seconds
	var elapsed = 0.0
	while elapsed < duration:
		elapsed += get_process_delta_time()
		var circle_size = lerp(0.0, 1.0, elapsed / duration)
		shader_material.set_shader_parameter("circle_size", circle_size)
		await get_tree().process_frame
	# Ensure it ends exactly at 1
	shader_material.set_shader_parameter("circle_size", 1.0)
