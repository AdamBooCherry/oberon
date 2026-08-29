extends Area3D
class_name RevealDetector

signal reveal_entered(rev_area: RevealArea)
signal reveal_exited(rev_area: RevealArea)

@export var health_component: HealthComponent
@export var damage_per_second: float = 10.0

var active_reveal_areas: Array[RevealArea] = []

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _process(delta: float) -> void:
	if active_reveal_areas.is_empty() or not health_component:
		return

	# Calculate damage scaled by number of overlapping reveal zones (e.g. multiple lights)
	var total_damage = damage_per_second * active_reveal_areas.size() * delta
	health_component.take_damage(total_damage)

func _on_area_entered(area: Area3D) -> void:
	if area is RevealArea:
		if not active_reveal_areas.has(area):
			active_reveal_areas.append(area)
			reveal_entered.emit(area)

func _on_area_exited(area: Area3D) -> void:
	if area is RevealArea:
		if active_reveal_areas.has(area):
			active_reveal_areas.erase(area)
			reveal_exited.emit(area)

func is_in_light() -> bool:
	return not active_reveal_areas.is_empty()
