extends Marker3D
class_name WorldCoin

@export var starting_coin: Coin
@export var coin_scene: PackedScene = preload("uid://b4lro5g46q76v")

# Track active instance in runtime
var _active_coin: Coin = null

func _ready() -> void:
	GameManager.day_number_changed.connect(_on_day_changed)
	_active_coin = starting_coin
	#_spawn_coin()

func _on_day_changed(_day_value: int) -> void:
	# If coin was collected or destroyed, spawn a fresh one
	if not is_instance_valid(_active_coin):
		_spawn_coin()

func _spawn_coin() -> void:
	if not coin_scene:
		push_warning("[CoinSpawner] Missing coin_scene PackedScene on %s" % name)
		return

	var new_coin = coin_scene.instantiate() as Coin
	if new_coin:
		new_coin.global_transform = global_transform
		
		add_child.call_deferred(new_coin)
		_active_coin = new_coin
