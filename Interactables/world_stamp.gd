extends Marker3D

@export var player_detector: PlayerDetector
@export var mesh_root: Node3D
@export var collect: AudioStreamPlayer3D
@export var nuh_uh: AudioStreamPlayer3D

var _is_collected: bool = false
var _wiggle_tween: Tween = null

func _ready() -> void:
	if player_detector:
		player_detector.player_entered.connect(_on_player_entered)

func _on_player_entered(_player: Player) -> void:
	if _is_collected:
		return

	# If player already has postage, reject; otherwise collect
	if InventoryManager.has_postage:
		_play_nuh_uh()
	else:
		_collect()

func _collect() -> void:

	_is_collected = true
	InventoryManager.has_postage = true
	
	if collect:
		collect.play()

	SceneHelper.spawn_effect("uid://brvyfw32spq8", self.global_position, get_parent())

	if mesh_root:
		# Cancel active wiggle animation if it's currently running
		if _wiggle_tween and _wiggle_tween.is_running():
			_wiggle_tween.kill()

		var tween = create_tween().set_parallel(true)
		tween.tween_property(mesh_root, "scale", Vector3.ZERO, 0.35)\
			.set_trans(Tween.TRANS_BACK)\
			.set_ease(Tween.EASE_IN)
		
		# Free node once audio completes (or scale animation finishes if no sound)
		if collect and collect.stream:
			collect.finished.connect(queue_free)
		else:
			tween.finished.connect(queue_free)

func _play_nuh_uh() -> void:
	if nuh_uh and not nuh_uh.playing:
		nuh_uh.play()

	if mesh_root:
		# Don't restart wiggle if already playing
		if _wiggle_tween and _wiggle_tween.is_running():
			return

		var base_rot = mesh_root.rotation
		_wiggle_tween = create_tween()
		
		# Quick side-to-side rotation wiggle along Y-axis
		_wiggle_tween.tween_property(mesh_root, "rotation:y", base_rot.y + deg_to_rad(15.0), 0.06)
		_wiggle_tween.tween_property(mesh_root, "rotation:y", base_rot.y - deg_to_rad(15.0), 0.08)
		_wiggle_tween.tween_property(mesh_root, "rotation:y", base_rot.y + deg_to_rad(10.0), 0.06)
		_wiggle_tween.tween_property(mesh_root, "rotation:y", base_rot.y, 0.06)
