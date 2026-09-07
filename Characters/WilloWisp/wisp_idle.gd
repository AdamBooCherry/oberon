### WISP_IDLE.GD ###
extends State

@export var wisp: WilloWisp
@export var idle_time_range: Vector2 = Vector2(2.0, 4.0)

var _timer: float = 0.0
var _current_idle_time: float = 0.0

func enter() -> void:
	_timer = 0.0
	_current_idle_time = randf_range(idle_time_range.x, idle_time_range.y)
	#print(_current_idle_time)
	wisp.velocity = Vector3.ZERO

func update(delta: float) -> void:
	_timer += delta
	if _timer >= _current_idle_time:
		#print("timer finished")
		wisp.state_machine.change_state("WispWander")
