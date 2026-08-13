extends CharacterBody3D
class_name FrogMob

@export var player_detector: Area3D
@export var animation_player: AnimationPlayer

## hide
## run away
## wander
## invisible / reveal
## stun

func _ready() -> void:
	player_detector.area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area3D):
	if area is FrogCollector:
		get_picked_up()

func get_picked_up():
## catch
## gets added to inventory/currency
	print("test")
	animation_player.play("Armature|Frog_Death")
	
	await animation_player.animation_finished
	
	InventoryManager.has_frog = true
	self.queue_free()
