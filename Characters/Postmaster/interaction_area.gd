extends Area3D
class_name InteractionArea

signal player_interaction_started(player: Player)

@export var interaction_icon: Sprite3D
@export var fade_duration: float = 0.2

var _current_tween: Tween

func _ready() -> void:
	if interaction_icon:
		interaction_icon.scale = Vector3(0.01, 0.01, 0.01)
		interaction_icon.visible = false

# Called directly by the InteractionDetector when the interact key is pressed
func interact(player: Player) -> void:
	player_interaction_started.emit(player)

func show_icon() -> void:
	if not interaction_icon:
		return
		
	if _current_tween and _current_tween.is_valid():
		_current_tween.kill()
		
	interaction_icon.visible = true
	
	_current_tween = create_tween()
	_current_tween.tween_property(interaction_icon, "scale", Vector3.ONE, fade_duration)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_OUT)

func hide_icon() -> void:
	if not interaction_icon:
		return
		
	if _current_tween and _current_tween.is_valid():
		_current_tween.kill()
		
	_current_tween = create_tween()
	_current_tween.tween_property(interaction_icon, "scale", Vector3(0.01, 0.01, 0.01), fade_duration)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_IN)
		
	_current_tween.tween_callback(func():
		if interaction_icon:
			interaction_icon.visible = false
	)
