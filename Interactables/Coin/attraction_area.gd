extends Area3D
class_name AttractionArea

@export var pickup_sound: AudioStreamPlayer

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _on_area_entered(area: Area3D) -> void:
	if area is AttractableArea:
		area.start_attraction(self)

func _on_area_exited(area: Area3D) -> void:
	if area is AttractableArea:
		area.stop_attraction(self)

func notify_collected(_item: Node) -> void:
	if pickup_sound and not pickup_sound.playing:
		pickup_sound.play()
