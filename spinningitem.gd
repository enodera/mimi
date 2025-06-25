# SpinningItem.gd
extends Node3D

@export var rotation_speed := 10000  # Radians per second

func _process(delta):
	rotate_y(delta * rotation_speed)
