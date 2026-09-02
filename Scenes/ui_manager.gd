extends Node
class_name UIManager

@export var result_screen: ResultScreen
@export var display_time: float = 5.0

func _ready() -> void:
	GameManager.begin_round_win.connect(_on_begin_round_win)
	GameManager.begin_round_lose.connect(_on_begin_round_lose)
	#result_screen.animate_in("Starting test!!", display_time)

func _on_begin_round_win():
	result_screen.animate_in("Nicely done!!", display_time)

func _on_begin_round_lose():
	result_screen.animate_in("A year is a long time to be away.", display_time)
