extends Node2D
class_name VoiceLines

@export var loss_lines : Array[VoiceLine]
@export var win_lines : Array[VoiceLine]
@export var buy_bluff : VoiceLine
@export var buy_peek : VoiceLine
@export var buy_rotate : VoiceLine
@export var key_line : VoiceLine
@export var key : Key
@export var register : Register
@onready var stream_player : AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var voiceline_text_area : Label = $Sprite2D/Label
@onready var animation_player : AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	visible = false
	key.key_touched_early.connect(_on_key_touched_early)
	register.buy_pressed.connect(_on_purchase_made)
	register.too_poor.connect(_not_enough_chips)

func play_loss_line():
	_play(_get_random_from(loss_lines))


func play_win_line():
	_play(_get_random_from(win_lines))

func _get_random_from(array : Array[VoiceLine]) -> VoiceLine:
	return array.pick_random()

func _on_key_touched_early():
	_play(key_line)

func _on_purchase_made(bottles : Array[Bottle], total_price : int):
	for bottle in bottles:
		on_drink_bought(bottle)


func _not_enough_chips():
	pass #TODO

func _play(voice_line : VoiceLine) -> void:
	if stream_player.playing:
		return
	stream_player.stream = voice_line.audio_stream
	stream_player.play()
	voiceline_text_area.text = voice_line.text
	animation_player.play("fade_in_fade_out")


var played_map : Dictionary[BottleData.TYPE, bool] = {}


func on_drink_bought(bottle : Bottle):
	var type : BottleData.TYPE = bottle.bottle_resource.type
	if played_map.has(type):
		return
	else:
		played_map.set(type, true)
	
	match type:
		BottleData.TYPE.PEEK_SHOE:
			_play(buy_peek)
		BottleData.TYPE.ROTATE:
			_play(buy_rotate)
		BottleData.TYPE.DOUBLE:
			_play(buy_bluff)
