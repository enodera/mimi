# MusicManager.gd
extends Node

@onready var music_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var sfx_player: AudioStreamPlayer = $AudioStreamPlayer2

var current_track: AudioStream = null

func _ready():
	print("MusicManager is ready. Music player: ", music_player)

func play_music(stream: AudioStream):
	if current_track != stream:
		music_player.stream = stream
		music_player.play()
		current_track = stream

func play_sfx(stream: AudioStream):
	sfx_player.stream = stream
	sfx_player.stop()
	sfx_player.play()

func stop_music():
	music_player.stop()
	current_track = null
	
