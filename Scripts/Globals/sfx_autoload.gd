extends Node2D

@onready var melody : AudioStreamPlayer = $music_melody
@onready var rhythm : AudioStreamPlayer = $music_rhythm

func music():
	$music.play()

func on_button_hover():
	$ButtonHover.play()

func on_button_pressed():
	$ButtonPressed.play()

func bottle():
	$sfx_bottle.play()
	
func burning():
	$sfx_burning.play()

@export var melody_fade_time : float = 2
@export var melody_fade_db : float = -12
const min_volume : float = -80.0

@onready var _melody_starting_db : float = melody.volume_db
@onready var _rhythm_starting_db : float = rhythm.volume_db

var volume_scale : float = 1
var _new_max_volume : float
var melody_tween : Tween = null
var faded : bool = false

func fade_down_melody():
	faded = true
	_set_melody(_melody_starting_db + melody_fade_db)

func fade_up_melody():
	faded = false
	_set_melody(_melody_starting_db)

func _set_melody(db : float):
	if melody_tween != null and melody_tween.is_running():
		melody_tween.kill()
	melody_tween = create_tween()
	melody_tween.tween_property(melody, "volume_db", db, melody_fade_time)

func linear_to_db(volume : float, max_db : float) -> float:
	if volume <= 0.0:
		return min_volume
	return lerp(min_volume, max_db, pow(volume, 0.5))
