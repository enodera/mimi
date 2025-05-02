# mimi.gd (This is the animation State Machine. (for walking mostly!))

class_name MimiSkin extends Node3D

@onready var _animation_tree: AnimationTree = $AnimationTree  # Reference to the AnimationTree
@onready var _state_machine: AnimationNodeStateMachinePlayback = _animation_tree.get("parameters/playback")  # Correct way to get state machine playback

# Method to update the blendspace value based on movement speed
func set_run_speed(speed: float, limit: float) -> void:
	if _animation_tree:
		_animation_tree.set("parameters/walkrun/blend_position", speed / limit)

# Method to update the animation state based on the character's movement speed
func set_move_state(state_name: String) -> void:
	if _state_machine:
		# print("Transitioning to state: ", state_name)  # Debugging log
		_state_machine.travel(state_name)  # Change animation state
	else:
		print("Error: State machine playback is null")
