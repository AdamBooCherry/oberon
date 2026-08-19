class_name State
extends Node

var player: Node # Changed from 'Player' to 'Node' so it accepts FrogMob, Player, or anything else!
var parent_state_machine: StateMachine

func enter() -> void:
	pass

func exit() -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass
