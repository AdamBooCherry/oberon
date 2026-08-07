extends Area3D
class_name InteractionArea

signal player_interaction_started

@export var interaction_icon: Sprite3D
@export var fade_duration: float = 0.2

var _player_is_in_area: bool = false
var _current_tween: Tween

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	_hide_icon()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		player_interaction_started.emit()
		pass

func _on_area_entered(area: Area3D) -> void:
	if area is InteractionDetector:
		_show_icon()
		_player_is_in_area = true

func _on_area_exited(area: Area3D) -> void:
	if area is InteractionDetector:
		_hide_icon()
		_player_is_in_area = false

func _show_icon() -> void:
	if _current_tween and _current_tween.is_valid():
		_current_tween.kill()
		
	interaction_icon.visible = true
	
	_current_tween = create_tween()
	_current_tween.tween_property(interaction_icon, "scale", Vector3.ONE, fade_duration)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)

func _hide_icon() -> void:
	if _current_tween and _current_tween.is_valid():
		_current_tween.kill()
		
	_current_tween = create_tween()
	_current_tween.tween_property(interaction_icon, "scale", Vector3(0.01,0.01,0.01), fade_duration)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN)
		
	_current_tween.tween_callback(func():
		if interaction_icon:
			interaction_icon.visible = false
	)
