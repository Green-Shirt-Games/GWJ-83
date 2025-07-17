extends Node2D

@onready var melody : AudioStreamPlayer = $music_melody

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


var melody_fade_time : float = 3
var melody_tween : Tween = null
func fade_down_melody():
	_set_melody(-12)

func fade_up_melody():
	_set_melody(-6)

func _set_melody(db : float):
	if melody_tween != null and melody_tween.is_running():
		melody_tween.kill()
	melody_tween = create_tween()
	melody_tween.tween_property(melody, "volume_db", db, melody_fade_time)
