class_name TextureButtonWithSFX
extends TextureButton

func _ready() -> void:
	mouse_entered.connect(SfxAutoload.on_button_hover)
	pressed.connect(SfxAutoload.on_button_pressed)
