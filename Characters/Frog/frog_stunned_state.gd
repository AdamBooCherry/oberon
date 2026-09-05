class_name FrogStunnedState
extends State

@export var frog: FrogMob
@export var stun_duration: float = 8.0
@export var state_machine: StateMachine

var _timer: float = 0.0
var _is_escaping: bool = false

func enter() -> void:
	print("[StunState] ENTERED")
	_timer = 0.0
	_is_escaping = false
	
	frog.velocity = Vector3.ZERO
	frog.is_stunned = true
	frog.set_hidden(false)
	
	if frog.animation_player and frog.animation_player.has_animation("Armature|Frog_Death"):
		frog.animation_player.play("Armature|Frog_Death")

	# Check if frog is already inside an AttractionArea when stunned
	var attraction_area = _find_attraction_area()
	if attraction_area and frog.attractable_area:
		print("[StunState] Found AttractionArea on enter! Initiating attraction.")
		frog.attractable_area.start_attraction(attraction_area)

func update(delta: float) -> void:
	if frog.is_picked_up or _is_escaping:
		return
		
	_timer += delta
	if _timer >= stun_duration:
		_recover_and_escape()

func _recover_and_escape() -> void:
	if _is_escaping:
		return
	_is_escaping = true

	print("[StunState] Stun expired! Escaping...")
	
	if frog.attractable_area and frog.attractable_area.current_attractor:
		frog.attractable_area.stop_attraction(frog.attractable_area.current_attractor)

	if frog.animation_player and frog.animation_player.has_animation("Armature|Frog_Death"):
		frog.animation_player.play_backwards("Armature|Frog_Death")
		await frog.animation_player.animation_finished

	if state_machine and state_machine.current_state == self:
		frog.is_stunned = false
		state_machine.change_state("FrogHideState")

func exit() -> void:
	print("[StunState] EXITED")
	_is_escaping = false
	frog.is_stunned = false

	if frog.homing_component:
		frog.homing_component.stop_homing()

func _find_attraction_area() -> AttractionArea:
	var search_node: Node3D = frog.player_node
	
	if not search_node:
		var players = frog.get_tree().get_nodes_in_group("Player")
		if players.size() > 0:
			search_node = players[0] as Node3D

	if search_node:
		for child in search_node.get_children():
			if child is AttractionArea:
				return child

	return null
