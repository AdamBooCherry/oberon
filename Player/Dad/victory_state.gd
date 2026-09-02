### VICTORY STATE ###
extends State
class_name VictoryState

@export var player_dad: Player
@export var animation_player: AnimationPlayer

var animation_name: String = "Dad/insult"
var anim_timer: Timer

func _ready() -> void:
	anim_timer = Timer.new()
	anim_timer.one_shot = true
	anim_timer.process_callback = Timer.TIMER_PROCESS_IDLE
	add_child(anim_timer)


func enter() -> void:
	# 1. Ensure AnimationTree is active
	player_dad.movement_tree.active = true

	# 2. Swap animation and request one-shot fire
	var anim_node = player_dad.movement_tree.tree_root.get_node("OneShotAnimation")
	anim_node.animation = animation_name
	player_dad.movement_tree.set("parameters/OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

	print("Animation started")
	# 3. Handle Timer safely
	if anim_timer.time_left > 0.0:
		anim_timer.stop()

	anim_timer.start(animation_player.get_animation(animation_name).length / player_dad.movement_tree.get("parameters/TimeScale/scale"))
	await anim_timer.timeout
	
	print("animation finished")
	GameManager.emit_begin_round_win()
