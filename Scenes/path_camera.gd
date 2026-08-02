extends Path3D
class_name PathCamera

@export var fixed_camera: FixedCamera
@export var path_follow_3d: PathFollow3D
var player: Player

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")

func _physics_process(delta: float) -> void:
	var player_position = player.global_position
	path_follow_3d.progress = curve.get_closest_offset(player_position)
