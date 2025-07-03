extends Area3D

@export_enum("Mage", "Frog")
var enemy_type: String = "Frog"
var enemy_scene: PackedScene 

@onready var player = %Player
@onready var health_ui = %HealthUI

@export var max_enemies: int = 3
@export var spawn_interval: float = 2.0

@export_enum(
	"almond", "apple", "banana", "blueberry", "carrot", "coconut", "grape",
	"kiwi", "lemon", "lime", "litchi", "mango", "mangosteen", "melon", "orange",
	"papaya", "peach", "peanut", "pear", "pineapple", "pumpkin", "raspberry",
	"starfruit", "strawberry", "watermelon", "sugar", "butter", "egg", "ice",
	"milk", "flour", "fruit_salad", "smoothie", "cake", "cookies", "pumpkin_pie",
	"fruit_pie", "ice_cream", "candied_fruit", "lemon_bar", "muffin", "coconut_ball"
)

var loot_item_id: String = "apple"

enum FrogClass { FROG1, FROG2, FROG3, FROG4 }
enum MageClass { MAGE1, MAGE2 }

@export var frogselectedtype: FrogClass
@export var mageselectedtype: MageClass

@export_range(1, 99) var loot_min_amount: int = 1
@export_range(1, 99) var loot_max_amount: int = 3

@export var patrol_speed: float = 40.0  # Optional overrides

var spawn_timer: Timer

func _ready():

	match enemy_type:
		"Mage":
			enemy_scene = preload("res://Enemies/GenericTest/enemyranged.tscn")
		"Frog":
			enemy_scene = preload("res://Enemies/GenericTest/enemy.tscn")
		_:
			push_error("Unknown enemy type selected!")

	# Create and start spawn timer
	spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_interval
	spawn_timer.one_shot = false
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(spawn_timer)
	spawn_timer.start()
	_on_spawn_timer_timeout()

func _on_spawn_timer_timeout():
	if _get_enemy_count_in_area() >= max_enemies:
		return

	var enemy = enemy_scene.instantiate()
	var offset = Vector3(randf_range(-5, 5), 0, randf_range(-5, 5))
	enemy.position = enemy.position + offset

	# Assign properties
	print ("The loot item is ", loot_item_id)
	
	if enemy.has_meta("patrol_bounds_area"):
		enemy.patrol_bounds_area = self
	if enemy.has_meta("loot_item_id"):
		enemy.loot_item_id = loot_item_id
	if enemy.has_meta("loot_min_amount"):
		enemy.loot_min_amount = loot_min_amount
	if enemy.has_meta("loot_max_amount"):
		enemy.loot_max_amount = loot_max_amount
	if enemy.has_meta("selectedtype"):
		if enemy_type == "Frog":
			enemy.selectedtype = frogselectedtype
		else:
			enemy.selectedtype = mageselectedtype

	add_child(enemy)
	enemy.add_to_group("enemy")

func _get_enemy_count_in_area() -> int:
	var count := 0
	for child in get_children():
		if child.is_in_group("enemy"):
			count += 1
	return count

func get_frogselectedtype() -> FrogClass:
	return frogselectedtype

func get_mageselectedtype() -> MageClass:
	return mageselectedtype

func get_loot_item_id() -> String:
	return loot_item_id

func get_loot_min_amount() -> int:
	return loot_min_amount

func get_loot_max_amount() -> int:
	return loot_max_amount
