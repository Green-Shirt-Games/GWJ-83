extends Node2D
class_name DevilVoiceLines

signal started
signal finished

@export var dealer_blackjack : Array[VoiceLine]
@export var player_blackjack : Array[VoiceLine]
@export var dealer_wins : Array[VoiceLine]
@export var player_wins : Array[VoiceLine]
@export var greetings : Array[VoiceLine]
@export var pushes : Array[VoiceLine]
@export var player_double_down : VoiceLine
@export var end_game : VoiceLine
@export var free_drink : VoiceLine
@export var player_wins_final_hand : VoiceLine
@export var player_loses_final_hand : Array[VoiceLine]
@export var player_can_afford : VoiceLine

@export var cooldown : float = 3.0
@export var table_parent : TableScene
var on_cooldown : bool = false

@export var key_data : BottleData

@onready var stream_player : AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var voiceline_text_area : Label = $Sprite2D/Label
@onready var animation_player : AnimationPlayer = $AnimationPlayer

var played_player_can_afford : bool = false

var greetings_said : bool = false

func _ready() -> void:
	visible = false
	stream_player.finished.connect(_on_greetings_finished)
	table_parent.tie.connect(on_push)
	table_parent.player_blackjack.connect(on_player_blackjack)
	table_parent.dealer_blackjack.connect(on_dealer_blackjack)
	table_parent.player_win.connect(on_player_win)
	table_parent.dealer_win.connect(on_dealer_win)
	Global.change_room.connect(_on_room_change)
	Global.final_hand_started.connect(on_final_hand_start)
	stream_player.finished.connect(finished.emit)
	Global.final_hand_over.connect(func(win):_on_player_wins_final_hand() if win else _on_player_lose_final_hand())
	Global.player_lost_all_chips.connect(_on_player_lose_final_hand)

func _on_room_change(room : Global.ROOMS):
	if !greetings_said and room == Global.ROOMS.TABLE:
		greetings_said = true
		on_greetings()

func on_dealer_blackjack():
	if Global.money == 0: return
	_play(dealer_blackjack.pick_random())

func on_player_blackjack():
	_play(player_blackjack.pick_random())

func on_dealer_win():
	if Global.money == 0: return
	_play(dealer_wins.pick_random())

func on_player_win():
	if Global.money >= key_data.price && !played_player_can_afford:
		played_player_can_afford = true
		_play(player_can_afford)
	else:
		_play(player_wins.pick_random())

func on_greetings():
	_play(greetings.pick_random())


func on_final_hand_start():
	_play(end_game)


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


func _on_player_wins_final_hand():
	_play(player_wins_final_hand, true)


func _on_player_lose_final_hand():
	_play(player_loses_final_hand.pick_random(), true)

func _play(voice_line : VoiceLine, override = false) -> void:
	if stream_player.playing or on_cooldown and !override:
		return
	started.emit()
	stream_player.stream = voice_line.audio_stream
	stream_player.play()
	voiceline_text_area.text = voice_line.text
	animation_player.play("fade_in_fade_out")
	
	get_tree().create_timer(cooldown).timeout.connect(func():on_cooldown=false)
	on_cooldown = true
