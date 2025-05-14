extends Camera3D

@export var follow_scan_radius: float = 50.0
@onready var target = %Player

func _ready():
	# Optional: any initialization code
	pass

func _process(delta: float) -> void:
	# Follow the player from above
	position = Vector3(target.position.x, follow_scan_radius, target.position.z)
