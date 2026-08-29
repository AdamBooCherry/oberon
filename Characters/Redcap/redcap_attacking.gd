## REDCAP ATTACKING ##
extends State

@export var redcap: Redcap
@export var attack_duration: float = 1.2
@export var rotation_speed: float = 5.0

var _timer: float = 0.0
var _has_attacked: bool = false

func enter() -> void:
	_timer = 0.0
	_has_attacked = false

	if not redcap:
		return

	# Freeze movement during attack windup/swing
	redcap.velocity = Vector3.ZERO

	# Ensure hook/hitbox is clean before starting
	if redcap.hook:
		redcap.hook.turn_off_hitbox()

	# Play attack animation (AnimationPlayer track handles turning hook hitbox on/off)
	if redcap.animation_player:
		redcap.animation_player.play("redcap_animations/attack_combo_01")

func physics_update(delta: float) -> void:
	if not redcap:
		return

	_timer += delta

	# Track toward player position during early windup frames before locking in
	if _timer < 0.25 and redcap.last_known_player_position != Vector3.ZERO:
		var dir = (redcap.last_known_player_position - redcap.global_position).normalized()
		dir.y = 0
		if dir.length_squared() > 0.01:
			var target_rot = atan2(-dir.x, -dir.z)
			redcap.rotation.y = lerp_angle(redcap.rotation.y, target_rot, rotation_speed * delta)

	# State recovery transition once animation completes
	if _timer >= attack_duration:
		if parent_state_machine:
			# Fall back to SEARCHING if player escaped during attack, or ALERT/HUNTING to continue chase
			parent_state_machine.change_state("HUNTING")

func exit() -> void:
	# Safety cleanup in case state is interrupted mid-swing (e.g., by stun)
	if redcap and redcap.hook:
		redcap.hook.turn_off_hitbox()
