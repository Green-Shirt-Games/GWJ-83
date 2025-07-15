extends Node2D

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
