### WISP_PANIC.gd ###
extends State

@export var wisp: WilloWisp

func enter() -> void:
	# Stop regular navigation when homing/attraction takes over movement
	wisp.velocity = Vector3.ZERO
	if wisp.omni_light_3d:
		wisp.omni_light_3d.light_energy = 5.0 # Flare up light intensity during panic
		wisp.omni_light_3d.light_color = Color.RED
func exit() -> void:
	if wisp.omni_light_3d:
		wisp.omni_light_3d.light_energy = 1.0
		wisp.omni_light_3d.light_color = Color.WHITE
