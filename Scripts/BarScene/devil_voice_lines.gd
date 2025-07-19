extends Node2D
class_name DevilVoiceLines

@export var dealer_blackjack : Array[VoiceLine]
@export var player_blackjack : Array[VoiceLine]
@export var dealer_wins : Array[VoiceLine]
@export var player_wins : Array[VoiceLine]
@export var greetings : Array[VoiceLine]
@export var pushes : Array[VoiceLine]
@export var player_double_down : VoiceLine
@export var end_game : VoiceLine
@export var free_drink : VoiceLine

@export var cooldown : float = 3.0
var on_cooldown : bool = false

@onready var stream_player : AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var voiceline_text_area : Label = $Sprite2D/Label
@onready var animation_player : AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	visible = false
	stream_player.finished.connect(_on_greetings_finished)

func on_dealer_blackjack():
	_play(dealer_blackjack.pick_random())

func on_player_blackjack():
	_play(player_blackjack.pick_random())

func on_dealer_win():
	_play(dealer_wins.pick_random())

func on_player_win():
	_play(player_wins.pick_random())

func on_greetings():
	_play(greetings.pick_random())
	

func _on_greetings_finished():
	Global.welcome_line_finished.emit()
	stream_player.finished.disconnect(_on_greetings_finished)

func on_push():
	_play(pushes.pick_random())

func on_double_down():
	_play(player_double_down)

func on_end_game():
	_play(end_game)

func on_free_drink():
	_play(free_drink)


func _play(voice_line : VoiceLine) -> void:
	if on_cooldown:
		return
	if stream_player.playing:
		return
	stream_player.stream = voice_line.audio_stream
	stream_player.play()
	voiceline_text_area.text = voice_line.text
	animation_player.play("fade_in_fade_out")
	
	get_tree().create_timer(cooldown).timeout.connect(func():on_cooldown=false)
	on_cooldown = true
