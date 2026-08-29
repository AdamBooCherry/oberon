extends State
class_name DeathState

@export var player_dad: Player
@export var animation_player: AnimationPlayer

var animation_name: String = "Dad/dying"
var death_timer: Timer

func _ready() -> void:
	death_timer = Timer.new()
	death_timer.one_shot = true
	death_timer.process_callback = Timer.TIMER_PROCESS_IDLE
	add_child(death_timer)


func enter() -> void:
	player_dad.velocity = Vector3.ZERO

	# Disable hurtbox immediately
	if player_dad.hurtbox:
		player_dad.hurtbox.set_deferred("monitoring", false)
		player_dad.hurtbox.set_deferred("monitorable", false)

	# 1. Ensure AnimationTree is active
	player_dad.movement_tree.active = true

	# 2. Swap animation and request one-shot fire
	var anim_node = player_dad.movement_tree.tree_root.get_node("OneShotAnimation")
	anim_node.animation = animation_name
	player_dad.movement_tree.set("parameters/OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

	# 3. Handle Timer safely
	if death_timer.time_left > 0.0:
		death_timer.stop()

	death_timer.start(animation_player.get_animation(animation_name).length / player_dad.movement_tree.get("parameters/TimeScale/scale"))
	await death_timer.timeout

	GameManager.emit_begin_death_sequence()
