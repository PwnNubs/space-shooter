extends Node2D

var _explosions_this_frame := 0

func _process(_delta: float) -> void:
	#AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Explosions"), min(_explosions_this_frame, 8))
	_explosions_this_frame = 0

func _kill_it(audio_player: AudioStreamPlayer) -> void:
	audio_player.queue_free()

# To Do add priority levels for sounds that are more important
func request_play_audio(audio_stream: AudioStream) -> void:
	_explosions_this_frame += 1
	if _explosions_this_frame < 16:
		var audio_player := AudioStreamPlayer.new()
		audio_player.stream = audio_stream
		audio_player.pitch_scale = randf_range(0.9, 1.1)
		audio_player.bus = "Explosions"
		add_child(audio_player)
		audio_player.play()
		audio_player.finished.connect(_kill_it.bind(audio_player))
