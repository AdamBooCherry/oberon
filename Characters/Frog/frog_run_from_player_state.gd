class_name FrogRunFromPlayerState
extends State

@export var frog: FrogMob
@export var flee_distance: float = 6.0
@export var max_flee_time: float = 3.0  # Safety fallback timer

var player_node: Node3D
var _flee_timer: float = 0.0
var _has_reached_target: bool = false

func enter() -> void:
	#print("[RunFromPlayerState] ENTERED. Fleeing from player with smart pathing!")
	if not frog:
		return
		
	frog.set_hidden(false)
	_flee_timer = 0.0
	_has_reached_target = false
	
	if frog.animation_player and frog.animation_player.has_animation("Armature|Frog_Jump"):
		frog.animation_player.play("Armature|Frog_Jump")
		
	var players = frog.get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		player_node = players[0]
		
	if frog.navigation_agent_3d:
		if not frog.navigation_agent_3d.target_reached.is_connected(_on_target_reached):
			frog.navigation_agent_3d.target_reached.connect(_on_target_reached)
			
	if player_node and frog.navigation_agent_3d:
		var nav_map = frog.navigation_agent_3d.get_navigation_map()
		
		# 1. Calculate primary escape vector away from player
		var base_flee_dir = (frog.global_position - player_node.global_position).normalized()
		base_flee_dir.y = 0
		
		# 2. Test multiple offset angles (Straight, 30 deg left/right, 60 deg left/right)
		# This prevents getting stuck on walls by fanning out our search options.
		var angles_to_test = [0.0, 0.5, -0.5, 1.0, -1.0]
		var best_pos = frog.global_position
		var max_distance_found = -1.0
		
		for angle in angles_to_test:
			var rotated_dir = base_flee_dir.rotated(Vector3.UP, angle)
			var candidate_pos = frog.global_position + (rotated_dir * flee_distance)
			var clamped_pos = NavigationServer3D.map_get_closest_point(nav_map, candidate_pos)
			
			# Check how far this valid navmesh point actually gets us from the player
			var dist_from_player = clamped_pos.distance_to(player_node.global_position)
			
			# We also want to make sure it's not pathing right back toward the player
			if dist_from_player > max_distance_found:
				max_distance_found = dist_from_player
				best_pos = clamped_pos
				
		# Assign the best smart escape position found
		frog.navigation_agent_3d.target_position = best_pos
	else:
		parent_state_machine.change_state("FrogHideState")

func physics_update(delta: float) -> void:
	if not frog or frog.is_stunned:
		return
		
	_flee_timer += delta
	if _flee_timer >= max_flee_time or _has_reached_target:
		parent_state_machine.change_state("FrogHideState")
		return
		
	if not frog.navigation_agent_3d:
		parent_state_machine.change_state("FrogHideState")
		return
		
	var next_path_pos = frog.navigation_agent_3d.get_next_path_position()
	var direction = (next_path_pos - frog.global_position).normalized()
	direction.y = 0
	
	frog.velocity = direction * frog.run_speed
	
	if not frog.is_on_floor():
		frog.velocity.y -= 9.8 * delta
		
	frog.move_and_slide()
	
	if direction != Vector3.ZERO:
		var target_rotation = atan2(-direction.x, -direction.z)
		frog.rotation.y = lerp_angle(frog.rotation.y, target_rotation, delta * 12.0)

func _on_target_reached() -> void:
	#print("[RunFromPlayerState] Navigation target reached signal fired!")
	_has_reached_target = true

func exit() -> void:
	if frog and frog.navigation_agent_3d:
		if frog.navigation_agent_3d.target_reached.is_connected(_on_target_reached):
			frog.navigation_agent_3d.target_reached.disconnect(_on_target_reached)
