extends Node

signal started(resource: CutsceneResource)
signal ended(resource: CutsceneResource)
signal skipped(resource: CutsceneResource)

var current_resource: CutsceneResource = null
var _current_anim_player: AnimationPlayer = null
var _skip_callback: Callable

# Public accessor for GameStateManager and other callers
var is_active: bool:
	get: return current_resource != null

# Registry to look up CutsceneBox nodes by ID
var _registry: Dictionary = {}

# --- Registry Management ---

func register_cutscene(id: StringName, box: Node) -> void:
	if id == &"":
		return
	if _registry.has(id):
		push_warning("CutsceneManager: Overwriting registered cutscene for ID '%s'" % id)
	_registry[id] = box

func unregister_cutscene(id: StringName) -> void:
	if _registry.has(id):
		_registry.erase(id)

func get_cutscene(id: StringName) -> Node:
	return _registry.get(id, null)

# --- Playback Logic ---

func play_by_id(id: StringName) -> void:
	var box = get_cutscene(id)
	if box and box.has_method("start_cutscene"):
		box.start_cutscene()
	else:
		push_error("CutsceneManager: Failed to play cutscene with ID '%s'. Node not found or invalid." % id)

func play(resource: CutsceneResource, anim_player: AnimationPlayer, skip_callback: Callable = Callable()) -> void:
	if current_resource != null:
		return

	current_resource = resource
	_current_anim_player = anim_player
	_skip_callback = skip_callback

	started.emit(current_resource)

	if _current_anim_player:
		if not _current_anim_player.animation_finished.is_connected(_on_anim_finished):
			_current_anim_player.animation_finished.connect(_on_anim_finished, CONNECT_ONE_SHOT)
		_current_anim_player.play(current_resource.animation_name)

func _unhandled_input(event: InputEvent) -> void:
	if current_resource == null or not current_resource.is_skippable:
		return

	# Ignore mouse motion (movement, hover, spatial relative inputs)
	if event is InputEventMouseMotion:
		return

	# Trigger skip on any key, mouse button, joypad button, or screen touch
	if event.is_pressed() and not event.is_echo():
		get_viewport().set_input_as_handled()
		skip()

func skip() -> void:
	if current_resource == null:
		return

	if _current_anim_player and _current_anim_player.is_playing():
		_current_anim_player.stop()

	if _skip_callback.is_valid():
		_skip_callback.call()

	skipped.emit(current_resource)
	_finish()

func _on_anim_finished(_anim_name: String) -> void:
	_finish()

func _finish() -> void:
	var finished_res = current_resource
	current_resource = null
	_current_anim_player = null
	_skip_callback = Callable()

	ended.emit(finished_res)
