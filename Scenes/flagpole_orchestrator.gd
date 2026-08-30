extends Node3D

enum ScoreTarget { PLAYER, OBERON }

@export var target: ScoreTarget = ScoreTarget.OBERON
@export var flagpoles: Array[MeshInstance3D] = []

func _ready() -> void:
	if GameManager:
		match target:
			ScoreTarget.PLAYER:
				GameManager.player_score_changed.connect(_on_score_changed)
				_on_score_changed(GameManager.player_score)
			ScoreTarget.OBERON:
				GameManager.oberon_score_changed.connect(_on_score_changed)
				_on_score_changed(GameManager.oberon_score)


func _on_score_changed(score: int) -> void:
	var target_name:String = ScoreTarget.keys()[target]
	print("%s score changed to %d" % [target_name, score])

	for i in range(flagpoles.size()):
		if flagpoles[i]:
			flagpoles[i].visible = (i < score)
