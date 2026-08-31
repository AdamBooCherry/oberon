extends CharacterBody3D
class_name Redcap

@export var disable_idiot: bool = false

@export_category("AI Settings")
@export var move_speed: float = 3.5
@export var chase_speed: float = 6.0

@export_group("References")
@export var state_machine: StateMachine
@export var animation_player: AnimationPlayer
@export var player_detector: PlayerDetector
@export var navigation_agent_3d: NavigationAgent3D
@export var hook: MeleeWeapon
@export var reveal_detector: RevealDetector
@export var health_component: HealthComponent

var tracked_player: Player = null
var last_known_player_position: Vector3 = Vector3.ZERO

func _ready() -> void:
	# Detector signal wiring
	if player_detector:
		player_detector.player_entered.connect(_on_player_detected)
		player_detector.player_exited.connect(_on_player_lost)

	# Health & Hurtbox wiring
	if health_component:
		health_component.health_depleted.connect(_on_health_depleted)

	if reveal_detector and health_component:
		reveal_detector.health_component = health_component

	# State machine initialization
	if state_machine:
		state_machine.init(self)
		#print("[Redcap] State machine initialized. Starting state: ", state_machine.current_state.name if state_machine.current_state else "NONE")

func _physics_process(delta: float) -> void:
	if disable_idiot:
		return
		
	# Continuously track live player position when inside detection zone
	if is_instance_valid(tracked_player):
		last_known_player_position = tracked_player.global_position

	if state_machine and state_machine.current_state:
		if state_machine.current_state.has_method("physics_update"):
			state_machine.current_state.physics_update(delta)
		else:
			state_machine.current_state.update(delta)

	move_and_slide()

# --- Health & Damage Handling ---

func take_damage(amount: float) -> void:
	if health_component:
		health_component.take_damage(amount)

func take_stun() -> void:
	#print("[Redcap] Stun received!")
	if state_machine:
		state_machine.change_state("WANDERING")

func _on_health_depleted() -> void:
	#print("[Redcap] Health depleted!")
	if state_machine:
		state_machine.change_state("STUNNED")

# --- Detection Signals ---

func _on_player_detected(player: Player) -> void:
	#print("[Redcap] Player entered detector zone")
	tracked_player = player
	last_known_player_position = player.global_position

	if state_machine:
		state_machine.change_state("ALERT")

func _on_player_lost(player: Player) -> void:
	#print("[Redcap] Player exited detector zone")
	if player:
		last_known_player_position = player.global_position
	tracked_player = null

	if state_machine and state_machine.current_state:
		var active_state = state_machine.current_state.name.to_upper()
		# If losing line of sight during ALERT or HUNTING, drop to WANDERING
		if active_state in ["ALERT", "HUNTING"]:
			state_machine.change_state("WANDERING")
