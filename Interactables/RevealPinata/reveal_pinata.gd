extends Node3D
class_name RevealPinata

signal pinata_broken
signal pinata_reset

@export var max_health: float = 10.0:
	set(val):
		max_health = val
		if reveal_target:
			reveal_target.set_max_health(val)

@export_group("References")
@export var reveal_target: RevealTarget
@export var loot_spawner: LootSpawner
@export var visual_node: Node3D

var is_broken: bool = false

const BREAK_EFFECT_UID = "uid://dqo2wy1r43ocf"

func _ready() -> void:
	GameManager.day_number_changed.connect(reset_pinata)

	if reveal_target:
		reveal_target.set_max_health(max_health)
		reveal_target.target_depleted.connect(_on_target_depleted)

func _on_target_depleted() -> void:
	if is_broken:
		return
	is_broken = true

	# Hide visuals and let target disable its own detection
	if visual_node: visual_node.hide()
	if reveal_target: reveal_target.disable_detection()

	# World effect & loot
	SceneHelper.spawn_effect(BREAK_EFFECT_UID, global_position, get_tree().current_scene)
	if loot_spawner: loot_spawner.spawn_loot(global_position)

	pinata_broken.emit()

func reset_pinata(_arg = null) -> void:
	is_broken = false

	if visual_node: visual_node.show()
	if reveal_target: reveal_target.reset_target()

	pinata_reset.emit()
