class_name FrogRunFromPlayerState
extends State

@export var frog: FrogMob
@export var flee_speed: float = 5.0
@export var safe_distance: float = 6.0

var player_node: Node3D

func enter() -> void:
	print("[RunFromPlayerState] ENTERED. Fleeing from player!")
	if frog and frog.animation_player:
		frog.animation_player.play("Armature|Frog_Jump")
		
	var players = frog.get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		player_node = players[0]

func physics_update(delta: float) -> void:
	if not frog or frog.is_stunned:
		return
		
	if not player_node:
		parent_state_machine.change_state("FrogIdleState")
		return
		
	var distance_to_player = frog.global_position.distance_to(player_node.global_position)
	
	if distance_to_player >= safe_distance:
		print("[RunFromPlayerState] Safe distance reached. Returning to Idle.")
		parent_state_machine.change_state("FrogIdleState")
		return
		
	# Pick a point away from the player using the navigation system
	if frog.navigation_agent_3d:
		var flee_dir = (frog.global_position - player_node.global_position).normalized()
		var target_flee_pos = frog.global_position + (flee_dir * safe_distance)
		
		# Ask NavigationServer for a valid point on the navmesh
		var clamped_pos = NavigationServer3D.map_get_closest_point(frog.navigation_agent_3d.get_navigation_map(), target_flee_pos)
		frog.navigation_agent_3d.target_position = clamped_pos
		
		if not frog.navigation_agent_3d.is_navigation_finished():
			var next_path_pos = frog.navigation_agent_3d.get_next_path_position()
			var direction = (next_path_pos - frog.global_position).normalized()
			direction.y = 0
			
			frog.velocity = direction * flee_speed
			frog.move_and_slide()
			
			if direction != Vector3.ZERO:
				var target_rotation = atan2(-direction.x, -direction.z)
				frog.rotation.y = lerp_angle(frog.rotation.y, target_rotation, delta * 12.0)
