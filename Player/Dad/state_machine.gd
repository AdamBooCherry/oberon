class_name StateMachine
extends Node

@export var initial_state: State

var current_state: State
var current_sub_state: State
var states: Dictionary = {}

func init(player_ref: Player) -> void:
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.player = player_ref
			child.parent_state_machine = self
			
			for sub_child in child.get_children():
				if sub_child is State:
					sub_child.player = player_ref
					sub_child.parent_state_machine = self
			
	if initial_state:
		initial_state.enter()
		current_state = initial_state
		print("[%s] Initialized with state: %s" % [name, initial_state.name])

func change_state(new_state_name: String) -> void:
	var target_state = states.get(new_state_name.to_lower())
	if not target_state:
		print("[%s] WARNING: State '%s' not found!" % [name, new_state_name])
		return
		
	if current_state:
		print("[%s] Exiting: %s" % [name, current_state.name])
		current_state.exit()
		
	print("[%s] Entering: %s" % [name, target_state.name])
	current_state = target_state
	current_state.enter()

func update(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func physics_update(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)
