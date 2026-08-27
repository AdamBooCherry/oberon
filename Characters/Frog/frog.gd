class_name FrogMob
extends CharacterBody3D

@export var move_speed: float = 1.5
@export var run_speed: float = 5.0 
@export var detection_radius: float = 2.5
@export var pinata_respawn_delay: float = 5.0

@export_group("References")
@export var player_detector: Area3D
@export var animation_player: AnimationPlayer
@export var navigation_agent_3d: NavigationAgent3D
@export var state_machine: StateMachine
@export var frog_mesh: MeshInstance3D
@export var reveal_pinata: RevealPinata

#const FROG_COLLECT = preload("uid://brvyfw32spq8")

var is_stunned: bool = false
var is_picked_up: bool = false
var is_hidden: bool = false
var player_node: Node3D = null

func _ready() -> void:
	print("[FrogMob] Ready called on: ", self.name)
	set_hidden(true)
	
	if player_detector:
		player_detector.area_entered.connect(_on_area_entered)
	else:
		print("[FrogMob] WARNING: player_detector is null!")
		
	if state_machine:
		state_machine.init(self)
	else:
		print("[FrogMob] WARNING: state_machine reference is missing in Inspector!")
		
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		player_node = players[0]
	
	if reveal_pinata:
		reveal_pinata.pinata_broken.connect(_on_pinata_broken)

func _process(delta: float) -> void:
	if state_machine:
		state_machine.update(delta)

func _physics_process(delta: float) -> void:
	if state_machine:
		state_machine.physics_update(delta)
		
	if not is_stunned and not is_picked_up and player_node and state_machine:
		var current_state = state_machine.current_state
		if current_state and current_state.name.to_lower() in ["frogidlestate", "frogwanderstate", "froghidestate"]:
			if global_position.distance_to(player_node.global_position) <= detection_radius:
				state_machine.change_state("FrogStartledState")

func set_hidden(hidden: bool) -> void:
	if is_hidden == hidden:
		return
		
	is_hidden = hidden
	if not frog_mesh:
		return
		
	if is_hidden:
		frog_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
		print("hide")
	else:
		frog_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		SceneHelper.spawn_effect("uid://dqo2wy1r43ocf", self.global_position, get_parent())
		print("show")

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
	set_hidden(false)
	
	if state_machine:
		state_machine.change_state("FrogStunnedState")

func get_picked_up() -> void:
	is_picked_up = true
	InventoryManager.has_frog = true
	
	var spawn_pos = global_position
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	
	if player_detector:
		for child in player_detector.find_children("*", "CollisionShape3D"):
			child.disabled = true
		for child in player_detector.find_children("*", "CollisionPolygon3D"):
			child.disabled = true
			
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector3(0.01, 0.01, 0.01), 0.3)
	tween.tween_property(self, "position", position + Vector3(0, 1.0, 0), 0.3)
	
	await tween.finished
	
	SceneHelper.spawn_effect("uid://brvyfw32spq8", spawn_pos, get_parent())
	
	queue_free()

func _on_pinata_broken() -> void:
	await get_tree().create_timer(pinata_respawn_delay).timeout
	
	if is_instance_valid(reveal_pinata):
		reveal_pinata.reset_pinata()
