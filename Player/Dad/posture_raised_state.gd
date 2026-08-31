class_name PostureRaisedState
extends State

@export var raised_collector_radius: float = 5.0
@export var default_collector_radius: float = 0.2

@export_category("Growth & Range Settings")
@export var growth_rate: float = 1.0     # How fast it grows per second while holding
@export var shrink_duration: float = 1.0 # Takes 1 second to shrink back down on exit
@export var gold_color: Color = Color(1.0, 0.84, 0.0) # Standard gold tint
@export var max_omni_range: float = 5.0  # Maximum range the light reaches at full growth
@export var default_omni_range: float = 0.5 # Default starting range (tweak as needed)

@export_category("Light Sphere Scale")
@export var min_sphere_scale: Vector3 = Vector3.ZERO
@export var max_sphere_scale: Vector3 = Vector3.ONE

@export_category("Torch Ring Scale")
@export var min_ring_scale: Vector3 = Vector3.ZERO
@export var max_ring_scale: Vector3 = Vector3.ONE

@export_group("References")
@export var glory_hand: GloryHand
@export var raise_light: OmniLight3D
@export var coin_collector_shape: CollisionShape3D
@export var torch_ring: Sprite3D

var current_radius: float = 0.2
var active_tween: Tween # Keep track of the tween so we can kill it if interrupted

func _ready() -> void:
	exit()

func enter() -> void:
	# 1. If an exit tween was still running, kill it instantly so it can't snap things back
	if active_tween and active_tween.is_valid():
		active_tween.kill()

	glory_hand.switch_pose(-.95)

	player.current_posture = 1.0
	glory_hand.set_flame_color(gold_color)
	
	# 2. Capture current actual values so we grow smoothly from *wherever* we currently are
	if coin_collector_shape and coin_collector_shape.shape is SphereShape3D:
		if not coin_collector_shape.shape.resource_local_to_scene:
			coin_collector_shape.shape = coin_collector_shape.shape.duplicate()
		current_radius = coin_collector_shape.shape.radius

func update(delta: float) -> void:
	player.current_posture = 1.0
	
	var is_sprinting = Input.is_action_pressed("sprint")
	
	# If letting go of the button or trying to sprint, exit state
	if is_sprinting or not Input.is_action_pressed("raise_hog"):
		parent_state_machine.change_state("PostureNeutralState")
		return

	# Gradually grow radius every frame while holding the button
	if coin_collector_shape and coin_collector_shape.shape is SphereShape3D:
		current_radius = move_toward(current_radius, raised_collector_radius, growth_rate * delta)
		coin_collector_shape.shape.radius = current_radius
		
	var progress = (current_radius - default_collector_radius) / (raised_collector_radius - default_collector_radius)
	progress = clamp(progress, 0.0, 1.0)
	
	if raise_light:
		# Scale omni_range proportionally to the growth progress
		raise_light.omni_range = lerp(default_omni_range, max_omni_range, progress)
		# Smoothly shift the light's color toward gold as it charges up
		raise_light.light_color = glory_hand.default_flame_color.lerp(gold_color, progress)

	# Scale the glory_hand's light sphere up toward Vector3.ONE based on progress
	if glory_hand and glory_hand.light_sphere:
		glory_hand.light_sphere.scale = min_sphere_scale.lerp(max_sphere_scale, progress)

	# Scale the torch_ring up along with the growth progress
	if torch_ring:
		torch_ring.scale = min_ring_scale.lerp(max_ring_scale, progress)

func exit() -> void:
	glory_hand.set_flame_color(glory_hand.default_flame_color)
	
	# Kill any prior running tween before starting a new exit tween
	if active_tween and active_tween.is_valid():
		active_tween.kill()
		
	# Use a tween to smoothly shrink back radius, range, scale, and color when letting go
	active_tween = create_tween().set_parallel(true)
	
	if coin_collector_shape and coin_collector_shape.shape is SphereShape3D:
		active_tween.tween_property(coin_collector_shape.shape, "radius", default_collector_radius, shrink_duration)
		
	if raise_light:
		active_tween.tween_property(raise_light, "omni_range", default_omni_range, shrink_duration)
		active_tween.tween_property(raise_light, "light_color", glory_hand.default_flame_color, shrink_duration)
		
	if glory_hand and glory_hand.light_sphere:
		active_tween.tween_property(glory_hand.light_sphere, "scale", min_sphere_scale, shrink_duration)
		
	if torch_ring:
		active_tween.tween_property(torch_ring, "scale", min_ring_scale, shrink_duration)
