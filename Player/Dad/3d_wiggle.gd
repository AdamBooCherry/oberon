extends Node3D
class_name Wiggle3D

@export var enabled: bool = true

@export_category("Position")
@export var position_amplitude: Vector3 = Vector3.ZERO
@export var position_frequency: float = 1.0

@export_category("Rotation (Degrees)")
@export var rotation_amplitude: Vector3 = Vector3.ZERO
@export var rotation_frequency: float = 1.0

@export_category("Scale")
@export var scale_amplitude: Vector3 = Vector3.ZERO
@export var scale_frequency: float = 1.0

var _noise: FastNoiseLite
var _time: float = 0.0

# Store the initial transform so we oscillate around the starting point
var _base_position: Vector3
var _base_rotation: Vector3
var _base_scale: Vector3

func _ready() -> void:
	# Save the starting state
	_base_position = position
	_base_rotation = rotation
	_base_scale = scale
	
	# Initialize Simplex Noise
	_noise = FastNoiseLite.new()
	_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	_noise.seed = randi() # Random seed so multiple wiggle nodes don't sync up

func _process(delta: float) -> void:
	if not enabled:
		return
		
	_time += delta
	
	# --- POSITION ---
	if position_amplitude != Vector3.ZERO:
		# We add large arbitrary offsets to Y and Z so the axes don't move in a perfect diagonal line
		var px = _noise.get_noise_1d(_time * position_frequency * 100.0)
		var py = _noise.get_noise_1d(_time * position_frequency * 100.0 + 1000.0)
		var pz = _noise.get_noise_1d(_time * position_frequency * 100.0 + 2000.0)
		
		position = _base_position + (Vector3(px, py, pz) * position_amplitude)

	# --- ROTATION ---
	if rotation_amplitude != Vector3.ZERO:
		var rx = _noise.get_noise_1d(_time * rotation_frequency * 100.0 + 3000.0)
		var ry = _noise.get_noise_1d(_time * rotation_frequency * 100.0 + 4000.0)
		var rz = _noise.get_noise_1d(_time * rotation_frequency * 100.0 + 5000.0)
		
		# Convert the noise value (-1.0 to 1.0) * degree amplitude into radians
		var rot_offset = Vector3(rx, ry, rz) * rotation_amplitude
		rotation = _base_rotation + Vector3(deg_to_rad(rot_offset.x), deg_to_rad(rot_offset.y), deg_to_rad(rot_offset.z))

	# --- SCALE ---
	if scale_amplitude != Vector3.ZERO:
		var sx = _noise.get_noise_1d(_time * scale_frequency * 100.0 + 6000.0)
		var sy = _noise.get_noise_1d(_time * scale_frequency * 100.0 + 7000.0)
		var sz = _noise.get_noise_1d(_time * scale_frequency * 100.0 + 8000.0)
		
		scale = _base_scale + (Vector3(sx, sy, sz) * scale_amplitude)
