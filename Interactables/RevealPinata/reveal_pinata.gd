extends Node3D
class_name RevealPinata

signal pinata_broken
signal pinata_reset

@export var damage_rate: float = 5.0

@export_group("References")
@export var reveal_detector: RevealDetector
@export var health_component: HealthComponent
@export var loot_spawner: LootSpawner
@export var visual_node: Node3D # The mesh/visuals of the pinata itself

var is_broken: bool = false

const BREAK_EFFECT = preload("uid://dqo2wy1r43ocf")

func _ready() -> void:
	if health_component:
		health_component.health_depleted.connect(_break_pinata)
	else:
		push_error("[RevealPinata] ERROR: HealthComponent reference is missing!")

func _process(delta: float) -> void:
	if is_broken:
		return
		
	# If the reveal area is active, deal damage to our health component
	if reveal_detector and reveal_detector.current_reveal_area != null:
		if health_component:
			health_component.take_damage(damage_rate * delta)

func _break_pinata() -> void:
	if is_broken:
		return
	is_broken = true
	
	print("[RevealPinata] Pinata broken at position: ", global_position)
	
	var death_position = global_position
	var world_root = get_tree().current_scene
	
	# Play break visual effect in world space
	SceneHelper.spawn_effect("uid://dqo2wy1r43ocf", death_position, world_root)
	
	# Tell our generic loot component to spawn items in world space
	if loot_spawner:
		loot_spawner.spawn_loot(death_position)

	# Hide visuals and disable logic instead of deleting the node
	if visual_node:
		visual_node.hide()
		
	set_process(false)
	pinata_broken.emit()

func reset_pinata() -> void:
	print("[RevealPinata] Resetting pinata...")
	
	# Reset health pool back to max
	if health_component:
		health_component.reset_health() # Assumes a reset function exists on your HealthComponent, or set current_health = max_health
		
	# Restore visuals and re-enable processing
	if visual_node:
		visual_node.show()
		
	is_broken = false
	set_process(true)
	pinata_reset.emit()
