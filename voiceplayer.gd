extends AudioStreamPlayer3D

# Array to store the voice lines
var voice_lines: Array[AudioStream] = []
var current_index := 0

func _ready():
	# Load your 4 voice lines
	voice_lines = [
		preload("res://Voices/VoiceA/wa.wav"),
		preload("res://Voices/VoiceA/ne.wav"),
		preload("res://Voices/VoiceA/ki.wav"),
		preload("res://Voices/VoiceA/du.wav")
	]

func play_next_voice_line():
	# Set the next stream and play it
	stream = voice_lines[current_index]
	play()

	# Move to the next index, wrap around at the end
	current_index = (current_index + 1) % voice_lines.size()
