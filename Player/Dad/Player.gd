extends CharacterBody3D
class_name Player

@export_category("Movement Settings")
@export var move_speed: float = 3.0
@export var run_speed: float = 5.0
@export var backward_speed: float = 2.5
@export var turn_speed: float = 2.75
@export var gravity: float = 9.8

@export_category("Animation Settings")
@export var default_blend_time := 0.5
@export var blend_smooth_speed: float = 5.0 # Speed at which animation blends interpolate

@export_category("Posture Speed Multipliers")
@export var lowered_speed_multiplier: float = 0.8
@export var raised_speed_multiplier: float = 0.6

@export_group("References")
@export var animation_player: AnimationPlayer
@export var movement_tree: AnimationTree
@export var movement_state_machine: StateMachine
@export var action_state_machine: StateMachine
@export var hurtbox: Hurtbox
@export var health_component: HealthComponent

# Context state flags
var has_torch: bool = true # Set by game logic
var current_posture: float = 0.5 # 0.5 = Neutral, 1.0 = Raised, 0.0 = Lowered/Crouched

# Internal tracking for smooth blending
var current_blend_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
	if movement_tree:
		movement_tree.active = true
	if movement_state_machine:
		movement_state_machine.init(self)
	if action_state_machine:
		action_state_machine.init(self)

	# Wire up HealthComponent & Hurtbox logic
	if health_component:
		health_component.health_depleted.connect(_on_health_depleted)
		health_component.health_changed.connect(_on_health_changed)

	if hurtbox and health_component:
		hurtbox.health_component = health_component

func _process(delta: float) -> void:
	if movement_state_machine:
		movement_state_machine.update(delta)
	if action_state_machine:
		action_state_machine.update(delta)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	if movement_state_machine:
		movement_state_machine.physics_update(delta)
	if action_state_machine:
		action_state_machine.physics_update(delta)
		
	move_and_slide()

func handle_turn(delta: float) -> void:
	var turn_input := Input.get_axis("turn_right", "turn_left")
	rotate_y(turn_input * turn_speed * delta)

# --- Damage & Health Integration ---

func take_damage(amount: float) -> void:
	if health_component:
		health_component.take_damage(amount)

func _on_health_changed(current: float, max_hp: float) -> void:
	print("[Player] Health updated: ", current, "/", max_hp)

func _on_health_depleted() -> void:
	print("[Player] Health depleted! Triggering death logic...")
	
	# Interrupt action state machine so actions stop executing
	if action_state_machine:
		action_state_machine.change_state("PostureNeutralState") # or disable/pause it
		
	# Transition movement state machine to lock physics & input
	if movement_state_machine:
		movement_state_machine.change_state("DeathState")

# --- Animation Tree Controls ---

func update_animation_blend(x_speed: float, y_posture: float, delta: float) -> void:
	if not movement_tree:
		print("[Player] ERROR: movement_tree reference is NULL!")
		return
	
	var target_blend := Vector2(x_speed, y_posture)
	current_blend_pos = current_blend_pos.move_toward(target_blend, blend_smooth_speed * delta)
	
	# Set blend positions
	movement_tree.set("parameters/TorchBlend/blend_position", current_blend_pos)
	movement_tree.set("parameters/UnarmedBlend/blend_position", current_blend_pos)
	
	# Equipment weight check
	var torch_weight = 1.0 if has_torch else 0.0
	movement_tree.set("parameters/RaiseLower/blend_amount", torch_weight)
