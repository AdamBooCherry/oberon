extends CSGSphere3D

@export var glory_hand: GloryHand

var current_flame_color: Color
var _gradient: Gradient

func _ready() -> void:
	# 1. Safely extract the Gradient resource from the material's texture
	_setup_gradient_reference()

	# 2. Connect to the GloryHand signal
	if glory_hand:
		glory_hand.flame_color_changed.connect(_on_flame_color_changed)
		# Apply initial color immediately
		apply_flame_color(glory_hand.current_flame_color)

func _setup_gradient_reference() -> void:
	# Assuming you are using a StandardMaterial3D with an Albedo Texture (GradientTexture1D/2D)
	var mat = material as StandardMaterial3D
	if mat and mat.albedo_texture is GradientTexture1D:
		# Make sure it's unique so changing it doesn't affect other objects sharing this texture
		if not mat.albedo_texture.resource_local_to_scene:
			mat.albedo_texture = mat.albedo_texture.duplicate()
		_gradient = mat.albedo_texture.gradient
	elif mat and mat.albedo_texture is GradientTexture2D:
		if not mat.albedo_texture.resource_local_to_scene:
			mat.albedo_texture = mat.albedo_texture.duplicate()
		_gradient = mat.albedo_texture.gradient

func _on_flame_color_changed(new_color: Color) -> void:
	apply_flame_color(new_color)

func apply_flame_color(new_color: Color) -> void:
	current_flame_color = new_color

	if _gradient and _gradient.get_point_count() > 0:
		# Tint the first color stop of your gradient to match the flame color
		_gradient.set_color(0, current_flame_color)
		
		# Optional: Adjust the second stop too if you want a smooth transition fade
		if _gradient.get_point_count() > 1:
			_gradient.set_color(1, current_flame_color.lerp(Color.WHITE, 0.4))
