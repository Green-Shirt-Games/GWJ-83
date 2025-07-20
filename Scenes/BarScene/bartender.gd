extends Node2D

@onready var btv : BartenderVoiceLines = $VoiceLines
@onready var idle : Sprite2D = $Idle
@onready var talking : Sprite2D = $Talking
func _ready() -> void:
	btv.started.connect(func():
		idle.visible = false
		talking.visible = true)
	
	btv.finished.connect(func():
		idle.visible = true
		talking.visible = false)
