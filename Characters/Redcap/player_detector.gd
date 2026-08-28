extends Area3D
class_name PlayerDetector

signal player_entered(player: Player)
signal player_exited(player: Player)

var player_is_in_area: bool = false
var current_player: Player = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D) -> void:
	if body is not Player:
		return
	
	player_is_in_area = true
	current_player = body
	player_entered.emit(body)

func _on_body_exited(body: Node3D) -> void:
	if body is not Player or body != current_player:
		return
		
	player_is_in_area = false
	current_player = null
	player_exited.emit(body)
