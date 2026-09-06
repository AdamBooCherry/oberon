class_name FrogStunnedState
extends State

@export var stun_duration: float = 8.0

@export_group("Stun Visuals")
@export var stunned_scale: Vector3 = Vector3(0.4, 0.4, 0.4)
@export var hover_height: float = 0.5
@export var glow_target_scale: Vector3 = Vector3(1.5, 1.5, 1.5)
@export var tween_duration: float = 0.3

@export_group("References")
@export var frog: FrogMob
@export var state_machine: StateMachine
@export var glow_sprite: Sprite3D
@export var homing_component: HomingComponent

var _timer: float = 0.0
var _is_escaping: bool = false
var _original_mesh_scale: Vector3 = Vector3.ONE
var _original_mesh_pos: Vector3 = Vector3.ZERO
var _visual_tween: Tween

func enter() -> void:
	print("[StunState] ENTERED")
	_timer = 0.0
	_is_escaping = false
	
	frog.velocity = Vector3.ZERO
	frog.is_stunned = true
	frog.set_hidden(false)

	# Store base transforms from the mesh
	if frog.frog_mesh:
		_original_mesh_scale = frog.frog_mesh.scale
		_original_mesh_pos = frog.frog_mesh.position
	
	if frog.animation_player and frog.animation_player.has_animation("Armature|Frog_Death"):
		frog.animation_player.play("Armature|Frog_Death")

	_apply_stun_effects()

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

func _apply_stun_effects() -> void:
	if _visual_tween and _visual_tween.is_running():
		_visual_tween.kill()

	_visual_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	# 1. Scale down and hover mesh
	if frog.frog_mesh:
		_visual_tween.tween_property(frog, "scale", _original_mesh_scale * stunned_scale, tween_duration)
		#_visual_tween.tween_property(frog, "position", _original_mesh_pos + Vector3(0, hover_height, 0), tween_duration)

	# 2. Scale up and fade in glow sprite
	if glow_sprite:
		glow_sprite.visible = true
		glow_sprite.scale = Vector3.ZERO
		glow_sprite.modulate.a = 0.0
		_visual_tween.tween_property(glow_sprite, "scale", glow_target_scale, tween_duration)
		_visual_tween.tween_property(glow_sprite, "modulate:a", 1.0, tween_duration)

func _revert_stun_effects() -> void:
	if _visual_tween and _visual_tween.is_running():
		_visual_tween.kill()

	_visual_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

	# Restore mesh transform
	if frog.frog_mesh:
		_visual_tween.tween_property(frog, "scale", _original_mesh_scale, tween_duration)
		#_visual_tween.tween_property(frog, "position", _original_mesh_pos, tween_duration)

	# Hide glow sprite
	if glow_sprite:
		_visual_tween.tween_property(glow_sprite, "scale", Vector3.ZERO, tween_duration)
		_visual_tween.tween_property(glow_sprite, "modulate:a", 0.0, tween_duration)

	await _visual_tween.finished
	if glow_sprite:
		glow_sprite.visible = false

func _recover_and_escape() -> void:
	if _is_escaping:
		return
	_is_escaping = true

	print("[StunState] Stun expired! Escaping...")
	
	if frog.attractable_area and frog.attractable_area.current_attractor:
		frog.attractable_area.stop_attraction(frog.attractable_area.current_attractor)

	# Revert shrink, hover, and glow simultaneously with animation reversal
	await _revert_stun_effects()

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

	# Ensure visual properties are reset if state exits abruptly (e.g., gets picked up)
	if _visual_tween and _visual_tween.is_running():
		_visual_tween.kill()

	if frog.frog_mesh:
		frog.frog_mesh.scale = _original_mesh_scale
		frog.frog_mesh.position = _original_mesh_pos

	if glow_sprite:
		glow_sprite.visible = false

	if homing_component:
		homing_component.stop_homing()

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
