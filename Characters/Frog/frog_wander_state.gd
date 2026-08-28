class_name FrogWanderState
extends State

@export var frog: FrogMob
@export var wander_radius: float = 20.0

var _path_initialized: bool = false

func enter() -> void:
	if frog and frog.animation_player:
		frog.animation_player.play("Armature|Frog_Jump")
		
	_path_initialized = false
	
	# Wait one frame for the NavigationServer to be fully ready, then pick a target
	await get_tree().physics_frame
	if frog and frog.navigation_agent_3d:
		_pick_random_destination()

func _pick_random_destination() -> void:
	if not frog or not frog.navigation_agent_3d:
		return
		
	var random_angle = randf() * TAU
	var random_distance = randf_range(1.0, wander_radius)
	var offset = Vector3(cos(random_angle), 0, sin(random_angle)) * random_distance
	var target_pos = frog.global_position + offset
	
	frog.navigation_agent_3d.target_position = target_pos
	_path_initialized = true
	#print("[WanderState] Picked new wander target: ", target_pos)

func physics_update(delta: float) -> void:
	if not frog or not _path_initialized:
		return
		
	if frog.is_stunned:
		frog.velocity = Vector3.ZERO
		return
		
	var nav = frog.navigation_agent_3d
	if not nav:
		return
		
	# Check if we've arrived at the destination
	if nav.is_navigation_finished():
		#print("[WanderState] Reached destination! Switching to Idle.")
		parent_state_machine.change_state("FrogIdleState")
		return
		
	var next_path_pos = nav.get_next_path_position()
	var direction = (next_path_pos - frog.global_position).normalized()
	direction.y = 0 
	
	frog.velocity = direction * frog.move_speed
	frog.move_and_slide()
	
	if direction != Vector3.ZERO:
		var target_rotation = atan2(-direction.x, -direction.z)
		frog.rotation.y = lerp_angle(frog.rotation.y, target_rotation, delta * 10.0)
