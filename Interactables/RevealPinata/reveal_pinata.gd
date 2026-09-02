extends Node3D
class_name RevealPinata

signal pinata_broken
signal pinata_reset

@export_group("References")
@export var reveal_detector: RevealDetector

#@export var health_component: HealthComponent
@export var loot_spawner: LootSpawner
@export var visual_node: Node3D # The mesh/visuals of the pinata itself

var is_broken: bool = false

const BREAK_EFFECT = preload("uid://dqo2wy1r43ocf")

func _ready() -> void:
	GameManager.day_number_changed.connect(_on_day_number_changed)
	
	if reveal_detector.health_component:
		reveal_detector.health_component.health_depleted.connect(_break_pinata)

func _break_pinata() -> void:
	if is_broken:
		return
	is_broken = true
	
	var death_position = global_position
	var world_root = get_tree().current_scene
	
	# Play break visual effect in world space
	SceneHelper.spawn_effect("uid://dqo2wy1r43ocf", death_position, world_root)
	
	# Tell our generic loot component to spawn items in world space
	if loot_spawner:
		loot_spawner.spawn_loot(death_position)

	# Hide visuals and disable collision/detection logic instead of deleting the node
	if visual_node:
		visual_node.hide()
		
	if reveal_detector:
		reveal_detector.monitoring = false
		
	pinata_broken.emit()

func reset_pinata() -> void:
	#print("[RevealPinata] Resetting pinata...")
	
	# Reset health pool back to max
	if reveal_detector.health_component:
		reveal_detector.health_component.reset_health()
		
	# Restore visuals and re-enable detection
	if visual_node:
		visual_node.show()
		
	if reveal_detector:
		reveal_detector.monitoring = true
		
	is_broken = false
	pinata_reset.emit()

func _on_day_number_changed(_value):
	reset_pinata()
