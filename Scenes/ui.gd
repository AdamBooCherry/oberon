class_name UI
extends CanvasLayer

@export var tween_duration: float = 0.4
@export var slide_offset_y: float = -300.0 # Move 300px up

@export_group("References")
@export var frog_texture: TextureRect
@export var stamp_texture: TextureRect

var _items: Dictionary = {}

func _ready() -> void:
	InventoryManager.item_state_changed.connect(_on_item_state_changed)

	_register_item(&"frog", frog_texture, InventoryManager.has_frog)
	_register_item(&"postage", stamp_texture, InventoryManager.has_postage)


func _register_item(item_name: StringName, node: TextureRect, is_owned: bool) -> void:
	if not node:
		print("[UI] WARNING: Node for '%s' is not assigned!" % item_name)
		return

	# Wait 1 frame so containers settle initial positions
	await get_tree().process_frame

	var default_pos := node.position
	var hidden_pos := default_pos + Vector2(0, slide_offset_y)

	_items[item_name] = {
		"node": node,
		"default_pos": default_pos,
		"hidden_pos": hidden_pos,
		"tween": null
	}

	# Shift up off-screen immediately
	node.position = hidden_pos

	if is_owned:
		show_item(item_name)


func _on_item_state_changed(item_name: StringName, owned: bool) -> void:
	if owned:
		show_item(item_name)
	else:
		hide_item(item_name)


# --- Generic UI Controls ---

func show_item(item_name: StringName) -> void:
	var item: Dictionary = _items.get(item_name, {})
	if item.is_empty():
		return

	_kill_tween(item)

	# Tween back down to default container position
	item.tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	item.tween.tween_property(item.node, "position", item.default_pos, tween_duration)


func hide_item(item_name: StringName) -> void:
	var item: Dictionary = _items.get(item_name, {})
	if item.is_empty():
		return

	_kill_tween(item)

	# Move 300px up off-screen
	item.tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	item.tween.tween_property(item.node, "position", item.hidden_pos, tween_duration)


func _kill_tween(item: Dictionary) -> void:
	if item.tween and item.tween.is_valid():
		item.tween.kill()
