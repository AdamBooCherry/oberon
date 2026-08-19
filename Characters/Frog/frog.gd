class_name FrogMob
extends CharacterBody3D

@export var move_speed: float = 1.5
@export var detection_radius: float = 2.5

@export_group("References")
@export var player_detector: Area3D
@export var animation_player: AnimationPlayer
@export var navigation_agent_3d: NavigationAgent3D
@export var state_machine: StateMachine
const FROG_COLLECT = preload("uid://brvyfw32spq8")


var is_stunned: bool = false
var is_picked_up: bool = false
var player_node: Node3D = null

func _ready() -> void:
	print("[FrogMob] Ready called on: ", self.name)
	
	if player_detector:
		player_detector.area_entered.connect(_on_area_entered)
	else:
		print("[FrogMob] WARNING: player_detector is null!")
		
	if state_machine:
		print("[FrogMob] State machine found: ", state_machine.name)
		state_machine.init(self)
	else:
		print("[FrogMob] WARNING: state_machine reference is missing in Inspector!")
		
	# Find player reference for fleeing mechanics
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		player_node = players[0]

func _process(delta: float) -> void:
	if state_machine:
		state_machine.update(delta)

func _physics_process(delta: float) -> void:
	if state_machine:
		state_machine.physics_update(delta)
		
	# Global check: If player gets close while wandering/idle, switch to running away
	if not is_stunned and not is_picked_up and player_node and state_machine:
		var current_state_name = state_machine.current_state.name.to_lower() if state_machine.current_state else ""
		
		if current_state_name in ["frogidlestate", "frogwanderstate"]:
			var distance = global_position.distance_to(player_node.global_position)
			if distance <= detection_radius:
				state_machine.change_state("FrogRunFromPlayerState")

func _on_area_entered(area: Area3D) -> void:
	if is_picked_up:
		return
		
	if area is FrogCollector:
		if not is_stunned:
			_get_stunned()
		else:
			get_picked_up()

func _get_stunned() -> void:
	is_stunned = true
	
	if state_machine:
		state_machine.change_state("FrogStunnedState")
		
	if animation_player:
		animation_player.play("Armature|Frog_Death")
		await animation_player.animation_finished

func get_picked_up() -> void:
	is_picked_up = true
	print("Frog collected!")
	
	InventoryManager.has_frog = true
	
	var spawn_pos = global_position
	print("[FrogMob] Captured spawn_pos before tween: ", spawn_pos)
	
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	
	if player_detector:
		for child in player_detector.find_children("*", "CollisionShape3D"):
			child.disabled = true
		for child in player_detector.find_children("*", "CollisionPolygon3D"):
			child.disabled = true
			
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector3.ZERO, 0.3)
	tween.tween_property(self, "position", position + Vector3(0, 1.0, 0), 0.3)
	
	await tween.finished
	print("[FrogMob] Tween finished. Current global_position: ", global_position)
	
	# Spawn the collection effect scene
	var collect_effect = FROG_COLLECT.instantiate()
	print("[FrogMob] Instantiated collect_effect. Type: ", collect_effect.get_class())
	
	get_parent().add_child(collect_effect)
	print("[FrogMob] Added to current_scene: ", get_tree().current_scene.name)
	
	collect_effect.global_position = spawn_pos
	print("[FrogMob] Assigned global_position to effect: ", collect_effect.global_position)
	
	self.queue_free()
