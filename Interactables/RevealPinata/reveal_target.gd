extends Node3D
class_name RevealTarget

# Signals for external listeners (e.g., Pinata, LootSpawner, UI)
signal target_revealed(area: RevealArea)
signal target_hidden
signal target_depleted

@export_group("References")
@export var reveal_detector: RevealDetector
@export var health_component: HealthComponent

@export_group("Continuous Effects")
@export var reveal_sparks: CPUParticles3D
@export var reveal_noise: AudioStreamPlayer3D

@export_group("Burst Effects")
@export var pop_flash: Sprite3D
@export var pop_noise: AudioStreamPlayer3D

func _ready() -> void:
	stop_continuous_effects()
	_reset_pop_flash()

	if reveal_detector:
		reveal_detector.reveal_entered.connect(_on_reveal_entered)
		reveal_detector.reveal_exited.connect(_on_reveal_exited)

	if health_component:
		health_component.health_depleted.connect(_on_health_depleted)

func set_max_health(value: float) -> void:
	if health_component:
		health_component.max_health = value
		health_component.current_health = value

func disable_detection() -> void:
	if reveal_detector:
		reveal_detector.monitoring = false

func enable_detection() -> void:
	if reveal_detector:
		reveal_detector.monitoring = true

func _on_reveal_entered(area: RevealArea) -> void:
	if health_component and health_component.current_health <= 0.0:
		return

	if reveal_sparks:
		reveal_sparks.emitting = true
	if reveal_noise and not reveal_noise.playing:
		reveal_noise.play()

	target_revealed.emit(area)

func _on_reveal_exited(_area: RevealArea) -> void:
	if reveal_detector and not reveal_detector.is_in_light():
		stop_continuous_effects()
		target_hidden.emit()

func _on_health_depleted() -> void:
	stop_continuous_effects()
	play_pop_animation()
	target_depleted.emit()

func stop_continuous_effects() -> void:
	if reveal_sparks:
		reveal_sparks.emitting = false
	if reveal_noise:
		reveal_noise.stop()

func play_pop_animation() -> void:
	if pop_noise:
		pop_noise.play()

	if pop_flash:
		pop_flash.show()
		pop_flash.scale = Vector3.ZERO

		var tween = create_tween()
		tween.tween_property(pop_flash, "scale", Vector3.ONE, 0.125).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(pop_flash, "scale", Vector3.ZERO, 0.125).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tween.tween_callback(pop_flash.hide)

func reset_target() -> void:
	_reset_pop_flash()
	enable_detection()
	
	if health_component:
		health_component.reset_health()

	if reveal_detector and reveal_detector.is_in_light():
		if reveal_sparks:
			reveal_sparks.emitting = true
		if reveal_noise and not reveal_noise.playing:
			reveal_noise.play()
		target_revealed.emit(null)
	else:
		stop_continuous_effects()

func _reset_pop_flash() -> void:
	if pop_flash:
		pop_flash.scale = Vector3.ZERO
		pop_flash.hide()
