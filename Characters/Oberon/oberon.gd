extends Node3D
class_name Oberon

@export var animation_player: AnimationPlayer

func _ready() -> void:
	animation_player.play("Float")

#func play_animation(name: String):
	#animation_player.play(name, 1)
