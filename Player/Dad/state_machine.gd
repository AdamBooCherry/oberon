class_name StateMachine
extends Node

@export var initial_state: State

var current_state: State
var current_sub_state: State
var states: Dictionary = {}

signal state_changed(state: State)

func _ready() -> void:
	# Wait for the parent actor to finish its own _ready before initializing states
	await get_parent().ready
	_init_state_machine()

func _init_state_machine() -> void:
	var actor = get_parent()
	states.clear()
	
	for child in get_children():
		if child is State:
			var key = child.name.to_lower()
			states[key] = child
			child.player = actor
			child.parent_state_machine = self
			
			# Also register without "state" suffix if node is named e.g. "WispIdleState"
			if key.ends_with("state"):
				states[key.trim_suffix("state")] = child
			
			for sub_child in child.get_children():
				if sub_child is State:
					sub_child.player = actor
					sub_child.parent_state_machine = self

	if initial_state:
		current_state = initial_state
		current_state.enter()
		
	#print_debug("[%s] StateMachine initialized for '%s' with states: %s" % [name, actor.name, states.keys()])

func change_state(new_state_name: String) -> void:
	var target_state = states.get(new_state_name.to_lower())
	if not target_state:
		push_warning("[%s] WARNING: State '%s' not found!" % [name, new_state_name])
		return
		
	if current_state:
		current_state.exit()
		
	current_state = target_state
	current_state.enter()
	state_changed.emit(current_state)

func update(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func physics_update(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)
