extends Node2D
class_name VoiceLines

@export var loss_lines : Array[VoiceLine]
@onready var stream_player : AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var voiceline_text_area : Label = $Sprite2D/Label
@onready var animation_player : AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	visible = false
	get_tree().create_timer(5).timeout.connect(func():
		play_loss_line())

func play_loss_line():
	_play(_get_random_from(loss_lines))


func _get_random_from(array : Array[VoiceLine]) -> VoiceLine:
	return array.pick_random()


func _play(voice_line : VoiceLine) -> void:
	stream_player.stream = voice_line.audio_stream
	stream_player.play()
	voiceline_text_area.text = voice_line.text
	animation_player.play("fade_in_fade_out")
