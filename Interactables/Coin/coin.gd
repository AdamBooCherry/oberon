extends Node3D
class_name Coin

@export var coin_value: int = 1
@export var attractable_area: AttractableArea

func _ready() -> void:
	if attractable_area:
		attractable_area.collected.connect(_on_collected)

func _on_collected(_collector: AttractionArea) -> void:
	InventoryManager.increment_currency(coin_value)
