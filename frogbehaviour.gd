# frogbehaviour.gd

extends CharacterBody3D

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D

enum State { PATROL, ATTACK, MELEE, DAMAGE }
enum FrogClass { FROG1, FROG2, FROG3, FROG4 }

enum MeleePhase { BUFFER, ATTACKING, RECOVERY }
var melee_phase: MeleePhase = MeleePhase.BUFFER
var melee_timer: float = 0.5

var player
var health_ui
var selectedtype: FrogClass

var patrol_walk_time: float = 0.0
@export var max_patrol_walk_duration: float = 5.0

@onready var class_models = {
	FrogClass.FROG1: $enemy/frog1,
	FrogClass.FROG2: $enemy/frog2,
	FrogClass.FROG3: $enemy/frog3,
	FrogClass.FROG4: $enemy/frog4
}

@onready var class_controller = {
	FrogClass.FROG1: $enemy/frog1/AnimationTree,
	FrogClass.FROG2: $enemy/frog2/AnimationTree,
	FrogClass.FROG3: $enemy/frog3/AnimationTree,
	FrogClass.FROG4: $enemy/frog4/AnimationTree
}

@export_group("Physics")
@export var knockback_strength: float = 25.0
@export var gravity: float = 125.0

@export_group("Stats")
@export var health: float = 5.0
@export var damagedealt: int = 5

@export_group("Movement")
@export var patrol_speed: float = 20.0
@export var chase_speed: float = 6.0
@export var patrol_wait_time: float = 1.5
@export var patrol_bounds_area: Area3D
@export var melee_range: float = 3.0
@export var vision_range: float = 10.0

@export var hitstun_rotation_speed: float = 20.0

@export var max_wait: float = 1.0
@export var min_wait: float = 2.0

@export var idle_chance: float = 0.3
@export var knockback_duration: float = 0.25

var state: State = State.PATROL
var mesh: Node3D

var waiting: bool = false
var wait_timer: float = 0.0

var is_knocked_back: bool = false
var knockback_velocity: Vector3 = Vector3.ZERO
var knockback_elapsed: float = 0.0
var playeraggroable = true
var playerattackable = true

var loot_item_id: String
var loot_min_amount: int
var loot_max_amount: int

var drop_item = true
var attack_hitbox_active: bool = false  # Track hitbox state

var _animation_tree: AnimationTree  # Reference to the AnimationTree
var _state_machine: AnimationNodeStateMachinePlayback
var was_on_floor := false

func _ready() -> void:
	
	if !player:
		player = get_tree().get_first_node_in_group("player") # Fallback
	if !health_ui:
		health_ui = get_tree().get_first_node_in_group("health_ui") # Fallback
	if !selectedtype and get_parent().has_method("get_frogselectedtype"):
		selectedtype = get_parent().get_frogselectedtype()
	if !loot_item_id:
		loot_item_id = get_parent().loot_item_id
	if !loot_min_amount:
		loot_min_amount = get_parent().loot_min_amount
	if !loot_max_amount:
		loot_max_amount = get_parent().loot_max_amount
		
	if patrol_bounds_area == null and get_parent() is Area3D:
		patrol_bounds_area = get_parent() as Area3D
	
	was_on_floor = true
	
	$MeshInstance3D/Area3D.area_entered.connect(_on_area_entered)
	$VisibilityRange.body_entered.connect(_on_vision_body_entered)
	$VisibilityRange.body_exited.connect(_on_vision_body_exited)
	$MeleeAttackRange.body_entered.connect(_on_melee_body_entered)
	$MeleeAttackRange.body_exited.connect(_on_melee_body_exited)
	$AttackHitbox.body_entered.connect(_on_hitbox_body_entered)
	
	set_attack_hitbox_active(false)
	$enemy/frog1.visible = false
	$enemy/frog2.visible = false
	$enemy/frog3.visible = false
	$enemy/frog4.visible = false
	
	mesh = class_models[selectedtype]
	mesh.visible = true
	_animation_tree = class_controller[selectedtype]
	_state_machine = _animation_tree.get("parameters/playback")
	$enemy/DeathParticles2.emitting = true
	_pick_new_target()

var target_velocity: Vector3 = Vector3.ZERO

func _physics_process(delta: float) -> void:
	match state:
		State.PATROL:
			if waiting:
				wait_timer -= delta
				_state_machine.travel("idle")
				if wait_timer <= 0:
					waiting = false
					_pick_new_target()
			else:
				patrol_walk_time += delta  # increment time walking to current target
				
				# If stuck or walking too long, pick a new target
				if patrol_walk_time > max_patrol_walk_duration or navigation_agent_3d.is_navigation_finished():
					if randf() < idle_chance:
						waiting = true
						wait_timer = randf_range(min_wait, max_wait)
						target_velocity = Vector3.ZERO
					else:
						_pick_new_target()
				else:
					var destination = navigation_agent_3d.get_next_path_position()
					var direction = (destination - global_position).normalized()
					target_velocity = direction * patrol_speed
					_state_machine.travel("walk")
				
			if not is_on_floor():
				velocity.y -= gravity * delta
			else:
				velocity.y = 0


		State.ATTACK:
			if player:
				var direction = (player.global_position - global_position).normalized()
				target_velocity = direction * chase_speed
				_state_machine.travel("walk")
			if not is_on_floor():
				velocity.y -= gravity * delta
			else:
				velocity.y = 0

		State.MELEE:
			target_velocity = Vector3.ZERO
			
			if not is_on_floor():
				velocity.y -= gravity * delta
			else:
				velocity.y = 0
			
			match melee_phase:
				MeleePhase.BUFFER:
					_state_machine.travel("idle")
					melee_timer -= delta
					if melee_timer <= 0.0:
						melee_phase = MeleePhase.ATTACKING
						$attacksound.play()
						melee_timer = 0.5  # duration of the attack animation
						_state_machine.travel("attack")
						# Deal damage once, e.g., instantly or use an animation event system if you have one
						# health_ui.take_damage(20)

				MeleePhase.ATTACKING:
					melee_timer -= delta

					if melee_timer <= 0.0:
						melee_phase = MeleePhase.RECOVERY
						melee_timer = 0.5  # recovery time before checking again

				MeleePhase.RECOVERY:
					melee_timer -= delta
					_state_machine.travel("idle")  # Play idle during recovery
					if melee_timer <= 0.0:
						if player and global_position.distance_to(player.global_position) <= melee_range:
							melee_phase = MeleePhase.BUFFER
							melee_timer = 1.0
						else:
							if playeraggroable:
								if playerattackable:
									state = State.MELEE
								else:
									state = State.ATTACK
							else:
								state = State.PATROL
			
		State.DAMAGE:
			if is_knocked_back:
				knockback_elapsed += delta
				velocity.x = knockback_velocity.x
				velocity.z = knockback_velocity.z
				
				var knockback_axis = knockback_velocity.cross(Vector3.UP).normalized()
				mesh.rotate(knockback_axis, deg_to_rad(-hitstun_rotation_speed))

				if knockback_elapsed >= knockback_duration and was_on_floor:
					is_knocked_back = false

			else:
				# Stop rotation and reset if needed
				if playeraggroable:
					if playerattackable:
						state = State.MELEE
					else:
						state = State.ATTACK
				else:
					state = State.PATROL

			if not is_on_floor():
				velocity.y -= gravity * delta

	
	if is_on_floor():
		mesh.rotation_degrees.x = 0
		mesh.rotation_degrees.z = 0

		
	# Smoothly interpolate velocity towards target_velocity
	if state != State.DAMAGE:
		velocity = velocity.lerp(target_velocity, 0.25)

	if state == State.ATTACK and player:
		var look_dir = (player.global_position - global_position).normalized()
		look_dir.y = 0  # Keep the look direction horizontal
		if look_dir.length() > 0.1:
			var target = global_position + look_dir
			var direction = (target - mesh.global_position).normalized()
			var target_angle = atan2(direction.x, direction.z)
			mesh.rotation.y = lerp_angle(mesh.rotation.y, target_angle - deg_to_rad(90), delta * 5.0)

	elif state == State.PATROL and not waiting and not navigation_agent_3d.is_navigation_finished():
		var look_dir = (navigation_agent_3d.get_next_path_position() - global_position).normalized()
		look_dir.y = 0
		if look_dir.length() > 0.1:
			var target = global_position + look_dir
			var direction = (target - mesh.global_position).normalized()
			var target_angle = atan2(direction.x, direction.z)
			mesh.rotation.y = lerp_angle(mesh.rotation.y, target_angle - deg_to_rad(90), delta * 5.0)
	
	was_on_floor = is_on_floor()
	move_and_slide()
	
	var desired_hitbox_state = (state == State.MELEE and melee_phase == MeleePhase.ATTACKING)
	# Only update hitbox if its state changed
	
	if attack_hitbox_active != desired_hitbox_state:
		set_attack_hitbox_active(desired_hitbox_state)
		attack_hitbox_active = desired_hitbox_state

func _pick_new_target() -> void:
	var center = patrol_bounds_area.global_position
	var random_position = Vector3(
		randf_range(center.x - 15.0, center.x + 15.0),
		global_position.y,
		randf_range(center.z - 15.0, center.z + 15.0)
	)
	navigation_agent_3d.set_target_position(random_position)
	patrol_walk_time = 0.0

func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("playerattack"):
		var direction = (global_transform.origin - area.global_transform.origin).normalized()
		print(direction)
		health -= 1.0
		apply_knockback(direction)
		$enemy/AttackParticles.restart()
		$enemy/AttackParticles.emitting = true
		print("ENEMY: Took damage! Health now: ", health)
		$hitsound.play()
		if health <= 0:
			die()

func _on_vision_body_entered(body):
	if body.is_in_group("player"):
		player = body
		state = State.ATTACK
		playeraggroable = true
		print("ENEMY: Spotted player! Switching to ATTACK.")

func _on_vision_body_exited(body):
	if body.is_in_group("player"):
		player = null
		if state == State.ATTACK:
			state = State.PATROL
		playeraggroable = false
		playerattackable = false
		print("ENEMY: Player left vision.")
		

func _on_melee_body_entered(body):
	if body.is_in_group("player"):
		player = body
		state = State.MELEE
		melee_phase = MeleePhase.BUFFER
		melee_timer = 1.0
		playeraggroable = true
		playerattackable = true
		print("ENEMY: Meleeing player! Switching to MELEE.")


func _on_melee_body_exited(body):
	if body.is_in_group("player"):
		playerattackable = false
		print("ENEMY: Player left melee.")

func apply_knockback(direction: Vector3) -> void:
	is_knocked_back = true
	state = State.DAMAGE
	melee_phase = MeleePhase.BUFFER
	melee_timer = 1.0

	if _state_machine:
		_state_machine.travel("idle")
		
	
	knockback_elapsed = 0.0
	direction.y = 0
	direction = direction.normalized()
	
	if health <= 0:
		knockback_velocity = direction * knockback_strength * 2.5
	else:
		knockback_velocity = direction * knockback_strength 

	if is_on_floor():
			if health <= 0:
				knockback_velocity.y = knockback_strength * 1.5
			else:
				knockback_velocity.y = knockback_strength * 0.5
				
	else:
		knockback_velocity.y = 0  # prevent excess air lift

	velocity = knockback_velocity

func die():
	print("ENEMY: Dying...")
	QuestManager.on_enemy_defeated("frog")
	
	# Give loot before removing enemy
	if loot_item_id != "default_item" and drop_item:
		var loot_amount = randi() % (loot_max_amount - loot_min_amount + 1) + loot_min_amount
		Global.inventory_ref.add_item(loot_item_id, loot_amount)
		drop_item = false
	
	$enemy/DeathParticles1.emitting = true
	
	var exploding_timer := Timer.new()
	exploding_timer.one_shot = true
	exploding_timer.wait_time = 0.25
	add_child(exploding_timer)
	exploding_timer.start()
	await exploding_timer.timeout
	
	if mesh:
		mesh.visible = false
		
	if $MinimapSign.visible:
		$MinimapSign.visible = false
	
	$explosionsound.play()
		
	if $CollisionShape3D:
		$CollisionShape3D.queue_free()

	mesh.rotation_degrees.x = 0
	mesh.rotation_degrees.z = 0
	
	$enemy/DeathParticles1.emitting = false
	$enemy/DeathParticles2.emitting = true
	$enemy/DeathParticles3.emitting = true

	exploding_timer.wait_time = 2
	exploding_timer.start()
	await exploding_timer.timeout

	queue_free()

func set_attack_hitbox_active(active: bool) -> void:
	$AttackHitbox.monitoring = active
	$AttackHitbox.monitorable = active

func _on_hitbox_body_entered(body):
	print(body)
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			var direction = (body.global_transform.origin - global_transform.origin).normalized()
			var upward_force = 30.0
			body.take_damage(damagedealt, direction, knockback_strength, upward_force)
