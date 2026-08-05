extends Node3D
class_name Coin

@export var area_3d: Area3D

func _ready() -> void:
	area_3d.area_entered.connect(_on_area_entered)
	

func _on_area_entered(area: Area3D):
	## if area is coin_collector:
	fly_to_player()
	pass

func fly_to_player():
	## lerp to coin_collector
	## upon reaching destination, delete self
	#InventoryManager.curren
	pass
