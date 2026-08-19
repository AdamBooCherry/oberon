class_name PostureRaisedState
extends State

@export var glory_hand: GloryHand
@export var raise_light: OmniLight3D
@export var coin_collector_shape: CollisionShape3D
@export var raised_collector_radius: float = 5.0
@export var default_collector_radius: float = 0.2

@export_category("Growth & Color Settings")
@export var growth_rate: float = 1.0     # How fast it grows per second while holding
@export var shrink_duration: float = 1.0 # Takes 1 second to shrink back down on exit
@export var gold_color: Color = Color(1.0, 0.84, 0.0) # Standard gold tint
#@export var default_color: Color = Color.WHITE

var current_radius: float = 0.2
var max_light_energy: float = 3.0

func enter() -> void:
	player.current_posture = 1.0
	glory_hand.set_flame_color(gold_color)
	
	# 1. Ensure shape is unique so it doesn't affect other instances
	if coin_collector_shape and coin_collector_shape.shape is SphereShape3D:
		if not coin_collector_shape.shape.resource_local_to_scene:
			coin_collector_shape.shape = coin_collector_shape.shape.duplicate()
		current_radius = coin_collector_shape.shape.radius

func update(delta: float) -> void:
	player.current_posture = 1.0
	
	var move_input := Input.get_axis("back", "forward")
	var is_running = Input.is_action_pressed("sprint") and move_input != 0.0
	
	# If letting go of the button or trying to run, exit state
	if is_running or not Input.is_action_pressed("raise_hog"):
		parent_state_machine.change_state("PostureNeutralState")
		return

	# Gradually grow radius and light energy every frame while holding the button
	if coin_collector_shape and coin_collector_shape.shape is SphereShape3D:
		current_radius = move_toward(current_radius, raised_collector_radius, growth_rate * delta)
		coin_collector_shape.shape.radius = current_radius
		
	if raise_light:
		var progress = (current_radius - default_collector_radius) / (raised_collector_radius - default_collector_radius)
		progress = clamp(progress, 0.0, 1.0)
		
		raise_light.light_energy = lerp(0.0, max_light_energy, progress)
		# Smoothly shift the light's color toward gold as it charges up
		raise_light.light_color = glory_hand.default_flame_color.lerp(gold_color, progress)

func exit() -> void:
	glory_hand.set_flame_color(glory_hand.default_flame_color)
	# Use a tween to smoothly shrink back and revert color when letting go
	var tween = create_tween().set_parallel(true)
	
	if coin_collector_shape and coin_collector_shape.shape is SphereShape3D:
		tween.tween_property(coin_collector_shape.shape, "radius", default_collector_radius, shrink_duration)
		
	if raise_light:
		tween.tween_property(raise_light, "light_energy", 0.0, shrink_duration)
		tween.tween_property(raise_light, "light_color", glory_hand.default_flame_color, shrink_duration)
