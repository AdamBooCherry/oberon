## Attach this script to your Melee Weapon root node ##
extends Node3D
class_name MeleeWeapon

@export var hitbox: Hitbox

func _ready() -> void:
	# Ensure the hitbox starts disabled when spawned or equipped
	turn_off_hitbox()

## Called via AnimationPlayer Method Track during active swing frames
func turn_on_hitbox() -> void:
	if hitbox:
		hitbox.enable()
		#print("Hitbox enabled!")
		
## Called via AnimationPlayer Method Track when active swing frames end
func turn_off_hitbox() -> void:
	if hitbox:
		hitbox.disable()
		#print("Hitbox disabled!")
