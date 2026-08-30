extends Node
class_name HealthComponent

signal health_depleted
signal health_changed(current_health: float, max_health: float)
signal damage_taken(amount: float)
signal healed(amount: float)

@export var max_health: float = 10.0
var current_health: float

func _ready() -> void:
	current_health = max_health

func take_damage(amount: float) -> void:
	if current_health <= 0.0 or amount <= 0.0:
		return
		
	var actual_damage := minf(current_health, amount)
	current_health = maxf(0.0, current_health - amount)
	
	damage_taken.emit(actual_damage)
	health_changed.emit(current_health, max_health)
	
	if current_health <= 0.0:
		health_depleted.emit()

func heal(amount: float) -> void:
	if current_health <= 0.0 or amount <= 0.0:
		return
		
	var actual_heal := minf(max_health - current_health, amount)
	if actual_heal <= 0.0:
		return
		
	current_health = minf(max_health, current_health + amount)
	
	healed.emit(actual_heal)
	health_changed.emit(current_health, max_health)

func reset_health() -> void:
	current_health = max_health
	health_changed.emit(current_health, max_health)
