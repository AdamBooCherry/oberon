extends CanvasLayer
class_name UI

@export var frog_texture: TextureRect
@export var tween_duration: float = 0.3

var _default_frog_position: Vector2
var _active_tween: Tween

func _ready() -> void:
	InventoryManager.item_state_changed.connect(_on_item_state_changed)
	
	if frog_texture:
		# Cache its original position from the editor layout
		_default_frog_position = frog_texture.position
		
		# Start hidden immediately (snapped 300px down)
		frog_texture.position = _default_frog_position + Vector2(0, 300)
		frog_texture.visible = false
		
	# Check initial state in case the frog was already collected before UI loaded
	if InventoryManager.has_frog:
		show_frog()

func _on_item_state_changed(item_name: StringName, owned: bool):
	if item_name != "frog":
		return
		
	if owned:
		show_frog()
	else:
		hide_frog()

func show_frog() -> void:
	if not frog_texture:
		return
		
	frog_texture.visible = true
	
	if _active_tween and _active_tween.is_valid():
		_active_tween.kill()
		
	_active_tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_active_tween.tween_property(frog_texture, "position", _default_frog_position, tween_duration)

func hide_frog() -> void:
	if not frog_texture:
		return
		
	var hidden_position = _default_frog_position + Vector2(0, 300)
	
	if _active_tween and _active_tween.is_valid():
		_active_tween.kill()
		
	_active_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_active_tween.tween_property(frog_texture, "position", hidden_position, tween_duration)
	
	# Hide node entirely after tween finishes dropping it down
	_active_tween.tween_callback(func(): frog_texture.visible = false)
