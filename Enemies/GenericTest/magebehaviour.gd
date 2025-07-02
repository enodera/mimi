extends CharacterBody3D

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D

enum State { PATROL, ATTACK, MELEE, DAMAGE, DISAPPEAR }
enum Class { MAGE1, MAGE2 }

enum MeleePhase { BUFFER, ATTACKING, RECOVERY }
var melee_phase: MeleePhase = MeleePhase.BUFFER
var melee_timer: float = 0.3

var player
var health_ui
var selectedtype: Class

@onready var class_models = {
	Class.MAGE1: $enemy/mage1,
	Class.MAGE2: $enemy/mage2
}

@onready var class_controller = {
	Class.MAGE1: $enemy/mage1/AnimationTree,
	Class.MAGE2: $enemy/mage2/AnimationTree
}

var multiplebullets : bool = false

@onready var decidebullets = {
	Class.MAGE1: false,
	Class.MAGE2: true
}

@export_group("Physics")
@export var knockback_strength: float = 25.0
@export var gravity: float = 125.0

@export_group("Stats")
@export var health: float = 10.0
@export var damagedealt: int = 10

@export_group("Movement")
@export var patrol_speed: float = 40.0
@export var chase_speed: float = 6.0
@export var patrol_wait_time: float = 1.5
@export var patrol_bounds_area: Area3D
@export var melee_range: float = 3.0
@export var vision_range: float = 10.0

@export var hitstun_rotation_speed: float = 20.0
@export var disappear_timer: float = 0.4  # length of disappear animation

@export var max_wait: float = 1.0
@export var min_wait: float = 2.0

@export var idle_chance: float = 0.3
@export var knockback_duration: float = 0.25

@export_group("Loot")
@export var loot_item_id: String = "milk"
@export var loot_min_amount: int = 1
@export var loot_max_amount: int = 3

@export_group("Projectile")
@export var projectile_scene: PackedScene = null

var just_disappeared = false

var state: State = State.PATROL
var mesh: Node3D

var waiting: bool = false
var wait_timer: float = 0.0

var is_knocked_back: bool = false
var knockback_velocity: Vector3 = Vector3.ZERO
var knockback_elapsed: float = 0.0
var playeraggroable = true
var playerattackable = true

var drop_item = true
var attack_hitbox_active: bool = false

var _animation_tree: AnimationTree
var _state_machine: AnimationNodeStateMachinePlayback
var dying = false

func _ready() -> void:
	if !player:
		player = get_tree().get_first_node_in_group("player")
	if !health_ui:
		health_ui = get_tree().get_first_node_in_group("health_ui")
	if !selectedtype:
		selectedtype = get_parent().selectedtype
	
	if patrol_bounds_area == null and get_parent() is Area3D:
		patrol_bounds_area = get_parent() as Area3D
	
	$MeshInstance3D/Area3D.area_entered.connect(_on_area_entered)
	$VisibilityRange.body_entered.connect(_on_vision_body_entered)
	$VisibilityRange.body_exited.connect(_on_vision_body_exited)
	$MeleeAttackRange.body_entered.connect(_on_melee_body_entered)
	$MeleeAttackRange.body_exited.connect(_on_melee_body_exited)
	$enemy/AttackHitbox.body_entered.connect(_on_hitbox_body_entered)
	
	set_attack_hitbox_active(false)
	$enemy/mage1.visible = false
	$enemy/mage2.visible = false
	
	multiplebullets = decidebullets[selectedtype]
	
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
				if navigation_agent_3d.is_navigation_finished():
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
						melee_timer = 0.25
						melee_phase = MeleePhase.ATTACKING
						_state_machine.travel("attack")
						if not dying:
							shoot_projectile()

				MeleePhase.ATTACKING:
					melee_timer -= delta
					if melee_timer <= 0.0:
						melee_timer = 0.55
						melee_phase = MeleePhase.RECOVERY

				MeleePhase.RECOVERY:
					melee_timer -= delta
					_state_machine.travel("idle")
					if melee_timer <= 0.0:
						_state_machine.travel("disappear")
						disappear_timer = 0.4
						melee_timer = 0.3
						state = State.DISAPPEAR

		State.DAMAGE:
			if is_knocked_back:
				knockback_elapsed += delta
				velocity.x = knockback_velocity.x
				velocity.z = knockback_velocity.z
				
				if player:
					var look_dir = (player.global_position - mesh.global_position)
					look_dir.y = 0  # ignore vertical difference for rotation
					if look_dir.length() > 0.1:
						look_dir = look_dir.normalized()
						var target_angle = atan2(look_dir.x, look_dir.z)
						mesh.rotation.y = lerp_angle(mesh.rotation.y, target_angle - deg_to_rad(90), delta * 5.0)

				if knockback_elapsed >= knockback_duration:
					is_knocked_back = false
			else:
				if playeraggroable:
					if playerattackable:
						melee_phase = MeleePhase.RECOVERY
						if not dying:
							state = State.MELEE
						else:
							state = State.DAMAGE
					else:
						state = State.ATTACK
				else:
					state = State.PATROL
				melee_timer = 0.5
				
			if not is_on_floor():
				velocity.y -= gravity * delta

		State.DISAPPEAR:
			disappear_timer -= delta
			target_velocity = Vector3.ZERO
			if disappear_timer <= 0:
				disappear_timer = 0.4
				if not just_disappeared:
					_teleport_nearby()
					just_disappeared = true
					set_player_detection_areas(not just_disappeared)
					print("STATE PLAY: JUST DISSAPEARED")

				else:
					print("STATE PLAY: NOT JUST DISSAPEARED")
					just_disappeared = false
					set_player_detection_areas(not just_disappeared)
					melee_timer = 0.5
					melee_phase = MeleePhase.BUFFER
					state = State.MELEE if playeraggroable and playerattackable else State.PATROL
					
	if is_on_floor():
		mesh.rotation_degrees.x = 0
		mesh.rotation_degrees.z = 0
		
	if state != State.DAMAGE and state != State.DISAPPEAR:
		velocity = velocity.lerp(target_velocity, 0.25)

	if state in [State.ATTACK, State.PATROL, State.MELEE]:
		var look_dir = Vector3.ZERO
		if state == State.ATTACK and player:
			look_dir = (player.global_position - global_position).normalized()
		elif state == State.PATROL and not waiting and not navigation_agent_3d.is_navigation_finished():
			look_dir = (navigation_agent_3d.get_next_path_position() - global_position).normalized()
		if state == State.MELEE and player and melee_timer >= 0.2:
			look_dir = (player.global_position - global_position).normalized()
			
		look_dir.y = 0
		if look_dir.length() > 0.1:
			var target = global_position + look_dir
			var direction = (target - mesh.global_position).normalized()
			var target_angle = atan2(direction.x, direction.z)
			mesh.rotation.y = lerp_angle(mesh.rotation.y, target_angle - deg_to_rad(90), delta * 5.0)

	move_and_slide()

	var desired_hitbox_state = (state == State.MELEE and melee_phase == MeleePhase.ATTACKING)
	if attack_hitbox_active != desired_hitbox_state:
		set_attack_hitbox_active(desired_hitbox_state)
	
	attack_hitbox_active = desired_hitbox_state
	
	$enemy/AttackHitbox.rotation = mesh.rotation

func _pick_new_target() -> void:
	var center = patrol_bounds_area.global_position
	var random_position = Vector3(
		randf_range(center.x - 15.0, center.x + 15.0),
		global_position.y,
		randf_range(center.z - 15.0, center.z + 15.0)
	)
	navigation_agent_3d.set_target_position(random_position)

func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("playerattack"):
		var direction = (global_transform.origin - area.global_transform.origin).normalized()
		health -= 1.0
		apply_knockback(direction)
		$enemy/AttackParticles.restart()
		$enemy/AttackParticles.emitting = true
		if health <= 0:
			die()

func _on_vision_body_entered(body):
	if body.is_in_group("player"):
		player = body
		state = State.ATTACK
		playeraggroable = true

func _on_vision_body_exited(body):
	if body.is_in_group("player"):
		player = null
		if state == State.ATTACK:
			state = State.PATROL
		playeraggroable = false
		playerattackable = false

func _on_melee_body_entered(body):
	if body.is_in_group("player") and state != State.DISAPPEAR:
		player = body
		if not dying:
			state = State.MELEE
		melee_timer = 0.5
		melee_phase = MeleePhase.BUFFER
		playeraggroable = true
		playerattackable = true

func _on_melee_body_exited(body):
	if body.is_in_group("player"):
		playerattackable = false

func apply_knockback(direction: Vector3) -> void:
	is_knocked_back = true
	state = State.DAMAGE
	melee_timer = 1.0
	melee_phase = MeleePhase.BUFFER
	
	_state_machine.travel("damagestatic")

	knockback_elapsed = 0.0
	direction.y = 0
	direction = direction.normalized()

	knockback_velocity = direction * knockback_strength * (2.5 if health <= 0 else 1.0)
	
	if is_on_floor():
		if health <= 0:
			knockback_velocity.y = knockback_strength * 1.5
		else:
			knockback_velocity.y = knockback_strength * 0.5
	else:
		knockback_velocity.y = 0

	velocity = knockback_velocity

func die():
	
	dying = true
	QuestManager.on_enemy_defeated("mage")
	
	if loot_item_id != "default_item" and drop_item:
		var loot_amount = randi() % (loot_max_amount - loot_min_amount + 1) + loot_min_amount
		Global.inventory_ref.add_item(loot_item_id, loot_amount)

	$enemy/DeathParticles1.emitting = true
	var exploding_timer := Timer.new()
	exploding_timer.one_shot = true
	exploding_timer.wait_time = 0.25
	add_child(exploding_timer)
	exploding_timer.start()
	await exploding_timer.timeout
	
	if mesh.visible:
		mesh.visible = false
	
	if $MinimapSign.visible:
		$MinimapSign.visible = false
	
	if $CollisionShape3D:
		$CollisionShape3D.queue_free()
	
	$enemy/DeathParticles1.emitting = false
	$enemy/DeathParticles2.emitting = true
	$enemy/DeathParticles3.emitting = true

	exploding_timer.wait_time = 2
	exploding_timer.start()
	await exploding_timer.timeout

	queue_free()

func set_attack_hitbox_active(active: bool) -> void:
	$enemy/AttackHitbox.monitoring = active
	$enemy/AttackHitbox.monitorable = active
	

func set_player_detection_areas(active: bool) -> void:
	$MeleeAttackRange.monitoring = active
	$MeleeAttackRange.monitorable = active
	$VisibilityRange.monitoring = active
	$VisibilityRange.monitorable = active


func _on_hitbox_body_entered(body):
	if body.is_in_group("player") and body.has_method("take_damage"):
		var direction = (body.global_transform.origin - global_transform.origin).normalized()
		body.take_damage(damagedealt, direction, 18.0, 30.0)

func _get_cylinder_aabb(shape: CylinderShape3D) -> AABB:
	var radius = shape.radius
	var height = shape.height
	
	var min_pos = Vector3(-radius, -height * 0.5, -radius)
	var size = Vector3(radius * 2, height, radius * 2)
	return AABB(min_pos, size)

func _teleport_nearby() -> void:
	if patrol_bounds_area:
		var collision_shape = patrol_bounds_area.get_node_or_null("CollisionShape3D")
		if collision_shape and collision_shape.shape:
			var shape = collision_shape.shape
			var aabb: AABB
			
			if shape is BoxShape3D:
				aabb = shape.get_aabb()
			elif shape is CylinderShape3D:
				aabb = _get_cylinder_aabb(shape)
			else:
				# Fallback for unsupported shapes:
				aabb = AABB(Vector3.ZERO, Vector3(10,10,10)) # arbitrary size
			
			var mage_position = collision_shape.global_transform
			var min_global = mage_position * aabb.position
			var max_global = mage_position * (aabb.position + aabb.size)
			
			var random_pos = Vector3(
				randf_range(min_global.x, max_global.x),
				global_position.y,
				randf_range(min_global.z, max_global.z)
			)
			
			global_position = random_pos
			navigation_agent_3d.set_target_position(random_pos)
		else:
			global_position = patrol_bounds_area.global_position
			navigation_agent_3d.set_target_position(global_position)

func shoot_projectile():
	var vertical_offset = Vector3.UP * 2.5
	var smalladjust = Vector3.UP
	var spawn_position = global_position + vertical_offset
	var base_direction = (player.global_position - global_position - smalladjust).normalized()

	if multiplebullets:
		# Define angles for fan spread in radians
		var fan_angle = 3.25  # Adjust this for wider or narrower spread

		# Directions for the three bullets
		var directions = [
			base_direction.rotated(Vector3.UP, -fan_angle),  # Left
			base_direction.rotated(Vector3.UP, fan_angle)   # Right
		]

		for dir in directions:
			var projectile = projectile_scene.instantiate()
			projectile.player = player
			projectile.smalladjust = smalladjust
			get_tree().current_scene.add_child(projectile)
			projectile.global_position = spawn_position
			projectile.direction = dir
	else:
		var projectile = projectile_scene.instantiate()
		projectile.player = player
		projectile.smalladjust = smalladjust
		get_tree().current_scene.add_child(projectile)
		projectile.global_position = spawn_position
		projectile.direction = base_direction


	
