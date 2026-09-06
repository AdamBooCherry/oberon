extends Node

## Manages background music and ambient tracks with smooth crossfading.

@export_group("References")
@export var _music_player_a: AudioStreamPlayer
@export var _music_player_b: AudioStreamPlayer
@export var _ambience_player_a: AudioStreamPlayer
@export var _ambience_player_b: AudioStreamPlayer

# Dynamic references to track active player
var _active_music_player: AudioStreamPlayer
var _active_ambience_player: AudioStreamPlayer

# Stores the target volume configured in the Inspector for each player
var _target_volumes: Dictionary = {}

func _ready() -> void:
	_active_music_player = _music_player_a
	_active_ambience_player = _ambience_player_a
	
	# Cache initial volume settings from the inspector
	print_debug("[MusicManager] --- Caching Player Target Volumes ---")
	_cache_player_volume(_music_player_a, "MusicPlayerA")
	_cache_player_volume(_music_player_b, "MusicPlayerB")
	_cache_player_volume(_ambience_player_a, "AmbiencePlayerA")
	_cache_player_volume(_ambience_player_b, "AmbiencePlayerB")


func _cache_player_volume(player: AudioStreamPlayer, player_name: String) -> void:
	if player:
		_target_volumes[player] = player.volume_db
		print_debug("[MusicManager] Cached ", player_name, " target volume_db: ", player.volume_db)
	else:
		print_debug("[MusicManager] WARNING: ", player_name, " reference is NULL in inspector!")


# ==============================================================================
# MUSIC CONTROL
# ==============================================================================

func play_music(stream: AudioStream, fade_duration: float = 1.0) -> void:
	if _active_music_player.stream == stream and _active_music_player.playing:
		return
		
	var incoming_player: AudioStreamPlayer = _get_inactive_player(_active_music_player, _music_player_a, _music_player_b)
	incoming_player.stream = stream
	
	_crossfade(incoming_player, _active_music_player, fade_duration)
	_active_music_player = incoming_player


func stop_music(fade_duration: float = 1.0) -> void:
	_fade_out_and_stop(_active_music_player, fade_duration)


# ==============================================================================
# AMBIENCE CONTROL
# ==============================================================================

func play_ambience(stream: AudioStream, fade_duration: float = 1.0) -> void:
	if _active_ambience_player.stream == stream and _active_ambience_player.playing:
		return
		
	var incoming_player: AudioStreamPlayer = _get_inactive_player(_active_ambience_player, _ambience_player_a, _ambience_player_b)
	incoming_player.stream = stream
	
	_crossfade(incoming_player, _active_ambience_player, fade_duration)
	_active_ambience_player = incoming_player


func stop_ambience(fade_duration: float = 1.0) -> void:
	_fade_out_and_stop(_active_ambience_player, fade_duration)


# ==============================================================================
# CORE FADING & UTILITY
# ==============================================================================

func _crossfade(incoming: AudioStreamPlayer, outgoing: AudioStreamPlayer, duration: float) -> void:
	if not incoming in _target_volumes:
		print_debug("[MusicManager] WARNING: Incoming player ", incoming.name, " missing from _target_volumes dictionary!")

	# Retrieve cached volume limit for the incoming player
	var target_db: float = _target_volumes.get(incoming, 0.0)
	print_debug("[MusicManager] Crossfading to ", incoming.name, " | Duration: ", duration, "s | Target DB: ", target_db)

	if duration <= 0.0:
		outgoing.stop()
		incoming.volume_db = target_db
		incoming.play()
		return

	incoming.volume_db = -80.0
	incoming.play()

	var tween: Tween = create_tween().set_parallel(true)
	
	# Fade in incoming track to its designated target_db
	tween.tween_property(incoming, "volume_db", target_db, duration)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_OUT)
		
	# Print active volume midway/end to verify step execution
	tween.tween_method(func(v: float): pass, 0.0, 1.0, duration).finished.connect(
		func(): print_debug("[MusicManager] Finished crossfade to ", incoming.name, " | Final volume_db: ", incoming.volume_db)
	)

	# Fade out outgoing track
	if outgoing.playing:
		tween.tween_property(outgoing, "volume_db", -80.0, duration)\
			.set_trans(Tween.TRANS_CUBIC)\
			.set_ease(Tween.EASE_IN)
		tween.chain().tween_callback(outgoing.stop)


func _fade_out_and_stop(player: AudioStreamPlayer, duration: float) -> void:
	if not player.playing:
		return
		
	if duration <= 0.0:
		player.stop()
		return

	var tween: Tween = create_tween()
	tween.tween_property(player, "volume_db", -80.0, duration)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_IN)
	tween.tween_callback(player.stop)


func _get_inactive_player(active: AudioStreamPlayer, a: AudioStreamPlayer, b: AudioStreamPlayer) -> AudioStreamPlayer:
	return b if active == a else a
