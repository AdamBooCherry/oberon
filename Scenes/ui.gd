class_name UI
extends CanvasLayer

@export var frog_texture: TextureRect
@export var tween_duration: float = 0.3
@export var slide_offset: Vector2 = Vector2(0, -300) # Distance/direction offset when hidden (e.g., up off-screen)

var _default_frog_position: Vector2
var _hidden_frog_position: Vector2
var _active_tween: Tween

func _ready() -> void:
	InventoryManager.item_state_changed.connect(_on_item_state_changed)
	
	if not frog_texture:
		print("[UI] WARNING: frog_texture is not assigned in the inspector!")
		return
		
	# Cache positions
	_default_frog_position = frog_texture.position
	_hidden_frog_position = _default_frog_position + slide_offset
	
	# Start hidden off-screen
	frog_texture.position = _hidden_frog_position
	frog_texture.visible = false
		
	# Check initial state in case the frog was already collected before UI loaded
	if InventoryManager.has_frog:
		show_frog()

func _on_item_state_changed(item_name: StringName, owned: bool) -> void:
	if item_name != &"frog":
		return
		
	if owned:
		show_frog()
	else:
		hide_frog()

func show_frog() -> void:
	if not frog_texture:
		return
		
	frog_texture.visible = true
	_kill_active_tween()
	
	_active_tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_active_tween.tween_property(frog_texture, "position", _default_frog_position, tween_duration)

func hide_frog() -> void:
	if not frog_texture:
		return
		
	_kill_active_tween()
	
	_active_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_active_tween.tween_property(frog_texture, "position", _hidden_frog_position, tween_duration)
	_active_tween.tween_callback(func(): frog_texture.visible = false)

func _kill_active_tween() -> void:
	if _active_tween and _active_tween.is_valid():
		_active_tween.kill()
