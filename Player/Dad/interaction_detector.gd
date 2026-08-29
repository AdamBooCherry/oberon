extends Area3D
class_name InteractionDetector

@export var player: Player

var current_area: InteractionArea = null
var is_enabled: bool = true

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _unhandled_input(event: InputEvent) -> void:
	# 1. Block interaction inputs during dialogue or when disabled
	if not is_enabled or current_area == null or Dialogic.current_timeline != null:
		return
		
	if event.is_action_pressed("interact"):
		current_area.interact(player)
		# Handled stops input from propagating to other UI elements
		get_viewport().set_input_as_handled()

func _on_area_entered(area: Area3D) -> void:
	if area is InteractionArea:
		current_area = area
		# Don't show prompt icons if dialogue is running
		if is_enabled and Dialogic.current_timeline == null:
			current_area.show_icon()

func _on_area_exited(area: Area3D) -> void:
	if area is InteractionArea and area == current_area:
		if is_enabled:
			current_area.hide_icon()
		current_area = null

# Call this from your Player state machine (e.g. disable during DeathState/WakeupState)
func set_detector_enabled(enabled: bool) -> void:
	is_enabled = enabled
	
	if not is_enabled and current_area:
		current_area.hide_icon()
	elif is_enabled and current_area and Dialogic.current_timeline == null:
		current_area.show_icon()
