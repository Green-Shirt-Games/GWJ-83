extends Button


func _ready() -> void:
	mouse_entered.connect(
		func():
			SfxAutoload.on_button_hover()
	)
	
	pressed.connect(
		func():
			SfxAutoload.on_button_pressed()
	)
