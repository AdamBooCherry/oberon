extends Area3D
class_name RevealDetector

signal reveal_entered(rev_area: RevealArea)
signal reveal_exited(rev_area: RevealArea)

#var is_in_reveal_area: bool = false
var current_reveal_area: RevealArea

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _on_area_entered(area: Area3D):
	if area is RevealArea:
		reveal_entered.emit(area)
		#is_in_reveal_area = true
		current_reveal_area = area

func _on_area_exited(area: Area3D):
	if area is RevealArea:
		reveal_exited.emit(area)
		#is_in_reveal_area = false
		current_reveal_area = null
