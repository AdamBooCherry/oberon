extends CanvasLayer
class_name ResultScreen

signal sequence_finished

@export_group("References")
@export var panel_container: Control
@export var message_label: Label
@export var player_score_markers: Array[TextureRect] = []
@export var oberon_score_markers: Array[TextureRect] = []

@export_group("Animation Settings")
@export var fade_duration: float = 0.4

func _ready() -> void:
	visible = false
	if panel_container:
		panel_container.modulate.a = 0.0
		panel_container.scale = Vector2(0.9, 0.9)
	
	# Re-evaluate whenever score updates
	if GameManager:
		GameManager.player_score_changed.connect(update_score_display)
		GameManager.oberon_score_changed.connect(update_score_display)

	update_score_display(0)

func assign_message(new_text: String) -> void:
	if message_label:
		message_label.text = new_text

func update_score_display(_value: int) -> void:
	var player_score = GameManager.player_score
	var oberon_score = GameManager.oberon_score

	# Evaluate Player Score Markers
	for i in range(player_score_markers.size()):
		var marker = player_score_markers[i]
		if marker:
			var should_be_visible = (i < player_score)
			marker.visible = should_be_visible
			print_debug("[ResultScreen] Player Marker [", i, "] -> Node: ", marker.name, " | Set Visible: ", should_be_visible)
		else:
			print_debug("[ResultScreen] ERROR: Player Marker at index ", i, " is NULL in Inspector!")

	# Evaluate Oberon Score Markers
	for i in range(oberon_score_markers.size()):
		var marker = oberon_score_markers[i]
		if marker:
			var should_be_visible = (i < oberon_score)
			marker.visible = should_be_visible
			print_debug("[ResultScreen] Oberon Marker [", i, "] -> Node: ", marker.name, " | Set Visible: ", should_be_visible)
		else:
			print_debug("[ResultScreen] ERROR: Oberon Marker at index ", i, " is NULL in Inspector!")

func animate_in(message: String = "", display_duration: float = 5.0) -> void:
	assign_message(message)

	#print_debug("[ResultScreen] animate_in called with message: '", message, "'")
	#update_score_display()
	visible = true

	if panel_container:
		panel_container.pivot_offset = panel_container.size / 2.0
		var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(panel_container, "modulate:a", 1.0, fade_duration)
		tween.tween_property(panel_container, "scale", Vector2.ONE, fade_duration)
		await tween.finished

	# Wait on screen for the specified duration before auto-dismissing
	if display_duration > 0.0:
		await get_tree().create_timer(display_duration).timeout

	await animate_out()
	sequence_finished.emit()

func animate_out() -> void:
	if not panel_container:
		visible = false
		return

	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(panel_container, "modulate:a", 0.0, fade_duration)
	tween.tween_property(panel_container, "scale", Vector2(0.9, 0.9), fade_duration)

	await tween.finished
	visible = false
