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

func set_broom_position(combo_step: int) -> void:
	if %BoneAttachment == null:
		push_error("BoneAttachment node is missing!")
		return

	match combo_step:
		1:
			%BoneAttachment.bone_name = "hand.l"
			%broom.position = Vector3(0,0,0)
			%broom.rotation = Vector3(0, 0, -50)
			
		2:
			%BoneAttachment.bone_name = "hand.r"
			%broom.position = Vector3(0,0,0)
			%broom.rotation = Vector3(0, 0, 50)
		3:
			%BoneAttachment.bone_name = "uparm.l"
			%broom.position = Vector3(0,1,0)
			%broom.rotation = Vector3(0, 0, 0)
		_:
			push_warning("Invalid combo_step: %s" % combo_step)

func set_broom_visibilty(state: bool) -> void:
	%broom.visible = state
		
func set_broom_particles(state: bool) -> void:
	%AttackParticles.emitting = state
	%Hitbox.disabled = not state

func spin_around(duration: float) -> void:
	if duration <= 0:
		push_warning("Duration must be positive.")
		return

	var original_rotation = rotation_degrees.y
	var target_rotation = original_rotation - 360.0

	# Kill any existing tweens if needed (not necessary unless you're stacking)
	var tween = create_tween()
	tween.tween_property(self, "rotation_degrees:y", target_rotation, duration)\
		.set_trans(Tween.TRANS_LINEAR)\
		.set_ease(Tween.EASE_IN_OUT)

	# Optional: Reset back to original rotation cleanly (in case rotation overflows)
	tween.tween_callback(func(): rotation_degrees.y = original_rotation)
