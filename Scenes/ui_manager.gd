extends Node
class_name UIManager

@export var result_screen: ResultScreen
@export var display_time: float = 5.0

func _ready() -> void:
	GameManager.begin_victory_sequence.connect(_on_begin_victory_sequence)
	GameManager.begin_death_sequence.connect(_on_begin_death_sequence)
	#result_screen.animate_in("Starting test!!", display_time)

func _on_begin_victory_sequence():
	result_screen.animate_in("Nicely done!!", display_time)

func _on_begin_death_sequence():
	result_screen.animate_in("A year is a long time to be away.", display_time)
