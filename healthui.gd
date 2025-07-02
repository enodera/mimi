extends CanvasLayer

@onready var health_bar: ProgressBar = $HealthBar
@onready var player: CharacterBody3D = %Player
var max_health: int = 100
var current_health: int = 100
var player_dead: bool = false

func _ready() -> void:
	update_health_bar()

func set_health(max_val: int, current_val: int) -> void:
	max_health = max_val
	current_health = clamp(current_val, 0, max_health)
	update_health_bar()

func take_damage(amount: int) -> void:
	current_health = max(current_health - amount, 0)
	update_health_bar()
	if current_health <= 0:
		die()

func heal_damage(amount: int) -> void:
	current_health = clamp(current_health + amount, 0, max_health)
	update_health_bar()

func update_health_bar() -> void:
	if health_bar:
		health_bar.value = float(current_health) / float(max_health) * 100.0

func die() -> void:
	if player and not player_dead:
		if player.was_on_floor or player.is_on_water:
			player_dead = true
			player.get_node("DeathParticles2").emitting = true
			player.get_node("DeathParticles3").emitting = true
			player.get_node("Mimi").visible = false
			player._can_move = false
			await player.run_transition_hide()
			get_tree().change_scene_to_file("res://Scenes/TitleScreen.tscn")
		print("Player has died.")
