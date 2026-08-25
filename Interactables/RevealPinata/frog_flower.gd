extends Node3D
class_name FrogFlower

@export var reveal_health: float = 10.0
@export var reveal_detector: RevealDetector
@export var marker_3d: Marker3D

var all_frogs: Array[Node] 
var _closest_frog: FrogMob

var is_awake: bool = false

const BREAK_EFFECT = preload("uid://dqo2wy1r43ocf")

func _ready() -> void:
	find_frogs()

func find_frogs() -> void:
	# Fixed: Store the returned nodes into our array and cast them safely
	all_frogs = get_tree().get_nodes_in_group("FROG")

func _process(delta: float) -> void:
	# 1. Handle health depletion while sleeping (using the exact same pinata logic)
	if not is_awake:
		if reveal_detector.current_reveal_area != null:
			var damage_rate = 5.0
			reveal_health -= damage_rate * delta
			
			if reveal_health <= 0.0:
				_awaken_flower()
		return
	
	# 2. Once awake, continuously find and track the nearest frog
	_update_closest_frog()
	
	if _closest_frog and is_instance_valid(_closest_frog):
		marker_3d.look_at(_closest_frog.global_position, Vector3.UP)

func _awaken_flower() -> void:
	if is_awake:
		return
	is_awake = true
	
	print("[FrogFlowerDebug] Flower awakened!")
	
	# Play reveal visual effect via SceneHelper
	SceneHelper.spawn_effect("uid://dqo2wy1r43ocf", self.global_position, get_parent())
	
	# [SOUND HOOK] Play flower awakening / blooming sound here

func _update_closest_frog() -> void:
	if all_frogs.is_empty():
		# Refresh the list just in case new frogs spawned later
		find_frogs()
		if all_frogs.is_empty():
			return
			
	var closest_dist: float = INF
	var nearest: FrogMob = null
	
	for frog in all_frogs:
		if not is_instance_valid(frog) or not (frog is FrogMob):
			continue
			
		var dist = global_position.distance_to(frog.global_position)
		if dist < closest_dist:
			closest_dist = dist
			nearest = frog
			
	_closest_frog = nearest
