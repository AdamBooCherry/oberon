### HIT STATE ###
extends State

@export var player_dad: Player
@export var animation_player: AnimationPlayer
@export var stun_duration: float = 0.35
var animation_name: String = "Dad/hit_react"
var _stun_timer: float = 0.0


func enter() -> void:
	_stun_timer = stun_duration
	player_dad.velocity = Vector3.ZERO
	player_dad.hurtbox.is_invulnerable = true

	# 1. Ensure AnimationTree is active
	player_dad.movement_tree.active = true

	# 2. Swap animation and request one-shot fire
	var anim_node = player_dad.movement_tree.tree_root.get_node("OneShotAnimation")
	anim_node.animation = animation_name
	player_dad.movement_tree.set("parameters/OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func physics_update(delta: float) -> void:
	_stun_timer -= delta
	if _stun_timer <= 0.0:

		player_dad.action_state_machine.change_state("PostureNeutralState")


func exit() -> void:
	player_dad.hurtbox.is_invulnerable = false
