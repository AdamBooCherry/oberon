extends Camera3D
class_name FixedCamera

@export var follow_player: bool = false
@export var trigger_area: CameraTriggerArea

var player: Player

func _ready() -> void:
	trigger_area.top_level = true
	
	trigger_area.area_entered.connect(_on_trigger_area_entered)

func _on_trigger_area_entered(area: Area3D):
	#print("trigger", area)
	if player == null:
		player = get_tree().get_first_node_in_group("Player")
		
	if area is CameraActivator:
		self.make_current()
		CameraManager.stop_off_camera_timer()

func _physics_process(_delta: float) -> void:
	if follow_player and player:
		look_at(player.global_position)
