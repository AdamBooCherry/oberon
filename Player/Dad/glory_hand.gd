extends Node3D
class_name GloryHand

# Define a signal that broadcasts the new color whenever it changes
signal flame_color_changed(new_color: Color)

@export var default_flame_color: Color = Color.DEEP_PINK

@export_group("References")
@export var animation_player: AnimationPlayer

var current_flame_color: Color

func _ready() -> void:
	current_flame_color = default_flame_color
	# Emit the initial color on startup so listeners catch it
	flame_color_changed.emit(current_flame_color)

func set_flame_color(new_color: Color) -> void:
	if current_flame_color == new_color:
		return
		
	# PRINT STACK TRACE / CALLER
	print("GloryHand color changed to: ", new_color, " by caller: ", Engine.get_frames_drawn())
	
	current_flame_color = new_color
	flame_color_changed.emit(current_flame_color)
