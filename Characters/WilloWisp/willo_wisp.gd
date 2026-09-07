extends CharacterBody3D
class_name WilloWisp

@export_group("Movement Settings")
@export var float_height: float = 1.2
@export var float_bob_amplitude: float = 0.15
@export var float_bob_speed: float = 3.0

@export_group("Combat Settings")
@export var collected_damage: float = 10.0

@export_group("References")
@export var mesh: Node3D
@export var omni_light_3d: OmniLight3D
@export var navigation_agent_3d: NavigationAgent3D
@export var player_detector: PlayerDetector
@export var attractable_area: AttractableArea
@export var state_machine: StateMachine

var _bob_timer: float = 0.0

func _ready() -> void:
	print("[%s] Wisp ready. Initializing signals..." % name)
	if attractable_area:
		attractable_area.attraction_started.connect(_on_attraction_started)
		attractable_area.attraction_stopped.connect(_on_attraction_stopped)
		attractable_area.collected.connect(_on_collected)

func _process(delta: float) -> void:
	_apply_visual_float(delta)
	state_machine.update(delta)

func _physics_process(delta: float) -> void:
	state_machine.physics_update(delta)

## Smoothly bobs the visual mesh up and down above ground position
func _apply_visual_float(delta: float) -> void:
	if not mesh:
		return
		
	_bob_timer += delta * float_bob_speed
	var target_y: float = float_height + (sin(_bob_timer) * float_bob_amplitude)
	mesh.position.y = lerp(mesh.position.y, target_y, delta * 5.0)


# ==============================================================================
# ATTRACTABLE AREA HANDLERS
# ==============================================================================

func _on_attraction_started(attractor: AttractionArea) -> void:
	print("[%s] Attraction STARTED by: %s" % [name, attractor.name if attractor else "Unknown"])
	if state_machine:
		state_machine.change_state("WispPanic")


func _on_attraction_stopped(attractor: AttractionArea) -> void:
	print("[%s] Attraction STOPPED by: %s" % [name, attractor.name if attractor else "Unknown"])
	if state_machine:
		state_machine.change_state("WispWander")


func _on_collected(collector: AttractionArea) -> void:
	print("[%s] COLLECTED by player! Applying %.1f damage." % [name, collected_damage])
	if collector and collector.player and collector.player.health_component:
		collector.player.health_component.take_damage(collected_damage)
	queue_free()
