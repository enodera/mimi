extends CanvasLayer

@onready var health_bar: ProgressBar = $HealthBar  # or correct path

var max_health: int = 100
var current_health: int = 100

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
	print("Player has died.")
