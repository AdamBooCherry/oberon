extends State
class_name FrogHideState

@export var frog: FrogMob
@export var hide_duration: float = 3.0

var _timer: float = 0.0

func enter() -> void:
	print("[HideState] ENTERED. Hiding / Invisible.")
	_timer = 0.0
	
	if frog:
		frog.velocity = Vector3.ZERO
		# Make the frog mesh invisible (disable visibility)
		#if frog.animation_player and frog.animation_player.has_animation("Armature|Frog_Hide"):
			#frog.animation_player.play("Armature|Frog_Hide")
			
		# Hide the visual mesh instance(s)
		for child in frog.find_children("*", "MeshInstance3D"):
			child.visible = false

func update(delta: float) -> void:
	if not frog or frog.is_stunned:
		return
		
	_timer += delta
	if _timer >= hide_duration:
		print("[HideState] Revealing! Switching to Idle.")
		# Reveal mesh before changing state
		for child in frog.find_children("*", "MeshInstance3D"):
			child.visible = true
		parent_state_machine.change_state("FrogIdleState")

func exit() -> void:
	# Ensure mesh is visible when leaving state just in case
	if frog:
		for child in frog.find_children("*", "MeshInstance3D"):
			child.visible = true
