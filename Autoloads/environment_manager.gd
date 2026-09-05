### ENVIRONMENT MANAGER ###
extends Node

enum EnvironmentState {
	SAFE,          # Default / Peaceful environment
	INVESTIGATING, # Redcap investigating / searching position
	CHASE,         # Redcap sees player / actively chasing
	DEATH          # Player caught / death sequence
}

signal environment_changed(new_state: EnvironmentState, old_state: EnvironmentState)

var current_state: EnvironmentState = EnvironmentState.SAFE

# State Machine Transition Rules
# Defines which states are allowed to transition to which target states
const TRANSITION_RULES: Dictionary = {
	EnvironmentState.SAFE: [
		EnvironmentState.INVESTIGATING,
		EnvironmentState.CHASE, # Direct ambush
		EnvironmentState.DEATH
	],
	EnvironmentState.INVESTIGATING: [
		EnvironmentState.SAFE,  # De-escalates if player hides / redcap gives up
		EnvironmentState.CHASE, # Escalates if redcap spots player
		EnvironmentState.DEATH
	],
	EnvironmentState.CHASE: [
		EnvironmentState.INVESTIGATING, # De-escalates to search if player breaks line of sight
		EnvironmentState.DEATH          # Escalates if caught
	],
	EnvironmentState.DEATH: [
		EnvironmentState.SAFE # Reset on respawn / round restart
	]
}

## Attempt to transition to a new environment state. Returns true if valid.
func change_state(new_state: EnvironmentState) -> bool:
	if current_state == new_state:
		#print("[EnvironmentManager] State is already: %s" % EnvironmentState.keys()[current_state])
		return false
		
	# Check if transition is permitted by rules
	if _can_transition(current_state, new_state):
		var old_state = current_state
		current_state = new_state
		
		#print("[EnvironmentManager] State changed: %s -> %s" % [
			#EnvironmentState.keys()[old_state],
			#EnvironmentState.keys()[current_state]
		#])
		
		environment_changed.emit(current_state, old_state)
		return true
	
	print("[EnvironmentManager] Invalid transition blocked: %s -> %s" % [
		EnvironmentState.keys()[current_state],
		EnvironmentState.keys()[new_state]
	])
	
	push_warning("EnvironmentManager: Invalid transition requested from %s to %s" % [
		EnvironmentState.keys()[current_state],
		EnvironmentState.keys()[new_state]
	])
	return false

func _can_transition(from_state: EnvironmentState, to_state: EnvironmentState) -> bool:
	return TRANSITION_RULES.has(from_state) and to_state in TRANSITION_RULES[from_state]

# Helper convenience triggers
func trigger_safe() -> void:
	change_state(EnvironmentState.SAFE)

func trigger_investigation() -> void:
	change_state(EnvironmentState.INVESTIGATING)

func trigger_chase() -> void:
	change_state(EnvironmentState.CHASE)

func trigger_death() -> void:
	change_state(EnvironmentState.DEATH)
