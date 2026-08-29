extends Area3D
class_name InteractionArea

# Pass the player node along with the signal
signal player_interaction_started(player: Player)

@export var interaction_icon: Sprite3D
@export var fade_duration: float = 0.2

var _player_is_in_area: bool = false
var _current_player: Player = null
var _current_tween: Tween

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	
	if interaction_icon:
		interaction_icon.scale = Vector3(0.01, 0.01, 0.01)
		interaction_icon.visible = false

func _unhandled_input(event: InputEvent) -> void:
	# Only allow interaction if the player is inside and valid
	if _player_is_in_area and event.is_action_pressed("interact"):
		player_interaction_started.emit(_current_player)

func _on_area_entered(area: Area3D) -> void:
	if area is InteractionDetector:
		_current_player = area.player
		_player_is_in_area = true
		_show_icon()

func _on_area_exited(area: Area3D) -> void:
	if area is InteractionDetector:
		_player_is_in_area = false
		_current_player = null
		_hide_icon()

func _show_icon() -> void:
	if not interaction_icon:
		return
		
	if _current_tween and _current_tween.is_valid():
		_current_tween.kill()
		
	interaction_icon.visible = true
	
	_current_tween = create_tween()
	_current_tween.tween_property(interaction_icon, "scale", Vector3.ONE, fade_duration)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_OUT)

func _hide_icon() -> void:
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
