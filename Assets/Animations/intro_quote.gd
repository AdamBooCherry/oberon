extends CanvasLayer

@export var resource: CutsceneResource
@export var animation_player: AnimationPlayer

var _is_waiting_for_input: bool = false

func _ready() -> void:
	# Small delay to let Autoloads initialize cleanly on start
	await get_tree().process_frame
	start_intro()

func start_intro() -> void:
	if not CutsceneManager or not animation_player:
		return

	_is_waiting_for_input = false

	# Phase 1: Play intro quote animation via CutsceneManager
	CutsceneManager.play(resource, animation_player, _on_skip)
	await CutsceneManager.ended

	# Transition to holding state
	_is_waiting_for_input = true

func _unhandled_input(event: InputEvent) -> void:
	if not _is_waiting_for_input:
		return

	# Any key or click triggers transition out
	if event.is_pressed() and not event.is_echo():
		get_viewport().set_input_as_handled()
		_animate_out()

func _on_skip() -> void:
	# Fast-forward quote animation straight to final frame
	if animation_player and animation_player.has_animation("intro_quote"):
		var anim = animation_player.get_animation("intro_quote")
		animation_player.seek(anim.length, true)

func _animate_out() -> void:
	_is_waiting_for_input = false

	# Phase 2: Animate out using CutsceneManager so gameplay remains locked
	CutsceneManager.play(resource, animation_player)
	animation_player.play("intro_animate_out")
	
	await CutsceneManager.ended
	queue_free()
