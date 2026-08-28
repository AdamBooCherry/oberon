extends CharacterBody3D
class_name Redcap

@export_category("AI Settings")
@export var move_speed: float = 3.5
@export var chase_speed: float = 6.0

@export_group("References")
@export var state_machine: StateMachine
@export var animation_player: AnimationPlayer
@export var player_detector: PlayerDetector
@export var navigation_agent_3d: NavigationAgent3D

var last_known_player_position: Vector3 = Vector3.ZERO

func _ready() -> void:
	if player_detector:
		player_detector.player_entered.connect(_on_player_detected)
		player_detector.player_exited.connect(_on_player_lost)

	if state_machine:
		state_machine.init(self)
		print("[Redcap] State machine initialized. Starting state: ", state_machine.current_state.name if state_machine.current_state else "NONE")

func _physics_process(delta: float) -> void:
	if state_machine and state_machine.current_state:
		# Process physics-based state updates (like NavigationAgent movement)
		if state_machine.current_state.has_method("physics_update"):
			state_machine.current_state.physics_update(delta)
		else:
			state_machine.current_state.update(delta)
			
	move_and_slide()

func take_stun() -> void:
	print("[Redcap] Stun received!")
	if state_machine:
		print("[Redcap] Transitioning to SEARCHING from stun")
		state_machine.change_state("SEARCHING")

func kill_player() -> void:
	## call cutscene from signalmanager
	print("[Redcap] Killing you!!")
	pass

func _on_player_detected(player: Player) -> void:
	print("[Redcap] Player entered detector zone")
	last_known_player_position = player.global_position
	if state_machine:
		print("[Redcap] Transitioning to Alert state")
		state_machine.change_state("Alert")

func _on_player_lost(player: Player) -> void:
	print("[Redcap] Player exited detector zone")
	if player:
		last_known_player_position = player.global_position

	if state_machine and state_machine.current_state:
		print("[Redcap] Current state on player lost: ", state_machine.current_state.name)
		if state_machine.current_state.name.to_upper() == "ALERT":
			print("[Redcap] Transitioning to Searching state")
			state_machine.change_state("Searching")
