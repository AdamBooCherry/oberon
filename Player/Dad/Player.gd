extends CharacterBody3D
class_name Player

@export_category("Movement Settings")
@export var move_speed: float = 2.0
@export var run_speed: float = 3.5
@export var backward_speed: float = 1.0
@export var turn_speed: float = 2.5
@export var gravity: float = 9.8

@export_category("Animation Settings")
@export var default_blend_time := 0.5

@export_group("References")
@export var animation_player: AnimationPlayer

func _physics_process(delta: float) -> void:
	# 1. Apply Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	handle_turn(delta)
	handle_movement(delta)
	move_and_slide()
	
	# 2. Update Animations after physics/velocity is resolved
	#handle_animations()


func handle_turn(delta: float) -> void:
	var turn_input := Input.get_axis("turn_right", "turn_left")
	rotate_y(turn_input * turn_speed * delta)


func handle_movement(delta: float) -> void:
	if Input.is_action_pressed("sprint") and Input.get_axis("forward", "back") < 0:
		handle_run(delta)
	else:
		handle_walk(delta)


func handle_walk(delta: float) -> void:
	var move_input := Input.get_axis("forward", "back")
	var current_speed := move_speed if move_input < 0 else backward_speed
	_apply_horizontal_velocity(move_input * current_speed)


func handle_run(delta: float) -> void:
	var move_input := Input.get_axis("forward", "back")
	_apply_horizontal_velocity(move_input * run_speed)


func _apply_horizontal_velocity(speed_vector_magnitude: float) -> void:
	var forward_dir := -transform.basis.z
	var target_velocity := forward_dir * speed_vector_magnitude

	velocity.x = target_velocity.x
	velocity.z = target_velocity.z


func handle_animations() -> void:
	if not animation_player:
		return

	var move_input := Input.get_axis("forward", "back")
	var turn_input := Input.get_axis("turn_right", "turn_left")
	
	var target_anim := "idle"

	# Prioritize linear locomotion
	if move_input < 0:
		if Input.is_action_pressed("sprint"):
			target_anim = "standard_run"
		else:
			target_anim = "walking"
	elif move_input > 0:
		# Playing "walking" backward or a dedicated "walk_back" clip
		target_anim = "walking"
	elif turn_input != 0:
		# Turning in place
		target_anim = "left_turn_90" if turn_input > 0 else "right_turn_90"

	# Play animation if it's not already running
	if animation_player.current_animation != target_anim:
		animation_player.play(target_anim, default_blend_time)
		
	# Reverse animation playback rate when walking backward
	if move_input > 0:
		animation_player.speed_scale = -1.0
	else:
		animation_player.speed_scale = 1.0
