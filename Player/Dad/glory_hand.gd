class_name GloryHand
extends Node3D

signal flame_color_changed(new_color: Color)

@export var default_flame_color: Color = Color.DEEP_PINK
@export var blend_speed: float = 8.0 # How fast the hand transitions between poses

@export_group("Wiggle Settings")
@export var wiggle_amount: float = 0.1  # How far the wiggle shifts the blend position (keep it small!)
@export var wiggle_speed: float = 6.0   # How fast the wiggle oscillates

@export_group("References")
@export var animation_player: AnimationPlayer
@export var animation_tree: AnimationTree
@export var light_sphere: CSGSphere3D

var current_flame_color: Color
var target_hand_pose: float = 0.0
var current_hand_pose: float = 0.0
var _time_accumulator: float = 0.0

func _ready() -> void:
	light_sphere.scale = Vector3.ZERO
	current_flame_color = default_flame_color
	flame_color_changed.emit(current_flame_color)
	
	if animation_tree:
		animation_tree.active = true

func _process(delta: float) -> void:
	# 1. Smoothly glide current_pose toward target_pose every frame
	if current_hand_pose != target_hand_pose:
		current_hand_pose = move_toward(current_hand_pose, target_hand_pose, blend_speed * delta)
		
	# 2. Calculate organic wiggle using a sine wave
	_time_accumulator += delta * wiggle_speed
	var wiggle_offset = sin(_time_accumulator) * wiggle_amount
	
	# Optional: Scale down the wiggle when close to neutral (pose 0) so it rests quieter, 
	# or keep it uniform if you want it constantly trembling.
	var final_pose = current_hand_pose + wiggle_offset
	
	# 3. Update the 1D Blend Space parameter path
	animation_tree.set("parameters/blend_position", final_pose)

func set_flame_color(new_color: Color) -> void:
	if current_flame_color == new_color:
		return
		
	current_flame_color = new_color
	flame_color_changed.emit(current_flame_color)

func switch_pose(pose: float) -> void:
	## 0 is neutral, -1 is for raised, 1 is for lowered
	target_hand_pose = pose
