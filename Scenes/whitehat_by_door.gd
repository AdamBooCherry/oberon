extends Node3D

@export var whitehat: CharacterBody3D
@export var interaction_area: InteractionArea
@export var dialogue_root: DialogicTimeline

func _ready() -> void:
	interaction_area.player_interaction_started.connect(_on_interaction_started)

func _on_interaction_started(_player: Player):
	Dialogic.start(dialogue_root, "STANDARD")
	
	pass
