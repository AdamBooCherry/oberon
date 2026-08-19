extends OmniLight3D

@export var glory_hand: GloryHand

func _ready() -> void:
	if glory_hand:
		# Connect the signal to a local function
		glory_hand.flame_color_changed.connect(_on_flame_color_changed)

func _on_flame_color_changed(new_color: Color) -> void:
	# Update light color automatically when GloryHand changes it
	light_color = new_color
