extends Node3D

@export var interaction_area: InteractionArea
@export var game: DialogicTimeline
@export var exit_door: AnimationPlayer

func _ready() -> void:
	interaction_area.player_interaction_started.connect(_on_player_interact)
	Dialogic.signal_event.connect(_on_dialogic_event)

func _on_player_interact(_value):
	Dialogic.start(game,"OPEN_DOOR_START_GAME")

func _on_dialogic_event(argument: Variant):
	if argument is not String:
		return
	
	if argument == "START_GAME":
		_open_door_start_game()

func _open_door_start_game():
	interaction_area.monitoring = false
	interaction_area.monitorable = false
	exit_door.play("open")
	exit_door.play("DoorAction")
	## disable prompt
	## play animation
	## take hand of glory
	## RE Door animation
	## game start logic
	pass
