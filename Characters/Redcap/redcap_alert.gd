## REDCAP ALERT ##
extends State

@export var redcap: Redcap
@export var alert_duration: float = 0.8
@export var rotation_speed: float = 12.0

var _timer: float = 0.0

func enter() -> void:
	EnvironmentManager.change_state(EnvironmentManager.EnvironmentState.CHASE)

	_timer = 0.0

	if not redcap:
		return

	# Stop all movement as Redcap acts surprised
	redcap.velocity = Vector3.ZERO

	# Play the reaction/alert animation
	if redcap.animation_player:
		redcap.animation_player.play("redcap_animations/alert")

func physics_update(delta: float) -> void:
	if not redcap:
		return

	_timer += delta

	# Snap attention toward where the player was detected
	if redcap.last_known_player_position != Vector3.ZERO:
		var dir = (redcap.last_known_player_position - redcap.global_position).normalized()
		dir.y = 0
		
		if dir.length_squared() > 0.01:
			var target_rot = atan2(-dir.x, -dir.z)
			redcap.rotation.y = lerp_angle(redcap.rotation.y, target_rot, rotation_speed * delta)

	# Once the reaction finishes, start the chase
	if _timer >= alert_duration:
		if parent_state_machine:
			parent_state_machine.change_state("HUNTING")
