class_name FrogMob
extends CharacterBody3D

@export var move_speed: float = 1.5
@export var run_speed: float = 5.0 
@export var detection_radius: float = 2.5
@export var pinata_respawn_delay: float = 5.0
@export var frog_inventory_value: int = 1

@export_group("References")
@export var animation_player: AnimationPlayer
@export var navigation_agent_3d: NavigationAgent3D
@export var state_machine: StateMachine
@export var frog_mesh: MeshInstance3D
@export var reveal_pinata: RevealPinata
@export var attractable_area: AttractableArea

var is_stunned: bool = false
var is_picked_up: bool = false
var is_hidden: bool = false
var player_node: Node3D = null

func _ready() -> void:
	set_hidden(true)
	
	if state_machine:
		state_machine.init(self)
		
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		player_node = players[0]
	
	if reveal_pinata:
		reveal_pinata.pinata_broken.connect(_on_pinata_broken)

	if attractable_area:
		attractable_area.collected.connect(_on_collected)

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
	else:
		frog_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		SceneHelper.spawn_effect("uid://dqo2wy1r43ocf", self.global_position, get_parent())

func _on_collected(_collector: AttractionArea) -> void:
	if is_picked_up:
		return

	is_picked_up = true
	InventoryManager.has_frog = true
	InventoryManager.increment_currency(frog_inventory_value)

	# Spawn pickup VFX at final arrival location before queue_free
	SceneHelper.spawn_effect("uid://brvyfw32spq8", global_position, get_parent())

func _on_pinata_broken() -> void:
	if state_machine:
		state_machine.change_state("FrogStunnedState")

	# Retain timer task using a local SceneTreeTimer reference
	var respawn_timer := get_tree().create_timer(pinata_respawn_delay)
	respawn_timer.timeout.connect(func():
		if is_instance_valid(reveal_pinata):
			reveal_pinata.reset_pinata()
	)
