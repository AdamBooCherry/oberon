extends State
class_name DeathState

@export var player_dad: Player
@export var animation_player: AnimationPlayer
@export var default_death_cutscene: CutsceneBox
@export var animation_name: StringName = &"Dad/dying"

func enter() -> void:
	if not player_dad:
		return

	player_dad.velocity = Vector3.ZERO

	# Disable hurtbox interaction immediately
	if player_dad.hurtbox:
		player_dad.hurtbox.set_deferred("monitoring", false)
		player_dad.hurtbox.set_deferred("monitorable", false)

	# Fire death animation on the AnimationTree
	if player_dad.movement_tree:
		player_dad.movement_tree.active = true
		var anim_node = player_dad.movement_tree.tree_root.get_node("OneShotAnimation")
		if anim_node:
			anim_node.animation = animation_name
			player_dad.movement_tree.set("parameters/OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

	# 1. Check for hazard/enemy-specific CutsceneBox
	var target_cutscene: CutsceneBox = null
	
	if player_dad.last_damage_source:
		var custom = player_dad.last_damage_source.get("death_cutscene")
		if custom is CutsceneBox:
			target_cutscene = custom

	# 2. Fall back to default CutsceneBox
	if not target_cutscene:
		target_cutscene = default_death_cutscene

	# 3. Execute cutscene or run fallback timer
	if target_cutscene:
		target_cutscene.play_cutscene()
	else:
		_run_fallback_timer()

func _run_fallback_timer() -> void:
	var anim_length: float = 1.5
	
	if animation_player and animation_player.has_animation(animation_name):
		var time_scale: float = 1.0
		if player_dad.movement_tree:
			time_scale = player_dad.movement_tree.get("parameters/TimeScale/scale")
		
		# Prevent division by zero
		if time_scale > 0.0:
			anim_length = animation_player.get_animation(animation_name).length / time_scale

	get_tree().create_timer(anim_length).timeout.connect(
		func(): GameManager.emit_begin_round_lose(),
		CONNECT_ONE_SHOT
	)
