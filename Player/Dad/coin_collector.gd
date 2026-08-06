extends Area3D
class_name CoinCollector

@export var pickup: AudioStreamPlayer

func on_pickup():
	print("pickup!x")
	pickup.play()
